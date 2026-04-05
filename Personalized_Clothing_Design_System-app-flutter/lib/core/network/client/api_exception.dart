import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.originalError,
  });

  final int code;
  final String message;
  final dynamic originalError;

  static const timeout = ApiException(code: -1, message: 'Connection timeout');
  static const noNetwork = ApiException(code: -2, message: 'No network connection');
  static const unauthorized = ApiException(code: 401, message: 'Unauthorized');

  static ApiException unknown([dynamic error]) =>
      ApiException(code: -999, message: 'Unknown error', originalError: error);

  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return timeout;
      case DioExceptionType.connectionError:
        return noNetwork;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? -1;
        final msg = e.response?.statusMessage ?? 'Bad response';
        return ApiException(code: statusCode, message: msg, originalError: e);
      case DioExceptionType.cancel:
        return const ApiException(code: -3, message: 'Request cancelled');
      default:
        return unknown(e);
    }
  }

  @override
  String toString() => 'ApiException(code: $code, message: $message)';
}
