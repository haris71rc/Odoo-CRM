import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odoocrm/core/storage/secure_storage_service.dart';
import 'package:odoocrm/features/call_log/data/datasource/growth_call_log_datasource.dart';
import 'package:odoocrm/features/call_log/data/datasource/growth_call_outbox.dart';
import 'package:odoocrm/features/call_log/data/datasource/inbound_call_sync_store.dart';
import 'package:odoocrm/features/call_log/data/services/device_call_reader.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_status_option.dart';
import 'package:odoocrm/features/call_log/domain/entities/device_call_event.dart';
import 'package:odoocrm/features/call_log/domain/entities/growth_call_log_request.dart';
import 'package:odoocrm/features/call_log/domain/services/growth_call_log_service.dart';
import 'package:odoocrm/features/call_log/domain/services/inbound_call_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InboundCallSyncCursor', () {
    test('isAfterCursor uses android id tie-breaker at same timestamp', () {
      final at = DateTime.fromMillisecondsSinceEpoch(1_725_000_000_000);
      final cursor = InboundCallSyncCursor(
        lastTimestampMs: at.millisecondsSinceEpoch,
        lastAndroidCallId: '100',
        initialized: true,
      );

      expect(
        InboundCallSyncService.isAfterCursor(
          DeviceCallEvent(
            at: at,
            duration: '00:00',
            status: 'missed',
            isOutbound: false,
            isInbound: true,
            androidCallLogId: '100',
          ),
          cursor,
        ),
        isFalse,
      );
      expect(
        InboundCallSyncService.isAfterCursor(
          DeviceCallEvent(
            at: at,
            duration: '00:00',
            status: 'missed',
            isOutbound: false,
            isInbound: true,
            androidCallLogId: '101',
          ),
          cursor,
        ),
        isTrue,
      );
      expect(
        InboundCallSyncService.isAfterCursor(
          DeviceCallEvent(
            at: at.add(const Duration(seconds: 1)),
            duration: '00:05',
            status: 'picked',
            isOutbound: false,
            isInbound: true,
            androidCallLogId: '1',
          ),
          cursor,
        ),
        isTrue,
      );
    });
  });

  group('InboundCallSyncService', () {
    late FlutterSecureStorage storage;
    late SecureStorageService secureStorage;
    late InboundCallSyncStore syncStore;
    late GrowthCallOutbox outbox;
    late _FakeGrowthDatasource datasource;
    late GrowthCallLogService growth;
    late _FakeDeviceCallReader reader;
    late InboundCallSyncService sync;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      storage = const FlutterSecureStorage();
      secureStorage = SecureStorageService(storage);
      syncStore = InboundCallSyncStore(secureStorage);
      outbox = GrowthCallOutbox(secureStorage);
      datasource = _FakeGrowthDatasource();
      growth = GrowthCallLogService(
        datasource: datasource,
        secureStorage: secureStorage,
        outbox: outbox,
      );
      reader = _FakeDeviceCallReader();
      sync = InboundCallSyncService(
        deviceCallReader: reader,
        growthCallLogService: growth,
        syncStore: syncStore,
      );
    });

    tearDown(() {
      growth.dispose();
    });

    test('first run initializes forward-only and uploads nothing', () async {
      await storage.write(key: 'session_id', value: 'sess-1');
      reader.inboundEvents = [
        DeviceCallEvent(
          at: DateTime.now().subtract(const Duration(days: 2)),
          duration: '00:00',
          status: 'missed',
          isOutbound: false,
          isInbound: true,
          androidCallLogId: '1',
          phoneNumber: '919111111111',
        ),
      ];

      await sync.syncIfNeeded(salesperson: 'Haris');

      final cursor = await syncStore.load();
      expect(cursor.initialized, isTrue);
      expect(datasource.requests, isEmpty);
      expect(await outbox.loadPending(), isEmpty);
    });

    test('later run enqueues new inbound rows and advances cursor', () async {
      await storage.write(key: 'session_id', value: 'sess-1');
      await storage.write(key: 'app_tenant', value: 'digilawyer');

      final baseline = DateTime.utc(2026, 9, 11, 8, 0);
      await syncStore.save(InboundCallSyncCursor.baselineAt(baseline));

      final first = DeviceCallEvent(
        at: baseline.add(const Duration(minutes: 1)),
        duration: '00:00',
        status: 'missed',
        isOutbound: false,
        isInbound: true,
        androidCallLogId: '10',
        phoneNumber: '919111111111',
      );
      final second = DeviceCallEvent(
        at: baseline.add(const Duration(minutes: 2)),
        duration: '00:20',
        status: 'picked',
        isOutbound: false,
        isInbound: true,
        androidCallLogId: '11',
        phoneNumber: '919222222222',
      );
      reader.inboundEvents = [first, second];

      await sync.syncIfNeeded(salesperson: 'Haris');
      await growth.flushPending();

      expect(datasource.requests, hasLength(2));
      expect(datasource.requests.every((r) => r.leadId == null), isTrue);
      expect(datasource.requests.every((r) => r.direction == 'inbound'), isTrue);
      expect(datasource.requests.map((r) => r.status).toList(), [
        'dnp',
        'picked',
      ]);

      final cursor = await syncStore.load();
      expect(cursor.lastTimestampMs, second.at.millisecondsSinceEpoch);
      expect(cursor.lastAndroidCallId, '11');
    });

    test('does not re-enqueue already cursor-covered rows', () async {
      await storage.write(key: 'session_id', value: 'sess-1');
      final at = DateTime.utc(2026, 9, 11, 9, 0);
      await syncStore.save(
        InboundCallSyncCursor(
          lastTimestampMs: at.millisecondsSinceEpoch,
          lastAndroidCallId: '50',
          initialized: true,
        ),
      );
      reader.inboundEvents = [
        DeviceCallEvent(
          at: at,
          duration: '00:00',
          status: 'missed',
          isOutbound: false,
          isInbound: true,
          androidCallLogId: '50',
          phoneNumber: '919111111111',
        ),
      ];

      await sync.syncIfNeeded();
      await growth.flushPending();

      expect(datasource.requests, isEmpty);
    });
  });
}

class _FakeDeviceCallReader extends DeviceCallReader {
  _FakeDeviceCallReader() : super();

  List<DeviceCallEvent> inboundEvents = const [];

  @override
  bool get isSupported => true;

  @override
  Future<bool> ensurePermission() async => true;

  @override
  Future<List<DeviceCallEvent>> findInboundCallsSince({
    required DateTime since,
    List<CallStatusOption> statusOptions = const [],
  }) async {
    return inboundEvents
        .where((e) => !e.at.isBefore(since))
        .toList(growable: false);
  }
}

class _FakeGrowthDatasource extends GrowthCallLogDatasource {
  _FakeGrowthDatasource() : super(dio: Dio());

  final List<GrowthCallLogRequest> requests = [];

  @override
  Future<Map<String, dynamic>> logCall(GrowthCallLogRequest request) async {
    requests.add(request);
    return {'ok': true, 'duplicate': false};
  }
}
