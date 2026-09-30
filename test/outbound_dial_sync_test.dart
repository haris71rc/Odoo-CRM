import 'package:flutter_test/flutter_test.dart';
import 'package:odoocrm/features/call_log/data/datasource/pending_outbound_dial_store.dart';
import 'package:odoocrm/features/call_log/data/services/device_call_reader.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_status_option.dart';
import 'package:odoocrm/features/call_log/domain/entities/pending_outbound_dial.dart';
import 'package:odoocrm/features/call_log/domain/services/outbound_dial_sync_service.dart';
import 'package:odoocrm/features/call_log/domain/utils/outbound_dial_sync_policy.dart';

void main() {
  group('OutboundDialSyncPolicy', () {
    test('defers only during the dialer-launch flicker', () {
      final dialedAt = DateTime(2026, 9, 30, 12);
      expect(
        OutboundDialSyncPolicy.shouldDefer(
          dialedAt,
          dialedAt.add(const Duration(seconds: 2)),
        ),
        isTrue,
      );
      expect(
        OutboundDialSyncPolicy.shouldDefer(
          dialedAt,
          dialedAt.add(const Duration(minutes: 8)),
        ),
        isFalse,
      );
    });

    test('keeps watching a placeholder duration well after the call', () {
      final dialedAt = DateTime(2026, 9, 30, 12);
      expect(
        OutboundDialSyncPolicy.shouldKeepWatchingDuration(
          dialedAt,
          dialedAt.add(const Duration(minutes: 12)),
        ),
        isTrue,
      );
      expect(
        OutboundDialSyncPolicy.shouldKeepWatchingDuration(
          dialedAt,
          dialedAt.add(const Duration(minutes: 21)),
        ),
        isFalse,
      );
    });
  });

  group('OutboundDialSyncService', () {
    late _MemoryDialStore store;
    late _FakeReader reader;
    late List<OutboundPersistRequest> saved;
    var resumed = false;

    late OutboundDialSyncService service;

    setUp(() {
      store = _MemoryDialStore();
      reader = _FakeReader();
      saved = [];
      resumed = false;
      service = OutboundDialSyncService(
        store: store,
        reader: reader,
        isResumed: () => resumed,
        statusOptions: (_) async => const <CallStatusOption>[],
        persist: (request) async {
          saved.add(request);
          return const OutboundPersistResult(saved: true, message: 'saved');
        },
      );
    });

    tearDown(() => service.dispose());

    test('a late return still saves the finished call', () async {
      final dialedAt = DateTime.now().subtract(const Duration(minutes: 11));
      reader.next = CallLog(
        lastCallDate: dialedAt,
        duration: '04:12',
        status: 'picked',
      );

      await service.begin(leadId: 7, phone: '9876543210', dialedAt: dialedAt);
      resumed = true;
      await service.syncIfForeground();

      expect(saved, hasLength(1));
      expect(saved.single.callLog.duration, '04:12');
      expect(saved.single.leadId, 7);
      expect(service.pending.value, isNull);
      expect(await store.load(), isNull);
    });

    test('staying in the background does not drop or save the dial', () async {
      final dialedAt = DateTime.now().subtract(const Duration(minutes: 11));
      reader.next = CallLog(
        lastCallDate: dialedAt,
        duration: '04:12',
        status: 'picked',
      );

      await service.begin(leadId: 7, phone: '9876543210', dialedAt: dialedAt);
      resumed = false;
      await service.syncIfForeground();

      expect(saved, isEmpty);
      expect(service.pending.value?.leadId, 7);
      expect(await store.load(), isNotNull);
    });

    test('leaving the app cancels a foreground retry instead of giving up',
        () async {
      final dialedAt = DateTime.now().subtract(const Duration(minutes: 5));
      reader.next = null;

      await service.begin(leadId: 3, phone: '9876543210', dialedAt: dialedAt);
      resumed = true;
      await service.syncIfForeground();
      service.onLifecycle(resumed: false);

      expect(service.promptLeadId.value, isNull);
      expect(service.pending.value?.leadId, 3);

      reader.next = CallLog(
        lastCallDate: dialedAt,
        duration: '01:05',
        status: 'picked',
      );
      resumed = true;
      await service.syncIfForeground();

      expect(saved, hasLength(1));
      expect(saved.single.callLog.duration, '01:05');
    });
  });
}

class _MemoryDialStore implements PendingOutboundDialStore {
  PendingOutboundDial? _dial;

  @override
  Future<void> clear() async => _dial = null;

  @override
  Future<PendingOutboundDial?> load() async => _dial;

  @override
  Future<void> save(PendingOutboundDial dial) async => _dial = dial;
}

class _FakeReader extends DeviceCallReader {
  CallLog? next;

  @override
  bool get isSupported => true;

  @override
  Future<bool> ensurePermission() async => true;

  @override
  Future<CallLog?> findRecentCall({
    required String phone,
    required DateTime dialedAt,
    List<CallStatusOption> statusOptions = const [],
    int maxAttempts = 8,
  }) async {
    return next;
  }
}
