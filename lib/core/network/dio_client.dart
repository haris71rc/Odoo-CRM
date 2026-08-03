import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/network/interceptors/cookie_interceptor.dart';
import 'package:odoocrm/core/network/json_rpc_request.dart';

class DioClient {
  DioClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      CookieInterceptor(_secureStorage),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) {
          // Keep logs concise in production builds.
          assert(() {
            // ignore: avoid_print
            print(obj);
            return true;
          }());
        },
      ),
    ]);
  }

  final FlutterSecureStorage _secureStorage;
  late final Dio _dio;

  Dio get dio => _dio;

  Future<Map<String, dynamic>> postJsonRpc(
    String path,
    JsonRpcRequest request,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: request.toJson(),
      );

      final data = response.data;
      if (data == null) {
        throw const ParsingFailure('Empty response from server');
      }

      if (data.containsKey('error')) {
        final error = data['error'];
        final message = _extractErrorMessage(error);
        throw ApiFailure(message, statusCode: response.statusCode);
      }

      return data;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Failure _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final message = e.response?.data is Map
            ? _extractErrorMessage(e.response?.data['error'])
            : (e.message ?? 'Server error');
        return ApiFailure(message, statusCode: e.response?.statusCode);
      default:
        return UnexpectedFailure(e.message ?? 'Unexpected network error');
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is Map) {
      final data = error['data'];
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (error['message'] != null) {
        return error['message'].toString();
      }
    }
    return 'API request failed';
  }
}
