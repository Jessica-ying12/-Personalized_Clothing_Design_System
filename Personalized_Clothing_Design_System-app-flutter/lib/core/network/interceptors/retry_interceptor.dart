import 'dart:async';

import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.retryDelays = const [Duration(seconds: 1), Duration(seconds: 2)],
  });

  final Dio dio;
  final int maxRetries;
  final List<Duration> retryDelays;

  static const _retryCountKey = '_retryCount';

  bool _shouldRetry(DioException err) {
    final method = err.requestOptions.method.toUpperCase();
    if (!['GET', 'PUT', 'DELETE', 'HEAD', 'OPTIONS'].contains(method)) {
      return false;
    }
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = (err.requestOptions.extra[_retryCountKey] as int?) ?? 0;

    if (!_shouldRetry(err) || retryCount >= maxRetries) {
      return handler.next(err);
    }

    final delay =
        retryCount < retryDelays.length ? retryDelays[retryCount] : retryDelays.last;
    await Future<void>.delayed(delay);

    err.requestOptions.extra[_retryCountKey] = retryCount + 1;

    try {
      final response = await dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } catch (_) {
      return handler.next(err);
    }
  }
}
