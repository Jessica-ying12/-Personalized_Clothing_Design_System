import 'package:dio/dio.dart';

import '../../storage/secure_storage.dart';

/// 认证拦截器：从本地安全存储读取 JWT Token，注入到请求头
/// 使用 QueuedInterceptor 避免并发请求时的 token 读取竞争
class AuthInterceptor extends QueuedInterceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
