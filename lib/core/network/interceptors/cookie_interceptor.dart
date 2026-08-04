import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/constants/app_environment.dart';

class CookieInterceptor extends QueuedInterceptor {
  CookieInterceptor(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final sessionId = await _secureStorage.read(
      key: AppConstants.sessionIdKey,
    );
    if (sessionId != null && sessionId.isNotEmpty) {
      final cookieParts = <String>['session_id=$sessionId'];
      final companyIds = AppEnvironment.allowedCompanyIds;
      if (companyIds.isNotEmpty) {
        cookieParts.add('cids=${companyIds.join(',')}');
      }
      options.headers['Cookie'] = cookieParts.join('; ');
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    await _captureSessionCookie(response);
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response != null) {
      await _captureSessionCookie(err.response!);
    }
    handler.next(err);
  }

  Future<void> _captureSessionCookie(Response response) async {
    final setCookieHeaders = response.headers['set-cookie'];
    if (setCookieHeaders == null || setCookieHeaders.isEmpty) return;

    for (final header in setCookieHeaders) {
      final sessionId = _extractSessionId(header);
      if (sessionId != null) {
        await _secureStorage.write(
          key: AppConstants.sessionIdKey,
          value: sessionId,
        );
        break;
      }
    }
  }

  String? _extractSessionId(String cookieHeader) {
    final parts = cookieHeader.split(';');
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.startsWith('session_id=')) {
        final value = trimmed.substring('session_id='.length);
        if (value.isNotEmpty) return value;
      }
    }
    return null;
  }
}
