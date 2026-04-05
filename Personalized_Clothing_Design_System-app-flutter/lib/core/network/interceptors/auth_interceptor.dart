import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthInterceptor extends QueuedInterceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    try {
      final session = await Supabase.instance.client.auth.refreshSession();
      final token = session.session?.accessToken;
      if (token == null) return handler.next(err);

      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $token';
      final response = await Dio().fetch(options);
      return handler.resolve(response);
    } catch (_) {
      return handler.next(err);
    }
  }
}
