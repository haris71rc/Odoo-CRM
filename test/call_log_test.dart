import 'package:flutter_test/flutter_test.dart';
import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/call_log/data/parser/lead_properties_parser.dart';
import 'package:odoocrm/features/call_log/data/services/follow_up_stage_resolver.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log_validation_snapshot.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_status_option.dart';
import 'package:odoocrm/features/call_log/domain/entities/device_call_event.dart';
import 'package:odoocrm/features/call_log/domain/repository/call_log_repository.dart';
import 'package:odoocrm/features/call_log/domain/services/call_log_service.dart';
import 'package:odoocrm/features/call_log/domain/utils/call_log_updater.dart';
import 'package:odoocrm/features/chatter/domain/entities/chatter_message_entity.dart';
import 'package:odoocrm/features/chatter/domain/entities/tracking_value_entity.dart';
import 'package:odoocrm/features/chatter/domain/repository/chatter_repository.dart';

void main() {
  group('LeadPropertiesParser', () {
    const parser = LeadPropertiesParser();

    final sampleReadList = [
      {
        'name': '70f1aed4e5191458',
        'type': 'char',
        'string': 'Property 1',
        'value': false,
      },
      {
        'name': '40b914c159b18869',
        'type': 'separator',
        'string': 'Call Log',
        'value': null,
      },
      {
        'name': 'first_dt',
        'type': 'datetime',
        'string': 'Call Date & Time (First)',
        'value': false,
      },
      {
        'name': '755dd30af8e6281e',
        'type': 'datetime',
        'string': 'Call Date & Time (Last)',
        'default': false,
        'value': false,
      },
      {
        'name': 'd911c6d388aa8070',
        'type': 'char',
        'string': 'Total Call Duration',
        'default': false,
        'value': false,
      },
      {
        'name': '8943dbf5bf8cc84f',
        'tags': [
          ['picked', 'Picked', 2],
          ['not_picked', 'Not Picked', 3],
        ],
        'type': 'tags',
        'string': 'Call Status',
        'default': false,
        'value': false,
      },
      {
        'name': 'inbound',
        'type': 'integer',
        'string': 'Total InBound Calls',
        'value': 0,
      },
      {
        'name': 'outbound',
        'type': 'integer',
        'string': 'Total Outbound Call',
        'value': 0,
      },
      {
        'name': 'response',
        'type': 'float',
        'string': 'Response Time (Minutes)',
        'value': 0.0,
      },
    ];

    test('parses tag tuple and list formats from read', () {
      expect(
        parser.parse([
          {
            'name': '8943dbf5bf8cc84f',
            'type': 'tags',
            'string': 'Call Status',
            'value': ['picked'],
          },
        ]).callLog.status,
        'picked',
      );

      expect(
        parser.parse([
          {
            'name': '8943dbf5bf8cc84f',
            'type': 'tags',
            'string': 'Call Status',
            'value': [['not_picked', 'Not Picked', 3]],
          },
        ]).callLog.status,
        'not_picked',
      );
    });

    test('parses string tag value from read list', () {
      final withValues = [
        ...sampleReadList.sublist(0, 4),
        {
          'name': '8943dbf5bf8cc84f',
          'tags': [
            ['picked', 'Picked', 2],
            ['not_picked', 'Not Picked', 3],
          ],
          'type': 'tags',
          'string': 'Call Status',
          'value': 'not_picked',
        },
      ];

      final snapshot = parser.parse(withValues);
      expect(snapshot.callLog.status, 'not_picked');
    });

    test('mergeCallLogForWrite produces dict keyed by property name', () {
      final writeMap = parser.mergeCallLogForWrite(
        sampleReadList,
        CallLog(
          firstCallDate: DateTime(2026, 8, 6, 14, 0),
          lastCallDate: DateTime(2026, 8, 6, 15, 13, 32),
          duration: '00:00',
          totalDuration: '02:05',
          status: 'not_picked',
          totalInboundCalls: 1,
          totalOutboundCalls: 3,
          responseTimeMinutes: 12.5,
        ),
      ) as Map;

      expect(writeMap, isA<Map>());
      expect(writeMap['first_dt'], '2026-08-06 14:00:00');
      expect(writeMap.containsKey('755dd30af8e6281e'), isTrue);
      expect(writeMap.containsKey('d911c6d388aa8070'), isTrue);
      expect(writeMap.containsKey('8943dbf5bf8cc84f'), isTrue);
      expect(writeMap['8943dbf5bf8cc84f'], ['not_picked']);
      expect(writeMap['inbound'], 1);
      expect(writeMap['outbound'], 3);
      expect(writeMap['response'], 12.5);
      expect(writeMap.containsKey('40b914c159b18869'), isFalse);
      expect(writeMap['70f1aed4e5191458'], false);
    });

    test('writes Call Date & Time (Last) as local wall-clock', () {
      final localCall = DateTime(2026, 8, 10, 11, 27, 0);
      final writeMap = parser.mergeCallLogForWrite(
        sampleReadList,
        CallLog(
          lastCallDate: localCall,
          totalDuration: '00:30',
          status: 'picked',
        ),
      ) as Map;

      expect(writeMap['755dd30af8e6281e'], '2026-08-10 11:27:00');
    });

    test('parses Call Date & Time (Last) as local without UTC shift', () {
      final snapshot = parser.parse([
        {
          'name': '755dd30af8e6281e',
          'type': 'datetime',
          'string': 'Call Date & Time (Last)',
          'value': '2026-08-10 11:27:00',
        },
      ]);

      expect(snapshot.callLog.lastCallDate, DateTime(2026, 8, 10, 11, 27, 0));
    });

    test('parses extended call log fields from read list', () {
      final snapshot = parser.parse([
        {
          'name': 'first_dt',
          'type': 'datetime',
          'string': 'Call Date & Time (First)',
          'value': '2026-08-10 10:00:00',
        },
        {
          'name': '755dd30af8e6281e',
          'type': 'datetime',
          'string': 'Call Date & Time (Last)',
          'value': '2026-08-10 11:27:00',
        },
        {
          'name': 'd911c6d388aa8070',
          'type': 'char',
          'string': 'Total Call Duration',
          'value': '05:30',
        },
        {
          'name': 'inbound',
          'type': 'integer',
          'string': 'Total InBound Calls',
          'value': 2,
        },
        {
          'name': 'outbound',
          'type': 'integer',
          'string': 'Total Outbound Call',
          'value': 4,
        },
        {
          'name': 'response',
          'type': 'float',
          'string': 'Response Time (Minutes)',
          'value': 15.75,
        },
      ]);

      expect(snapshot.callLog.firstCallDate, DateTime(2026, 8, 10, 10));
      expect(snapshot.callLog.lastCallDate, DateTime(2026, 8, 10, 11, 27));
      expect(snapshot.callLog.totalDuration, '05:30');
      expect(snapshot.callLog.totalInboundCalls, 2);
      expect(snapshot.callLog.totalOutboundCalls, 4);
      expect(snapshot.callLog.responseTimeMinutes, 15.75);
    });

    test('parses call status options from Odoo tags definition', () {
      final options = parser.parseCallStatusOptions([
        {
          'name': '8943dbf5bf8cc84f',
          'type': 'tags',
          'string': 'Call Status',
          'tags': [
            ['picked', 'Picked', 2],
            ['dnp', 'DNP', 3],
            ['busy', 'Busy', 4],
            ['hanged_up', 'Hanged Up', 5],
            ['missed', 'Missed', 6],
            ['call_failed', 'Call Failed', 7],
          ],
        },
      ]);

      expect(options.length, 6);
      expect(options.first.key, 'picked');
      expect(options.first.label, 'Picked');
      expect(options[1].key, 'dnp');
      expect(options.last.label, 'Call Failed');
    });

    test('resolveTagKey maps device hints to Odoo tag keys', () {
      const options = [
        CallStatusOption(key: 'picked', label: 'Picked'),
        CallStatusOption(key: 'dnp', label: 'DNP'),
        CallStatusOption(key: 'call_failed', label: 'Call Failed'),
      ];

      expect(parser.resolveTagKey(options, 'dnp'), 'dnp');
      expect(parser.resolveTagKey(options, 'call_failed'), 'call_failed');
      expect(parser.resolveTagKey(options, 'not_picked'), 'dnp');
    });
  });

  group('CallLogUpdater', () {
    test('first outbound call sets first/last dates and response time', () {
      final leadCreated = DateTime(2026, 8, 10, 10, 0);
      final callAt = DateTime(2026, 8, 10, 10, 15);

      final merged = CallLogUpdater.applyOutboundCall(
        existing: const CallLog(),
        callEvent: CallLog(
          lastCallDate: callAt,
          duration: '02:00',
          status: 'picked',
        ),
        leadCreatedAt: leadCreated,
      );

      expect(merged.firstCallDate, callAt);
      expect(merged.lastCallDate, callAt);
      expect(merged.totalDuration, '02:00');
      expect(merged.totalOutboundCalls, 1);
      expect(merged.responseTimeMinutes, 15.0);
    });

    test('subsequent outbound calls accumulate duration and outbound count', () {
      final merged = CallLogUpdater.applyOutboundCall(
        existing: CallLog(
          firstCallDate: DateTime(2026, 8, 10, 10, 0),
          lastCallDate: DateTime(2026, 8, 10, 10, 0),
          totalDuration: '01:30',
          totalOutboundCalls: 1,
          responseTimeMinutes: 5,
        ),
        callEvent: CallLog(
          lastCallDate: DateTime(2026, 8, 10, 11, 0),
          duration: '00:45',
          status: 'dnp',
        ),
        leadCreatedAt: DateTime(2026, 8, 10, 9, 55),
      );

      expect(merged.firstCallDate, DateTime(2026, 8, 10, 10, 0));
      expect(merged.lastCallDate, DateTime(2026, 8, 10, 11, 0));
      expect(merged.totalDuration, '02:15');
      expect(merged.totalOutboundCalls, 2);
      expect(merged.responseTimeMinutes, 5);
      expect(merged.status, 'dnp');
    });

    test('failed calls with zero duration do not increase total duration', () {
      final merged = CallLogUpdater.applyOutboundCall(
        existing: CallLog(
          firstCallDate: DateTime(2026, 8, 10, 10, 0),
          totalDuration: '02:00',
          totalOutboundCalls: 1,
        ),
        callEvent: CallLog(
          lastCallDate: DateTime(2026, 8, 10, 11, 0),
          duration: '00:00',
          status: 'call_failed',
        ),
        leadCreatedAt: DateTime(2026, 8, 10, 9, 55),
      );

      expect(merged.totalDuration, '02:00');
      expect(merged.duration, '00:00');
      expect(merged.totalOutboundCalls, 2);
    });

    test('inbound sync only increases stored count', () {
      const existing = CallLog(totalInboundCalls: 2);
      expect(
        CallLogUpdater.applyInboundSync(
          existing: existing,
          deviceInboundCount: 1,
        ),
        existing,
      );
      expect(
        CallLogUpdater.applyInboundSync(
          existing: existing,
          deviceInboundCount: 5,
        ).totalInboundCalls,
        5,
      );
    });

    test('skips device outbound near last saved call (duplicate window)', () {
      final last = DateTime(2026, 8, 10, 12, 0, 0);
      expect(
        CallLogUpdater.shouldApplyDeviceOutbound(
          deviceAt: last.add(const Duration(seconds: 20)),
          lastCallDate: last,
        ),
        isFalse,
      );
      expect(
        CallLogUpdater.shouldApplyDeviceOutbound(
          deviceAt: last.add(const Duration(minutes: 2)),
          lastCallDate: last,
        ),
        isTrue,
      );
    });

    test('applyDeviceSync merges newer dialer outbound and inbound count', () {
      final existing = CallLog(
        firstCallDate: DateTime(2026, 8, 10, 10, 0),
        lastCallDate: DateTime(2026, 8, 10, 10, 0),
        totalDuration: '01:00',
        totalOutboundCalls: 1,
        totalInboundCalls: 0,
        status: 'picked',
      );

      final synced = CallLogUpdater.applyDeviceSync(
        existing: existing,
        deviceCalls: [
          DeviceCallEvent(
            at: DateTime(2026, 8, 10, 10, 0, 10), // within duplicate window
            duration: '01:00',
            status: 'picked',
            isOutbound: true,
            isInbound: false,
          ),
          DeviceCallEvent(
            at: DateTime(2026, 8, 10, 11, 30),
            duration: '00:40',
            status: 'dnp',
            isOutbound: true,
            isInbound: false,
          ),
          DeviceCallEvent(
            at: DateTime(2026, 8, 10, 11, 0),
            duration: '00:00',
            status: 'missed',
            isOutbound: false,
            isInbound: true,
          ),
        ],
        leadCreatedAt: DateTime(2026, 8, 10, 9, 0),
      );

      expect(synced.lastCallDate, DateTime(2026, 8, 10, 11, 30));
      expect(synced.totalOutboundCalls, 2);
      expect(synced.totalDuration, '01:40');
      expect(synced.status, 'dnp');
      expect(synced.totalInboundCalls, 1);
      expect(synced.firstCallDate, DateTime(2026, 8, 10, 10, 0));
    });
  });

  group('CallLogService', () {
    final service = CallLogService(
      repository: _FakeCallLogRepository(),
      chatterRepository: _FakeChatterRepository(),
    );

    test('Rule 1 blocks non Follow-Up when call data missing', () {
      expect(
        service.canMoveToStage(
          callLog: const CallLog(),
          currentStageName: 'New Prospects',
          targetStageName: 'Qualified',
        ),
        CallLogService.rule1Message,
      );
    });

    test(
      'Rule 2 allows Follow-Up → Do Not Picked when call is after Follow-Up even if status is missing',
      () {
        // Production case: Call Status was false in Odoo (tag not defined),
        // but Call Date 12:36 IST is after Follow-Up at 05:56 UTC (= 11:26 IST).
        final followUpAtUtc = DateTime.utc(2026, 8, 10, 5, 56, 10);
        final callLocal = DateTime(2026, 8, 10, 12, 36, 27);

        expect(
          service.canMoveToStage(
            callLog: CallLog(
              lastCallDate: callLocal,
              duration: '00:00',
              status: null,
            ),
            currentStageName: 'Follow-Up',
            targetStageName: 'Do Not Picked',
            followUpEnteredAt: followUpAtUtc.toLocal(),
          ),
          isNull,
        );
      },
    );

    test(
      'Rule 2 blocks Follow-Up → Do Not Picked when call is before Follow-Up',
      () {
        final followUpAt = DateTime(2026, 8, 10, 11, 0);
        final callBefore = CallLog(
          lastCallDate: DateTime(2026, 8, 10, 10, 50),
          duration: '00:30',
          status: 'not_picked',
        );

        expect(
          service.canMoveToStage(
            callLog: callBefore,
            currentStageName: 'Follow-Up',
            targetStageName: 'Do Not Picked',
            followUpEnteredAt: followUpAt,
          ),
          CallLogService.rule2Message,
        );

        expect(
          service.canMoveToStage(
            callLog: callBefore,
            currentStageName: 'Follow-Up',
            targetStageName: 'Not connected (DNP)',
            followUpEnteredAt: followUpAt,
          ),
          CallLogService.rule2Message,
        );
      },
    );

    test(
      'Rule 2 blocks Follow-Up → Do Not Picked when call time equals Follow-Up',
      () {
        final followUpAt = DateTime(2026, 8, 10, 11, 0);
        expect(
          service.canMoveToStage(
            callLog: CallLog(
              lastCallDate: followUpAt,
              duration: '00:00',
              status: 'not_picked',
            ),
            currentStageName: 'Follow-Up',
            targetStageName: 'Do Not Picked',
            followUpEnteredAt: followUpAt,
          ),
          CallLogService.rule2Message,
        );
      },
    );

    test(
      'Rule 2 allows Follow-Up → Do Not Picked when call is after Follow-Up',
      () {
        final followUpAt = DateTime(2026, 8, 10, 11, 0);
        expect(
          service.canMoveToStage(
            callLog: CallLog(
              lastCallDate: DateTime(2026, 8, 10, 11, 27),
              duration: '00:00',
              status: 'not_picked',
            ),
            currentStageName: 'Follow-Up',
            targetStageName: 'Do Not Picked',
            followUpEnteredAt: followUpAt,
          ),
          isNull,
        );
      },
    );

    test('Rule 2 blocks when Follow-Up entry time is unknown', () {
      expect(
        service.canMoveToStage(
          callLog: CallLog(
            lastCallDate: DateTime(2026, 8, 10, 12),
            duration: '01:00',
            status: 'picked',
          ),
          currentStageName: 'Follow-Up',
          targetStageName: 'Do Not Picked',
          followUpEnteredAt: null,
        ),
        CallLogService.rule2Message,
      );
    });

    test(
      'Rule 2 blocks Follow-Up → DNP when only an older call exists',
      () {
        // User moves to Follow-Up at 11:51, tries DNP at 11:52 without calling.
        // An older Call Date from earlier must not unlock the move.
        expect(
          service.canMoveToStage(
            callLog: CallLog(
              lastCallDate: DateTime(2026, 8, 10, 10, 30),
              duration: '00:00',
              status: 'not_picked',
            ),
            currentStageName: 'Follow-Up',
            targetStageName: 'Not connected (DNP)',
            followUpEnteredAt: DateTime(2026, 8, 10, 11, 51),
          ),
          CallLogService.rule2Message,
        );
      },
    );
  });

  group('FollowUpStageResolver', () {
    const resolver = FollowUpStageResolver();

    test('uses newest Follow-Up stage change', () async {
      final messages = [
        ChatterMessageEntity(
          id: 2,
          date: DateTime.utc(2026, 8, 10, 6, 21), // 11:51 IST
          subtypeDescription: 'Stage changed',
          trackingValues: const [
            TrackingValueEntity(
              changedField: 'Stage',
              oldValue: 'New Prospects',
              newValue: 'Follow-Up',
            ),
          ],
        ),
        ChatterMessageEntity(
          id: 1,
          date: DateTime.utc(2026, 8, 9, 4),
          subtypeDescription: 'Stage changed',
          trackingValues: const [
            TrackingValueEntity(
              changedField: 'Stage',
              oldValue: 'Qualified',
              newValue: 'Follow-Up',
            ),
          ],
        ),
      ];

      final at = await resolver.resolve(
        _FakeChatterRepository(messages),
        1,
      );
      expect(at, DateTime.utc(2026, 8, 10, 6, 21).toLocal());
    });

    test(
      'falls back to write_date when newest stage change is not Follow-Up',
      () async {
        // Chatter still shows earlier → New Prospects; lead already in Follow-Up.
        final messages = [
          ChatterMessageEntity(
            id: 1,
            date: DateTime.utc(2026, 8, 10, 5),
            subtypeDescription: 'Stage changed',
            trackingValues: const [
              TrackingValueEntity(
                changedField: 'Stage',
                oldValue: 'Follow-Up',
                newValue: 'New Prospects',
              ),
            ],
          ),
        ];

        final writeDate = DateTime.utc(2026, 8, 10, 6, 21);
        final at = await resolver.resolve(
          _FakeChatterRepository(messages),
          1,
          leadWriteDate: writeDate,
        );
        expect(at, writeDate.toLocal());
      },
    );
  });
}

class _FakeCallLogRepository implements CallLogRepository {
  @override
  Future<Result<CallLog>> getCallLog(int leadId) async =>
      throw UnimplementedError();

  @override
  Future<Result<CallLogValidationSnapshot>> getValidationSnapshot(
    int leadId,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Result<List<CallStatusOption>>> getCallStatusOptions(int leadId) async =>
      throw UnimplementedError();

  @override
  Future<Result<void>> saveCallLog({
    required int leadId,
    required CallLog callLog,
  }) async =>
      throw UnimplementedError();
}

class _FakeChatterRepository implements ChatterRepository {
  _FakeChatterRepository([this._messages = const []]);

  final List<ChatterMessageEntity> _messages;

  @override
  Future<Result<List<ChatterMessageEntity>>> getMessagesForLead(int leadId) async =>
      Success(_messages);

  @override
  Future<Result<void>> logNote({
    required int leadId,
    required String body,
  }) async =>
      throw UnimplementedError();
}
