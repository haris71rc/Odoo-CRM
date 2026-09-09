import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/storage/secure_storage_service.dart';
import 'package:odoocrm/features/call_log/data/datasource/growth_call_log_datasource.dart';
import 'package:odoocrm/features/call_log/data/datasource/growth_call_outbox.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/entities/growth_call_log_request.dart';
import 'package:odoocrm/features/call_log/domain/services/growth_call_log_service.dart';
import 'package:odoocrm/features/call_log/domain/utils/growth_call_id.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GrowthCallId', () {
    test('is stable for the same lead/direction/bucket', () {
      final at = DateTime.utc(2026, 9, 5, 14, 15, 10);
      final a = GrowthCallId.resolve(
        leadId: 62331,
        direction: 'outbound',
        callAt: at,
      );
      final b = GrowthCallId.resolve(
        leadId: 62331,
        direction: 'outbound',
        callAt: at.add(const Duration(seconds: 20)),
      );
      expect(a, b);
      expect(
        a,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
    });

    test('reuses known call_id within dedupe window across bucket edges', () {
      final firstAt = DateTime.utc(2026, 9, 5, 14, 15, 40);
      final firstId = GrowthCallId.resolve(
        leadId: 10,
        direction: 'outbound',
        callAt: firstAt,
      );
      final nearEdge = firstAt.add(const Duration(seconds: 30));
      final reused = GrowthCallId.resolve(
        leadId: 10,
        direction: 'outbound',
        callAt: nearEdge,
        known: [
          (
            leadId: 10,
            direction: 'outbound',
            callAt: firstAt,
            callId: firstId,
          ),
        ],
      );
      expect(reused, firstId);
    });
  });

  group('GrowthCallLogRequest', () {
    test('serializes required Growth API fields', () {
      final request = GrowthCallLogRequest(
        tenant: 'digilawyer',
        sessionId: 'session-abc',
        leadId: 62331,
        callId: '11111111-2222-4333-8444-555555555555',
        salesperson: 'Mohd Haris',
        callDatetime: DateTime.utc(2026, 9, 5, 14, 15),
        durationSeconds: 510,
        direction: 'outbound',
        status: 'picked',
        createdAt: DateTime.utc(2026, 9, 5, 14, 15),
      );

      expect(request.toJson(), {
        'tenant': 'digilawyer',
        'session_id': 'session-abc',
        'lead_id': 62331,
        'activity_type': 'call',
        'call_id': '11111111-2222-4333-8444-555555555555',
        'salesperson': 'Mohd Haris',
        'call_datetime': '2026-09-05T14:15:00.000Z',
        'duration_seconds': 510,
        'direction': 'outbound',
        'status': 'picked',
        'created_at': '2026-09-05T14:15:00.000Z',
      });
    });

    test('round-trips through JSON for outbox persistence', () {
      final original = GrowthCallLogRequest(
        tenant: 'botshot',
        sessionId: 's1',
        leadId: 9,
        callId: 'cid',
        callDatetime: DateTime.utc(2026, 1, 2, 3, 4, 5),
        durationSeconds: 12,
        direction: 'outbound',
        status: 'dnp',
        createdAt: DateTime.utc(2026, 1, 2, 3, 4, 6),
      );
      final restored = GrowthCallLogRequest.fromJson(original.toJson());
      expect(restored.toJson(), original.toJson());
    });
  });

  group('GrowthCallLogService', () {
    late FlutterSecureStorage storage;
    late SecureStorageService secureStorage;
    late GrowthCallOutbox outbox;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      storage = const FlutterSecureStorage();
      secureStorage = SecureStorageService(storage);
      outbox = GrowthCallOutbox(secureStorage);
    });

    GrowthCallLogService buildService(_FakeGrowthDatasource datasource) {
      return GrowthCallLogService(
        datasource: datasource,
        secureStorage: secureStorage,
        outbox: outbox,
      );
    }

    test('posts outbound call with stable call_id', () async {
      await storage.write(key: 'session_id', value: 'sess-1');
      await storage.write(key: 'app_tenant', value: 'digilawyer');
      final datasource = _FakeGrowthDatasource();
      final service = buildService(datasource);

      final at = DateTime.utc(2026, 9, 5, 14, 15);
      await service.enqueueOutboundCall(
        leadId: 62331,
        callEvent: CallLog(
          lastCallDate: at,
          duration: '08:30',
          status: 'picked',
        ),
        salesperson: 'Mohd Haris',
      );
      await service.flushPending();

      expect(datasource.requests, hasLength(1));
      final body = datasource.requests.single.toJson();
      expect(body['tenant'], 'digilawyer');
      expect(body['session_id'], 'sess-1');
      expect(body['lead_id'], 62331);
      expect(body['duration_seconds'], 510);
      expect(body['status'], 'picked');
      expect(body['call_id'], GrowthCallId.resolve(
        leadId: 62331,
        direction: 'outbound',
        callAt: at,
      ));
      expect(await outbox.loadPending(), isEmpty);
      expect(await outbox.loadAcked(), hasLength(1));
    });

    test('CRM dial + device sync reuse one call_id', () async {
      await storage.write(key: 'session_id', value: 'sess-1');
      final datasource = _FakeGrowthDatasource();
      final service = buildService(datasource);
      final dialedAt = DateTime.utc(2026, 9, 5, 14, 15, 0);
      final deviceAt = dialedAt.add(const Duration(seconds: 12));

      await service.enqueueOutboundCall(
        leadId: 42,
        callEvent: CallLog(
          lastCallDate: dialedAt,
          duration: '00:00',
          status: 'dnp',
        ),
      );
      await service.flushPending();

      await service.enqueueOutboundCall(
        leadId: 42,
        callEvent: CallLog(
          lastCallDate: deviceAt,
          duration: '01:10',
          status: 'picked',
        ),
      );
      await service.flushPending();

      // Second enqueue skipped as already-acked within dedupe window.
      expect(datasource.requests, hasLength(1));
    });

    test('persists outbox on network failure and flushes later', () async {
      await storage.write(key: 'session_id', value: 'sess-1');
      final datasource = _FakeGrowthDatasource(
        failures: [const NetworkFailure()],
      );
      final service = buildService(datasource);

      await service.enqueueOutboundCall(
        leadId: 10,
        callEvent: const CallLog(duration: '00:05', status: 'picked'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(await outbox.loadPending(), hasLength(1));
      expect(datasource.requests, hasLength(1));

      // Next drain after backoff window.
      final pending = (await outbox.loadPending()).single;
      await outbox.update(
        pending.copyWith(
          clearNextAttempt: true,
          attempts: pending.attempts,
        ),
      );
      await service.flushPending();

      expect(datasource.requests, hasLength(2));
      expect(datasource.requests[0].callId, datasource.requests[1].callId);
      expect(await outbox.loadPending(), isEmpty);
    });

    test('keeps outbox on 401 and flushes after session refresh', () async {
      await storage.write(key: 'session_id', value: 'old-sess');
      final datasource = _FakeGrowthDatasource(
        onCall: (request) async {
          if (request.sessionId == 'old-sess') {
            throw const AuthFailure('Session expired');
          }
          return {'ok': true};
        },
      );
      final service = buildService(datasource);

      await service.enqueueOutboundCall(
        leadId: 10,
        callEvent: const CallLog(duration: '00:05', status: 'dnp'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(await outbox.loadPending(), hasLength(1));

      await storage.write(key: 'session_id', value: 'new-sess');
      final pending = (await outbox.loadPending()).single;
      await outbox.update(pending.copyWith(clearNextAttempt: true));
      await service.flushPending();

      expect(datasource.requests.last.sessionId, 'new-sess');
      expect(await outbox.loadPending(), isEmpty);
    });

    test('dead-letters 422 without infinite retry', () async {
      await storage.write(key: 'session_id', value: 'sess-1');
      final datasource = _FakeGrowthDatasource(
        failures: [
          const ApiFailure('Malformed call log payload', statusCode: 422),
        ],
      );
      final service = buildService(datasource);

      await service.enqueueOutboundCall(
        leadId: 10,
        callEvent: const CallLog(duration: '00:05', status: 'picked'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(await outbox.loadPending(), isEmpty);
      final raw = await storage.read(key: AppConstants.growthCallOutboxKey);
      expect(raw, contains('dead'));
    });

    test('retries same call_id after 502 then succeeds', () async {
      await storage.write(key: 'session_id', value: 'sess-1');
      final datasource = _FakeGrowthDatasource(
        failures: [const ApiFailure('Odoo unreachable', statusCode: 502)],
      );
      final service = buildService(datasource);

      await service.enqueueOutboundCall(
        leadId: 10,
        callEvent: const CallLog(duration: '00:05', status: 'picked'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final pending = (await outbox.loadPending()).single;
      await outbox.update(pending.copyWith(clearNextAttempt: true));
      await service.flushPending();

      expect(datasource.requests, hasLength(2));
      expect(datasource.requests[0].callId, datasource.requests[1].callId);
      expect(await outbox.loadPending(), isEmpty);
    });
  });

  group('GrowthCallLogDatasource mapping', () {
    test('maps HTTP 401 to AuthFailure', () async {
      final dio = Dio()
        ..httpClientAdapter = _StatusAdapter(401, 'Session expired');
      final datasource = GrowthCallLogDatasource(dio: dio);

      await expectLater(
        datasource.logCall(
          GrowthCallLogRequest(
            tenant: 'digilawyer',
            sessionId: 'x',
            leadId: 1,
            callId: 'c',
            callDatetime: DateTime.utc(2026, 1, 1),
            durationSeconds: 0,
            direction: 'outbound',
            status: 'completed',
            createdAt: DateTime.utc(2026, 1, 1),
          ),
        ),
        throwsA(isA<AuthFailure>()),
      );
    });
  });
}

class _FakeGrowthDatasource extends GrowthCallLogDatasource {
  _FakeGrowthDatasource({
    this.failures = const [],
    this.onCall,
  }) : super(dio: Dio());

  final List<Failure> failures;
  final Future<Map<String, dynamic>> Function(GrowthCallLogRequest request)?
      onCall;
  final List<GrowthCallLogRequest> requests = [];
  var _failureIndex = 0;

  @override
  Future<Map<String, dynamic>> logCall(GrowthCallLogRequest request) async {
    requests.add(request);
    if (onCall != null) return onCall!(request);
    if (_failureIndex < failures.length) {
      throw failures[_failureIndex++];
    }
    return {'ok': true, 'duplicate': false};
  }
}

class _StatusAdapter implements HttpClientAdapter {
  _StatusAdapter(this.statusCode, this.detail);

  final int statusCode;
  final String detail;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"detail":"$detail"}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
