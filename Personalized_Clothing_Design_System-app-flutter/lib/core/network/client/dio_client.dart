import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/flavors.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/error_interceptor.dart';
import '../interceptors/log_interceptor.dart';
import '../interceptors/retry_interceptor.dart';

Dio createDio() {
  final dio = Dio(BaseOptions(
    baseUrl: F.apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
  ));

  // 执行链: Retry → Auth → Log → [请求] → Error
  dio.interceptors.addAll([
    RetryInterceptor(dio: dio),
    AuthInterceptor(),
    AppLogInterceptor(),
    ErrorInterceptor(),
  ]);

  return dio;
}

CancelToken createCancelToken() => CancelToken();

final dioProvider = Provider<Dio>((ref) => createDio());
