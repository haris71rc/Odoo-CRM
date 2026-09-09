import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:odoocrm/core/constants/growth_api_constants.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/features/call_log/domain/entities/growth_call_log_request.dart';

/// HTTP client for the Growth call-log API (separate host from Odoo).
class GrowthCallLogDatasource {
  GrowthCallLogDatasource({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: GrowthApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 20),
                sendTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                headers: const {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    if (kDebugMode && dio == null) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) {
            assert(() {
              // ignore: avoid_print
              print(obj);
              return true;
            }());
          },
        ),
      );
    }
  }

  final Dio _dio;

  /// Posts a call log. Throws [Failure] on non-success responses.
  Future<Map<String, dynamic>> logCall(GrowthCallLogRequest request) async {
    try {
      final response = await _dio.post<dynamic>(
        GrowthApiConstants.callsLogPath,
        data: request.toJson(),
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300) {
        final data = response.data;
        if (data is Map<String, dynamic>) return data;
        if (data is Map) return Map<String, dynamic>.from(data);
        return const <String, dynamic>{};
      }

      throw _failureForStatus(statusCode, response.data);
    } on Failure {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnexpectedFailure(e.toString());
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
        final statusCode = e.response?.statusCode;
        return _failureForStatus(statusCode, e.response?.data);
      case DioExceptionType.cancel:
        return const UnexpectedFailure('Growth API request cancelled');
      default:
        return UnexpectedFailure(e.message ?? 'Growth API request failed');
    }
  }

  Failure _failureForStatus(int? statusCode, dynamic data) {
    final message = _extractMessage(data) ??
        switch (statusCode) {
          401 => 'Session expired',
          403 => 'Forbidden',
          404 => 'Lead or tenant not found',
          408 => 'Request timeout',
          422 => 'Malformed call log payload',
          429 => 'Too many requests',
          500 => 'Internal server error',
          502 => 'Odoo unreachable',
          503 => 'Service unavailable',
          504 => 'Gateway timeout',
          _ =>
            'Growth API request failed${statusCode != null ? ' ($statusCode)' : ''}',
        };

    if (statusCode == 401) {
      return AuthFailure(message);
    }
    return ApiFailure(message, statusCode: statusCode);
  }

  String? _extractMessage(dynamic data) {
    if (data is Map) {
      final detail = data['detail'] ?? data['message'] ?? data['error'];
      if (detail is String && detail.trim().isNotEmpty) return detail;
      if (detail is List && detail.isNotEmpty) {
        return detail.first.toString();
      }
      if (detail is Map && detail['message'] != null) {
        return detail['message'].toString();
      }
    }
    if (data is String && data.trim().isNotEmpty) return data;
    return null;
  }
}
