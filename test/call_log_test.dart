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
import 'package:odoocrm/features/call_log/domain/utils/connected_call_rule.dart';
import 'package:odoocrm/features/chatter/domain/entities/chatter_message_entity.dart';
import 'package:odoocrm/features/chatter/domain/entities/tracking_value_entity.dart';
import 'package:odoocrm/features/chatter/domain/repository/chatter_repository.dart';
import 'package:odoocrm/features/leads/presentation/utils/lead_list_filters.dart';
import 'package:odoocrm/features/stages/domain/entities/stage_entity.dart';

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

    test('parses dict payload keyed only by property name', () {
      final snapshot = parser.parse({
        'first_dt': '2026-08-10 18:30:49',
        '755dd30af8e6281e': false,
        'inbound': 0,
        'outbound': 0,
        'response': 0.0,
        'd911c6d388aa8070': '01:00',
        '8943dbf5bf8cc84f': ['picked'],
      });

      expect(snapshot.callLog.firstCallDate, DateTime(2026, 8, 10, 18, 30, 49));
      expect(snapshot.callLog.totalInboundCalls, 0);
      expect(snapshot.callLog.totalOutboundCalls, 0);
      expect(snapshot.callLog.responseTimeMinutes, 0);
    });

    test('writes last date and outbound onto existing Odoo property names', () {
      final first = DateTime(2026, 8, 10, 18, 30, 49);
      final writeMap = parser.mergeCallLogForWrite(
        sampleReadList,
        CallLog(
          firstCallDate: first,
          lastCallDate: first,
          totalDuration: '01:00',
          status: 'picked',
          totalInboundCalls: 0,
          totalOutboundCalls: 1,
          responseTimeMinutes: 12.5,
        ),
      ) as Map;

      expect(writeMap['first_dt'], '2026-08-10 18:30:49');
      expect(writeMap['755dd30af8e6281e'], '2026-08-10 18:30:49');
      expect(writeMap['outbound'], 1);
      expect(writeMap['inbound'], 0);
      expect(writeMap['response'], 12.5);
      expect(writeMap['d911c6d388aa8070'], '01:00');
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

    test('resolveTagKey does not map picked to the first DNP tag', () {
      const options = [
        CallStatusOption(key: 'dnp', label: 'DNP'),
        CallStatusOption(key: 'busy', label: 'Busy'),
      ];

      expect(parser.resolveTagKey(options, 'picked'), 'picked');
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

    test('uses first call as duplicate anchor when last call is missing', () {
      final first = DateTime(2026, 8, 10, 18, 30, 49);
      expect(
        CallLogUpdater.shouldApplyDeviceOutbound(
          deviceAt: first.add(const Duration(seconds: 10)),
          lastCallDate: null,
          firstCallDate: first,
        ),
        isFalse,
      );
      expect(
        CallLogUpdater.shouldApplyDeviceOutbound(
          deviceAt: first.add(const Duration(minutes: 2)),
          lastCallDate: null,
          firstCallDate: first,
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

    test('repairs screenshot-like Odoo row with empty last and zero outbound', () {
      final first = DateTime(2026, 8, 10, 18, 30, 49);
      final repaired = CallLogUpdater.repairIncomplete(
        existing: CallLog(
          firstCallDate: first,
          status: 'picked',
          totalDuration: '01:00',
          totalInboundCalls: 0,
          totalOutboundCalls: 0,
          responseTimeMinutes: 0,
        ),
        leadCreatedAt: DateTime(2026, 8, 10, 17, 30, 49),
      );

      expect(repaired.lastCallDate, first);
      expect(repaired.totalOutboundCalls, 1);
      expect(repaired.totalInboundCalls, 0);
      expect(repaired.responseTimeMinutes, 60.0);
      expect(repaired.totalDuration, '01:00');
    });

    test('device sync does not double-count when last is empty but first is set', () {
      final first = DateTime(2026, 8, 10, 18, 30, 49);
      final synced = CallLogUpdater.applyDeviceSync(
        existing: CallLog(
          firstCallDate: first,
          totalDuration: '01:00',
          status: 'picked',
          totalOutboundCalls: 0,
          totalInboundCalls: 0,
        ),
        deviceCalls: [
          DeviceCallEvent(
            at: first.add(const Duration(seconds: 8)),
            duration: '01:00',
            status: 'picked',
            isOutbound: true,
            isInbound: false,
          ),
        ],
        leadCreatedAt: DateTime(2026, 8, 10, 17, 0),
      );

      expect(synced.lastCallDate, first.add(const Duration(seconds: 8)));
      expect(synced.totalOutboundCalls, 1);
      expect(synced.totalDuration, '01:00');
    });

    test('overlays Android dialer duration onto a same-call placeholder', () {
      final at = DateTime(2026, 8, 10, 18, 30, 49);
      final synced = CallLogUpdater.applyDeviceSync(
        existing: CallLog(
          firstCallDate: at,
          lastCallDate: at,
          duration: '00:00',
          totalDuration: '00:00',
          status: 'picked',
          totalOutboundCalls: 1,
          totalInboundCalls: 0,
        ),
        deviceCalls: [
          DeviceCallEvent(
            at: at.add(const Duration(seconds: 12)),
            duration: '01:00',
            status: 'picked',
            isOutbound: true,
            isInbound: false,
          ),
        ],
        leadCreatedAt: DateTime(2026, 8, 10, 17, 0),
      );

      expect(synced.totalOutboundCalls, 1);
      expect(synced.duration, '01:00');
      expect(synced.totalDuration, '01:00');
      expect(synced.lastCallDate, at.add(const Duration(seconds: 12)));
    });
  });

  group('ConnectedCallRule', () {
    test('only picked calls lasting ≥ 3s qualify for Connected', () {
      expect(
        ConnectedCallRule.isConnectedConversation(
          duration: '00:00',
          status: 'dnp',
        ),
        isFalse,
      );
      expect(
        ConnectedCallRule.isConnectedConversation(
          duration: '00:05',
          status: 'dnp',
        ),
        isFalse,
      );
      expect(
        ConnectedCallRule.isConnectedConversation(
          duration: '00:05',
          status: 'call_failed',
        ),
        isFalse,
      );
      expect(
        ConnectedCallRule.isConnectedConversation(
          duration: '00:05',
          status: 'missed',
        ),
        isFalse,
      );
      expect(
        ConnectedCallRule.isConnectedConversation(
          duration: '00:02',
          status: 'picked',
        ),
        isFalse,
      );
      expect(
        ConnectedCallRule.isConnectedConversation(
          duration: '00:03',
          status: 'picked',
        ),
        isTrue,
      );
      expect(
        ConnectedCallRule.isConnectedConversation(
          duration: '01:05',
          status: 'picked',
        ),
        isTrue,
      );
      expect(
        ConnectedCallRule.callWasMade(
          CallLog(
            duration: '00:10',
            status: 'answered',
            lastCallDate: DateTime(2026, 8, 26, 12),
          ),
        ),
        isTrue,
      );
      expect(
        ConnectedCallRule.callWasMade(
          CallLog(status: 'not_picked', totalOutboundCalls: 1),
        ),
        isFalse,
      );
      expect(
        ConnectedCallRule.callWasMade(const CallLog()),
        isFalse,
      );
    });

    test('isPickedStatus rejects DNP / failed and accepts picked variants', () {
      expect(ConnectedCallRule.isPickedStatus('dnp'), isFalse);
      expect(ConnectedCallRule.isPickedStatus('not_picked'), isFalse);
      expect(ConnectedCallRule.isPickedStatus('call_failed'), isFalse);
      expect(ConnectedCallRule.isPickedStatus('busy'), isFalse);
      expect(ConnectedCallRule.isPickedStatus('hanged_up'), isFalse);
      expect(ConnectedCallRule.isPickedStatus('rejected'), isFalse);
      expect(ConnectedCallRule.isPickedStatus('picked'), isTrue);
      expect(ConnectedCallRule.isPickedStatus('Picked'), isTrue);
      expect(ConnectedCallRule.isPickedStatus('answered'), isTrue);
      expect(ConnectedCallRule.isPickedStatus('call_picked'), isTrue);
    });

    test(
      'uses totalDuration after Odoo round-trip when only one outbound exists',
      () {
        // Parser only persists total duration — latest duration is null on read.
        expect(
          ConnectedCallRule.callWasMade(
            const CallLog(
              status: 'picked',
              totalDuration: '00:12',
              totalOutboundCalls: 1,
            ),
          ),
          isTrue,
        );
        expect(
          ConnectedCallRule.callWasMade(
            const CallLog(
              status: 'picked',
              totalDuration: '00:02',
              totalOutboundCalls: 1,
            ),
          ),
          isFalse,
        );
        // Multi-call totals must not unlock Connected without latest duration.
        expect(
          ConnectedCallRule.callWasMade(
            const CallLog(
              status: 'picked',
              totalDuration: '05:00',
              totalOutboundCalls: 3,
            ),
          ),
          isFalse,
        );
      },
    );

    test('does not move later pipeline stages back to Connected', () {
      expect(
        ConnectedCallRule.shouldMoveToConnected('New Prospects'),
        isTrue,
      );
      expect(
        ConnectedCallRule.shouldMoveToConnected('Do Not Picked'),
        isTrue,
      );
      expect(
        ConnectedCallRule.shouldMoveToConnected('Not connected (DNP)'),
        isTrue,
      );
      expect(ConnectedCallRule.shouldMoveToConnected('Connected'), isFalse);
      expect(ConnectedCallRule.shouldMoveToConnected('Follow-Up'), isFalse);
      expect(ConnectedCallRule.shouldMoveToConnected('Proposal'), isFalse);
      expect(ConnectedCallRule.shouldMoveToConnected('Won'), isFalse);
      expect(ConnectedCallRule.shouldMoveToConnected('Lost'), isFalse);
    });
  });

  group('Connected promotion scenarios', () {
    test('DNP / failed / busy never qualify even with long duration', () {
      for (final status in [
        'dnp',
        'not_picked',
        'call_failed',
        'busy',
        'missed',
        'hanged_up',
      ]) {
        expect(
          ConnectedCallRule.callWasMade(
            CallLog(duration: '01:00', status: status),
          ),
          isFalse,
          reason: '$status must not promote',
        );
      }
    });

    test('picked duration boundary: 2s no, 3s yes', () {
      expect(
        ConnectedCallRule.callWasMade(
          const CallLog(duration: '00:02', status: 'picked'),
        ),
        isFalse,
      );
      expect(
        ConnectedCallRule.callWasMade(
          const CallLog(duration: '00:03', status: 'picked'),
        ),
        isTrue,
      );
    });

    test('manual outcome sheet Picked without duration does not promote', () {
      // Manual sheet only sets status + lastCallDate (no duration).
      expect(
        ConnectedCallRule.callWasMade(
          CallLog(
            lastCallDate: DateTime(2026, 8, 27, 12),
            status: 'picked',
          ),
        ),
        isFalse,
      );
    });

    test('OEM late duration: DNP placeholder then dialer overlay unlocks', () {
      final dialedAt = DateTime(2026, 8, 27, 14, 0, 0);
      final saved = CallLogUpdater.applyOutboundCall(
        existing: const CallLog(),
        callEvent: CallLog(
          lastCallDate: dialedAt,
          duration: '00:00',
          status: 'dnp',
        ),
        leadCreatedAt: DateTime(2026, 8, 27, 10),
      );
      expect(ConnectedCallRule.callWasMade(saved), isFalse);

      // Simulate Odoo round-trip (latest duration dropped, total kept).
      final fromOdoo = CallLog(
        firstCallDate: saved.firstCallDate,
        lastCallDate: saved.lastCallDate,
        status: saved.status,
        totalDuration: saved.totalDuration,
        totalOutboundCalls: saved.totalOutboundCalls,
      );
      expect(ConnectedCallRule.callWasMade(fromOdoo), isFalse);

      final synced = CallLogUpdater.applyDeviceSync(
        existing: fromOdoo,
        deviceCalls: [
          DeviceCallEvent(
            at: dialedAt.add(const Duration(seconds: 2)),
            duration: '00:15',
            status: 'picked',
            isOutbound: true,
            isInbound: false,
          ),
        ],
        leadCreatedAt: DateTime(2026, 8, 27, 10),
      );

      expect(synced.status, 'picked');
      expect(synced.duration, '00:15');
      expect(ConnectedCallRule.callWasMade(synced), isTrue);
      expect(
        ConnectedCallRule.shouldMoveToConnected('New Prospects'),
        isTrue,
      );
      expect(
        ConnectedCallRule.shouldMoveToConnected('Follow-Up'),
        isFalse,
      );
    });

    test('short picked call stays off Connected after overlay', () {
      final dialedAt = DateTime(2026, 8, 27, 15, 0, 0);
      final saved = CallLogUpdater.applyOutboundCall(
        existing: const CallLog(),
        callEvent: CallLog(
          lastCallDate: dialedAt,
          duration: '00:01',
          status: 'picked',
        ),
        leadCreatedAt: DateTime(2026, 8, 27, 10),
      );
      expect(ConnectedCallRule.callWasMade(saved), isFalse);

      final synced = CallLogUpdater.overlayDialerDetails(
        existing: saved,
        event: DeviceCallEvent(
          at: dialedAt,
          duration: '00:02',
          status: 'picked',
          isOutbound: true,
          isInbound: false,
        ),
      );
      expect(ConnectedCallRule.callWasMade(synced), isFalse);
    });

    test('happy path: picked ≥3s on early stage qualifies', () {
      final log = CallLogUpdater.applyOutboundCall(
        existing: const CallLog(),
        callEvent: CallLog(
          lastCallDate: DateTime(2026, 8, 27, 16, 0),
          duration: '00:08',
          status: 'picked',
        ),
        leadCreatedAt: DateTime(2026, 8, 27, 9),
      );
      expect(ConnectedCallRule.callWasMade(log), isTrue);
      expect(ConnectedCallRule.shouldMoveToConnected('Do Not Picked'), isTrue);
    });

    test('picked ≥3s on Follow-Up / Proposal / Won / Lost does not move', () {
      expect(ConnectedCallRule.callWasMade(
        const CallLog(duration: '00:20', status: 'picked'),
      ), isTrue);
      for (final stage in ['Follow-Up', 'Proposal', 'Won', 'Lost', 'Connected']) {
        expect(
          ConnectedCallRule.shouldMoveToConnected(stage),
          isFalse,
          reason: stage,
        );
      }
    });

    test('device sync of new external dialer call can unlock Connected', () {
      final existing = CallLog(
        firstCallDate: DateTime(2026, 8, 20, 10),
        lastCallDate: DateTime(2026, 8, 20, 10),
        duration: '00:00',
        status: 'dnp',
        totalDuration: '00:00',
        totalOutboundCalls: 1,
      );

      final synced = CallLogUpdater.applyDeviceSync(
        existing: existing,
        deviceCalls: [
          DeviceCallEvent(
            at: DateTime(2026, 8, 27, 11, 0),
            duration: '00:45',
            status: 'picked',
            isOutbound: true,
            isInbound: false,
          ),
        ],
        leadCreatedAt: DateTime(2026, 8, 19),
      );

      expect(synced.totalOutboundCalls, 2);
      expect(synced.status, 'picked');
      expect(synced.duration, '00:45');
      expect(ConnectedCallRule.callWasMade(synced), isTrue);
    });
  });

  group('LeadListFilters connected stage', () {
    test('matches Connected and ignores Not connected (DNP)', () {
      expect(LeadListFilters.isConnectedStage('Connected'), isTrue);
      expect(LeadListFilters.isConnectedStage('Call Connected'), isTrue);
      expect(
        LeadListFilters.isConnectedStage('Not connected (DNP)'),
        isFalse,
      );
      expect(LeadListFilters.isConnectedStage('Do Not Picked'), isFalse);
    });

    test('findConnectedStageId prefers exact Connected name', () {
      const stages = [
        StageEntity(id: 1, name: 'New Prospects'),
        StageEntity(id: 2, name: 'Not connected (DNP)'),
        StageEntity(id: 3, name: 'Connected'),
        StageEntity(id: 4, name: 'Follow-Up'),
      ];
      expect(LeadListFilters.findConnectedStageId(stages), 3);
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
      'Rule 2 allows call a few seconds before write_date Follow-Up proxy',
      () {
        // Dial at 11:51:00; call-log save bumps write_date proxy to 11:51:30.
        expect(
          service.canMoveToStage(
            callLog: CallLog(
              lastCallDate: DateTime(2026, 8, 10, 11, 51, 0),
              status: 'dnp',
            ),
            currentStageName: 'Follow-Up',
            targetStageName: 'Do Not Picked',
            followUpEnteredAt: DateTime(2026, 8, 10, 11, 51, 30),
          ),
          isNull,
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
      'falls back to write_date when no Follow-Up stage change exists',
      () async {
        // Chatter only shows a leave-Follow-Up row (stale); lead is in Follow-Up.
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

    test('scans past non–Follow-Up rows to find Follow-Up entry', () async {
      final messages = [
        ChatterMessageEntity(
          id: 2,
          date: DateTime.utc(2026, 8, 10, 7),
          subtypeDescription: 'Stage changed',
          trackingValues: const [
            TrackingValueEntity(
              changedField: 'Stage',
              oldValue: 'Follow-Up',
              newValue: 'New Prospects',
            ),
          ],
        ),
        ChatterMessageEntity(
          id: 1,
          date: DateTime.utc(2026, 8, 10, 6, 21),
          subtypeDescription: 'Stage changed',
          trackingValues: const [
            TrackingValueEntity(
              changedField: 'Stage',
              oldValue: 'New Prospects',
              newValue: 'Follow-Up',
            ),
          ],
        ),
      ];

      final at = await resolver.resolve(
        _FakeChatterRepository(messages),
        1,
        leadWriteDate: DateTime.utc(2026, 8, 10, 8),
      );
      expect(at, DateTime.utc(2026, 8, 10, 6, 21).toLocal());
    });
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
