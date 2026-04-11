import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message = '网络请求失败';

    if (err.response != null) {
      final data = err.response?.data;
      if (data is Map && data.containsKey('error')) {
        message = data['error'] as String;
      } else {
        switch (err.response?.statusCode) {
          case 400:
            message = '请求参数错误';
            break;
          case 401:
            message = '未授权，请重新登录';
            break;
          case 404:
            message = '请求的资源不存在';
            break;
          case 422:
            message = '请求参数验证失败';
            break;
          case 500:
            message = '服务器错误';
            break;
        }
      }
    } else if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      message = '连接超时';
    } else if (err.type == DioExceptionType.connectionError) {
      message = '网络连接失败';
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
