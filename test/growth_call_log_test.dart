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
import 'package:odoocrm/features/call_log/domain/utils/growth_call_retry_policy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GrowthCallRetryPolicy', () {
    test('marks expected HTTP statuses as retryable', () {
      for (final code in [408, 429, 500, 502, 503, 504]) {
        expect(GrowthCallRetryPolicy.isRetryableStatus(code), isTrue);
      }
    });

    test('marks client errors as non-retryable', () {
      for (final code in [400, 403, 404, 405, 409, 422]) {
        expect(GrowthCallRetryPolicy.isRetryableStatus(code), isFalse);
        expect(
          GrowthCallRetryPolicy.nonRetryableStatusCodes.contains(code),
          isTrue,
        );
      }
    });
  });

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
    late List<GrowthCallLogService> services;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      storage = const FlutterSecureStorage();
      secureStorage = SecureStorageService(storage);
      outbox = GrowthCallOutbox(secureStorage);
      services = <GrowthCallLogService>[];
    });

    tearDown(() {
      for (final service in services) {
        service.dispose();
      }
    });

    GrowthCallLogService buildService(_FakeGrowthDatasource datasource) {
      final service = GrowthCallLogService(
        datasource: datasource,
        secureStorage: secureStorage,
        outbox: outbox,
      );
      services.add(service);
      return service;
    }

    Future<void> clearBackoff() async {
      final pending = await outbox.loadPending();
      for (final item in pending) {
        await outbox.update(item.copyWith(clearNextAttempt: true));
      }
    }

    Future<void> settle() => Future<void>.delayed(
          const Duration(milliseconds: 80),
        );

    test('POST success leaves queue empty', () async {
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
      expect(
        body['call_id'],
        GrowthCallId.resolve(
          leadId: 62331,
          direction: 'outbound',
          callAt: at,
        ),
      );
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
      await settle();

      expect(await outbox.loadPending(), hasLength(1));
      expect(datasource.requests, hasLength(1));

      await clearBackoff();
      await service.flushPending();

      expect(datasource.requests, hasLength(2));
      expect(datasource.requests[0].callId, datasource.requests[1].callId);
      expect(await outbox.loadPending(), isEmpty);
    });

    test('persists outbox on timeout-style network failure', () async {
      await storage.write(key: 'session_id', value: 'sess-1');
      final datasource = _FakeGrowthDatasource(
        failures: [const NetworkFailure('Connection timeout')],
      );
      final service = buildService(datasource);

      await service.enqueueOutboundCall(
        leadId: 11,
        callEvent: const CallLog(duration: '00:05', status: 'picked'),
      );
      await settle();

      expect(await outbox.loadPending(), hasLength(1));
      expect((await outbox.loadPending()).single.status, GrowthOutboxStatus.failed);
    });

    for (final code in [408, 429, 500, 502, 503, 504]) {
      test('persists outbox on HTTP $code', () async {
        await storage.write(key: 'session_id', value: 'sess-1');
        final datasource = _FakeGrowthDatasource(
          failures: [ApiFailure('transient', statusCode: code)],
        );
        final service = buildService(datasource);

        await service.enqueueOutboundCall(
          leadId: 20 + code,
          callEvent: const CallLog(duration: '00:05', status: 'picked'),
        );
        await settle();

        expect(await outbox.loadPending(), hasLength(1));
        final raw = await storage.read(key: AppConstants.growthCallOutboxKey);
        expect(raw, isNot(contains('"dead_letter":true')));
      });
    }

    test('does not queue 400 into retryable pending', () async {
      await storage.write(key: 'session_id', value: 'sess-1');
      final datasource = _FakeGrowthDatasource(
        failures: [const ApiFailure('Bad request', statusCode: 400)],
      );
      final service = buildService(datasource);

      await service.enqueueOutboundCall(
        leadId: 10,
        callEvent: const CallLog(duration: '00:05', status: 'picked'),
      );
      await settle();

      expect(await outbox.loadPending(), isEmpty);
      final raw = await storage.read(key: AppConstants.growthCallOutboxKey);
      expect(raw, contains('dead'));
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
      await settle();
      expect(await outbox.loadPending(), hasLength(1));

      await storage.write(key: 'session_id', value: 'new-sess');
      await clearBackoff();
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
      await settle();

      expect(await outbox.loadPending(), isEmpty);
      final raw = await storage.read(key: AppConstants.growthCallOutboxKey);
      expect(raw, contains('dead'));
    });

    test('retries same call_id after 503 then succeeds', () async {
      await storage.write(key: 'session_id', value: 'sess-1');
      final datasource = _FakeGrowthDatasource(
        failures: [const ApiFailure('Service unavailable', statusCode: 503)],
      );
      final service = buildService(datasource);

      await service.enqueueOutboundCall(
        leadId: 10,
        callEvent: const CallLog(duration: '00:05', status: 'picked'),
      );
      await settle();

      expect(await outbox.loadPending(), hasLength(1));
      await clearBackoff();
      await service.flushPending();

      expect(datasource.requests, hasLength(2));
      expect(datasource.requests[0].callId, datasource.requests[1].callId);
      expect(await outbox.loadPending(), isEmpty);
    });

    test('retry failure keeps item persisted', () async {
      await storage.write(key: 'session_id', value: 'sess-1');
      final datasource = _FakeGrowthDatasource(
        failures: [
          const ApiFailure('Service unavailable', statusCode: 503),
          const ApiFailure('Service unavailable', statusCode: 503),
        ],
      );
      final service = buildService(datasource);

      await service.enqueueOutboundCall(
        leadId: 10,
        callEvent: const CallLog(duration: '00:05', status: 'picked'),
      );
      await settle();
      await clearBackoff();
      await service.flushPending();
      await settle();

      expect(await outbox.loadPending(), hasLength(1));
      expect((await outbox.loadPending()).single.attempts, greaterThanOrEqualTo(2));
    });

    test('survives app restart via durable storage', () async {
      await storage.write(key: 'session_id', value: 'sess-1');
      final failing = _FakeGrowthDatasource(
        failures: [const NetworkFailure()],
      );
      final first = buildService(failing);

      await first.enqueueOutboundCall(
        leadId: 77,
        callEvent: const CallLog(duration: '00:05', status: 'picked'),
      );
      await settle();
      expect(await outbox.loadPending(), hasLength(1));
      final callId = (await outbox.loadPending()).single.callId;

      // Simulate cold start: new service + outbox over same secure storage.
      final outbox2 = GrowthCallOutbox(secureStorage);
      final datasource2 = _FakeGrowthDatasource();
      final restarted = GrowthCallLogService(
        datasource: datasource2,
        secureStorage: secureStorage,
        outbox: outbox2,
      );
      services.add(restarted);

      final restored = await outbox2.loadPending();
      expect(restored, hasLength(1));
      expect(restored.single.callId, callId);

      await outbox2.update(restored.single.copyWith(clearNextAttempt: true));
      await restarted.flushPending();

      expect(datasource2.requests, hasLength(1));
      expect(datasource2.requests.single.callId, callId);
      expect(await outbox2.loadPending(), isEmpty);
    });

    test('one failed item does not delete other pending items', () async {
      await storage.write(key: 'session_id', value: 'sess-1');
      final datasource = _FakeGrowthDatasource(
        onCall: (request) async {
          if (request.leadId == 2) {
            throw const ApiFailure('bad', statusCode: 400);
          }
          return {'ok': true};
        },
      );
      final service = buildService(datasource);

      // Seed three distinct pending rows with different call times / leads.
      final base = DateTime.utc(2026, 9, 5, 10);
      for (var i = 1; i <= 3; i++) {
        await outbox.upsert(
          GrowthOutboxItem(
            request: GrowthCallLogRequest(
              tenant: 'digilawyer',
              sessionId: 'sess-1',
              leadId: i,
              callId: 'call-$i',
              callDatetime: base.add(Duration(hours: i)),
              durationSeconds: 5,
              direction: 'outbound',
              status: 'picked',
              createdAt: base,
            ),
            attempts: 0,
            enqueuedAt: base,
          ),
        );
      }

      await service.flushPending();
      await settle();

      // lead 2 dead-lettered; 1 and 3 acked.
      expect(await outbox.loadPending(), isEmpty);
      expect(await outbox.loadAcked(), hasLength(2));
      final raw = await storage.read(key: AppConstants.growthCallOutboxKey);
      expect(raw, contains('call-2'));
      expect(raw, contains('dead'));
    });

    test('network failure short-circuits remaining queue items', () async {
      await storage.write(key: 'session_id', value: 'sess-1');
      var calls = 0;
      final datasource = _FakeGrowthDatasource(
        onCall: (request) async {
          calls++;
          throw const NetworkFailure();
        },
      );
      final service = buildService(datasource);
      final base = DateTime.utc(2026, 9, 5, 12);

      for (var i = 1; i <= 3; i++) {
        await outbox.upsert(
          GrowthOutboxItem(
            request: GrowthCallLogRequest(
              tenant: 'digilawyer',
              sessionId: 'sess-1',
              leadId: i,
              callId: 'net-$i',
              callDatetime: base.add(Duration(minutes: i)),
              durationSeconds: 1,
              direction: 'outbound',
              status: 'picked',
              createdAt: base,
            ),
            attempts: 0,
            enqueuedAt: base,
          ),
        );
      }

      await service.flushPending();
      await settle();

      expect(calls, 1);
      expect(await outbox.loadPending(), hasLength(3));
    });

    test('concurrent flushPending coalesces to one drain', () async {
      await storage.write(key: 'session_id', value: 'sess-1');
      var inFlight = 0;
      var maxInFlight = 0;
      final datasource = _FakeGrowthDatasource(
        onCall: (request) async {
          inFlight++;
          if (inFlight > maxInFlight) maxInFlight = inFlight;
          await Future<void>.delayed(const Duration(milliseconds: 40));
          inFlight--;
          return {'ok': true};
        },
      );
      final service = buildService(datasource);
      final base = DateTime.utc(2026, 9, 5, 13);

      await outbox.upsert(
        GrowthOutboxItem(
          request: GrowthCallLogRequest(
            tenant: 'digilawyer',
            sessionId: 'sess-1',
            leadId: 1,
            callId: 'concurrent-1',
            callDatetime: base,
            durationSeconds: 1,
            direction: 'outbound',
            status: 'picked',
            createdAt: base,
          ),
          attempts: 0,
          enqueuedAt: base,
        ),
      );

      await Future.wait([
        service.flushPending(),
        service.flushPending(),
        service.flushPending(),
      ]);

      expect(datasource.requests, hasLength(1));
      expect(maxInFlight, 1);
      expect(await outbox.loadPending(), isEmpty);
    });

    test('high attempt count keeps retryable item in pending', () async {
      await storage.write(key: 'session_id', value: 'sess-1');
      final datasource = _FakeGrowthDatasource(
        failures: [const ApiFailure('down', statusCode: 503)],
      );
      final service = buildService(datasource);
      final base = DateTime.utc(2026, 9, 5, 14);

      await outbox.upsert(
        GrowthOutboxItem(
          request: GrowthCallLogRequest(
            tenant: 'digilawyer',
            sessionId: 'sess-1',
            leadId: 9,
            callId: 'many-attempts',
            callDatetime: base,
            durationSeconds: 1,
            direction: 'outbound',
            status: 'picked',
            createdAt: base,
          ),
          attempts: 20,
          enqueuedAt: base,
        ),
      );

      await service.flushPending();
      await settle();

      final pending = await outbox.loadPending();
      expect(pending, hasLength(1));
      expect(pending.single.callId, 'many-attempts');
      expect(pending.single.deadLetter, isFalse);
      expect(pending.single.attempts, 21);
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

    test('maps HTTP 503 to ApiFailure with status', () async {
      final dio = Dio()
        ..httpClientAdapter = _StatusAdapter(503, 'Service unavailable');
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
        throwsA(
          isA<ApiFailure>().having((e) => e.statusCode, 'statusCode', 503),
        ),
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
