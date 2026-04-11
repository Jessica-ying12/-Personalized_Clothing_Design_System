import 'package:dio/dio.dart';

import '../../../app/flavors.dart';
import '../../../logger/logger.dart';

class AppLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (F.enableLog) {
      Log.d('[HTTP] â†?${options.method} ${options.uri}');
      if (options.data != null) Log.d('[HTTP] Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (F.enableLog) {
      Log.d('[HTTP] â†?${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (F.enableLog) {
      Log.e('[HTTP] âœ?${err.requestOptions.uri} ${err.message}');
    }
    handler.next(err);
  }
}
