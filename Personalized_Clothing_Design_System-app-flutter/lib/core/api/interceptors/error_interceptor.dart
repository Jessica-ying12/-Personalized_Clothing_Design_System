import 'package:dio/dio.dart';

import '../../storage/secure_storage.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message = '网络请求失败';

    if (err.response != null) {
      final data = err.response?.data;
      // FastAPI 标准错误格式：{ "detail": "..." }
      // 兼容旧格式：{ "error": "..." }
      if (data is Map) {
        if (data.containsKey('detail')) {
          final detail = data['detail'];
          message = detail is String ? detail : detail.toString();
        } else if (data.containsKey('error')) {
          message = data['error'] as String;
        }
      }

      switch (err.response?.statusCode) {
        case 400:
          if (message == '网络请求失败') message = '请求参数错误';
        case 401:
          // 清除本地 token，触发重新登录
          SecureStorage.clear();
          message = '登录已过期，请重新登录';
        case 404:
          if (message == '网络请求失败') message = '请求的资源不存在';
        case 422:
          if (message == '网络请求失败') message = '请求参数验证失败';
        case 500:
          if (message == '网络请求失败') message = '服务器错误，请稍后重试';
      }
    } else if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      message = '连接超时，请检查网络';
    } else if (err.type == DioExceptionType.connectionError) {
      message = '无法连接到服务器，请检查网络';
    }

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: message,
      ),
    );
  }
}
