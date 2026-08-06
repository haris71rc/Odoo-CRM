import 'package:flutter_test/flutter_test.dart';
import 'package:odoocrm/features/chatter/domain/entities/chatter_message_entity.dart';
import 'package:odoocrm/features/chatter/domain/entities/tracking_value_entity.dart';
import 'package:odoocrm/features/mobile_call/data/parser/mobile_call_parser.dart';
import 'package:odoocrm/features/mobile_call/domain/entities/latest_mobile_call_entity.dart';
import 'package:odoocrm/features/mobile_call/domain/entities/stage_call_validation_data.dart';
import 'package:odoocrm/features/mobile_call/domain/validation/stage_call_validator.dart';

void main() {
  group('MobileCallParser', () {
    const parser = MobileCallParser();

    test('parses MOBILE_CALL JSON from HTML chatter body', () {
      const body = '''
<p>[MOBILE_CALL]</p>
<p>{"source":"mobile_app","type":"call","status":"answered","duration":125,"direction":"outgoing","phone":"9876543210","timestamp":"2026-08-05T17:45:00","user_id":7}</p>
<p>[/MOBILE_CALL]</p>
<p>Customer answered the phone.</p>
''';

      final call = parser.parseBody(body);
      expect(call, isNotNull);
      expect(call!.status, 'answered');
      expect(call.duration, 125);
      expect(call.direction, 'outgoing');
      expect(call.phone, '9876543210');
      expect(call.userId, 7);
    });

    test('ignores malformed JSON without crashing', () {
      const body = '[MOBILE_CALL]{bad json}[/MOBILE_CALL]';
      expect(parser.parseBody(body), isNull);
    });

    test('attaches message id and loggedAt from chatter', () {
      final messages = [
        ChatterMessageEntity(
          id: 50,
          date: DateTime(2026, 8, 5, 18, 0),
          body:
              '[MOBILE_CALL]{"status":"no_answer","duration":0,"direction":"outgoing","phone":"1","timestamp":"2026-08-05T18:55:02","user_id":66}[/MOBILE_CALL]',
        ),
      ];

      final call = parser.parseLatestFromMessages(messages);
      expect(call?.messageId, 50);
      expect(call?.loggedAt, DateTime(2026, 8, 5, 18, 0));
      expect(call?.timestamp, DateTime(2026, 8, 5, 18, 55, 2));
    });

    test('finds Follow-up stage entry from tracking and subtype text', () {
      final messages = [
        ChatterMessageEntity(
          id: 120,
          date: DateTime(2026, 8, 5, 18, 0),
          subtypeDescription: 'Stage set to Follow-Up',
        ),
        ChatterMessageEntity(
          id: 110,
          date: DateTime(2026, 8, 5, 17, 59),
          trackingValues: const [
            TrackingValueEntity(
              changedField: 'Stage',
              oldValue: 'New Prospects',
              newValue: 'Not connected (DNP)',
            ),
          ],
        ),
      ];

      final entry = parser.findFollowUpEntry(messages);
      expect(entry?.messageId, 120);
      expect(entry?.at, DateTime(2026, 8, 5, 18, 0));
    });
  });

  group('StageCallValidator', () {
    test('blocks leaving Follow-up when call message is older than Follow-up',
        () {
      // Reproduces the production bug: dial JSON timestamp is later than
      // Follow-up UI time, but the Log Note was posted before Follow-up.
      final callBeforeFollowUp = LatestMobileCallEntity(
        status: 'no_answer',
        duration: 0,
        direction: 'outgoing',
        phone: '+91 70115 28419',
        timestamp: DateTime(2026, 8, 5, 18, 55, 2),
        userId: 66,
        messageId: 100,
        loggedAt: DateTime(2026, 8, 5, 18, 0),
      );

      final error = StageCallValidator.validate(
        currentStageName: 'Follow-Up',
        targetStageName: 'Not connected (DNP)',
        data: StageCallValidationData(
          latestCall: callBeforeFollowUp,
          mobileCalls: [callBeforeFollowUp],
          followUpEnteredAt: DateTime(2026, 8, 5, 18, 0),
          followUpEnteredMessageId: 110,
        ),
        currentUserId: 66,
      );

      expect(error, StageCallValidator.leaveFollowUpMessage);
    });

    test('allows leaving Follow-up when call message is newer', () {
      final callAfterFollowUp = LatestMobileCallEntity(
        status: 'answered',
        duration: 30,
        direction: 'outgoing',
        phone: '9876543210',
        timestamp: DateTime(2026, 8, 5, 18, 5),
        userId: 66,
        messageId: 130,
        loggedAt: DateTime(2026, 8, 5, 18, 5),
      );

      final error = StageCallValidator.validate(
        currentStageName: 'Follow-Up',
        targetStageName: 'Qualified',
        data: StageCallValidationData(
          latestCall: callAfterFollowUp,
          mobileCalls: [callAfterFollowUp],
          followUpEnteredAt: DateTime(2026, 8, 5, 18, 0),
          followUpEnteredMessageId: 110,
        ),
        currentUserId: 66,
      );

      expect(error, isNull);
    });

    test('Rule 1 allows only Follow-up when no call exists', () {
      expect(
        StageCallValidator.validate(
          currentStageName: 'New Prospect',
          targetStageName: 'Follow-up',
          data: const StageCallValidationData(
            latestCall: null,
            mobileCalls: [],
          ),
          currentUserId: 7,
        ),
        isNull,
      );
      expect(
        StageCallValidator.validate(
          currentStageName: 'New Prospect',
          targetStageName: 'Qualified',
          data: const StageCallValidationData(
            latestCall: null,
            mobileCalls: [],
          ),
          currentUserId: 7,
        ),
        'Please call the customer before changing stage.',
      );
    });

    test('Rule 3 blocks Do Not Picked after answered post-Follow-up call', () {
      final answered = LatestMobileCallEntity(
        status: 'answered',
        duration: 30,
        direction: 'outgoing',
        phone: '9876543210',
        timestamp: DateTime(2026, 8, 5, 18, 5),
        userId: 7,
        messageId: 130,
        loggedAt: DateTime(2026, 8, 5, 18, 5),
      );

      expect(
        StageCallValidator.validate(
          currentStageName: 'Follow-up',
          targetStageName: 'Do Not Picked',
          data: StageCallValidationData(
            latestCall: answered,
            mobileCalls: [answered],
            followUpEnteredAt: DateTime(2026, 8, 5, 18),
            followUpEnteredMessageId: 110,
          ),
          currentUserId: 7,
        ),
        'Lead can only be marked Do Not Picked after an unanswered call.',
      );
    });
  });
}
