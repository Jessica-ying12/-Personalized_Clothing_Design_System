import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:livhome/core/network/client/api_exception.dart';

void main() {
  group('ApiException', () {
    test('常量实例应有正确的 code 和 message', () {
      expect(ApiException.timeout.code, -1);
      expect(ApiException.noNetwork.code, -2);
      expect(ApiException.unauthorized.code, 401);
    });

    test('unknown 应包装原始错误', () {
      final original = Exception('boom');
      final e = ApiException.unknown(original);

      expect(e.code, -999);
      expect(e.message, 'Unknown error');
      expect(e.originalError, original);
    });

    test('toString 应包含 code 和 message', () {
      const e = ApiException(code: 500, message: 'Server error');
      expect(e.toString(), 'ApiException(code: 500, message: Server error)');
    });

    group('fromDioException', () {
      test('connectionTimeout → timeout', () {
        final dio = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(),
        );
        final e = ApiException.fromDioException(dio);
        expect(e.code, -1);
      });

      test('sendTimeout → timeout', () {
        final dio = DioException(
          type: DioExceptionType.sendTimeout,
          requestOptions: RequestOptions(),
        );
        expect(ApiException.fromDioException(dio).code, -1);
      });

      test('receiveTimeout → timeout', () {
        final dio = DioException(
          type: DioExceptionType.receiveTimeout,
          requestOptions: RequestOptions(),
        );
        expect(ApiException.fromDioException(dio).code, -1);
      });

      test('connectionError → noNetwork', () {
        final dio = DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(),
        );
        expect(ApiException.fromDioException(dio).code, -2);
      });

      test('badResponse → 应提取 statusCode', () {
        final dio = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(),
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 404,
            statusMessage: 'Not Found',
          ),
        );
        final e = ApiException.fromDioException(dio);
        expect(e.code, 404);
        expect(e.message, 'Not Found');
      });

      test('cancel → code -3', () {
        final dio = DioException(
          type: DioExceptionType.cancel,
          requestOptions: RequestOptions(),
        );
        expect(ApiException.fromDioException(dio).code, -3);
      });

      test('unknown type → code -999', () {
        final dio = DioException(
          type: DioExceptionType.unknown,
          requestOptions: RequestOptions(),
        );
        expect(ApiException.fromDioException(dio).code, -999);
      });
    });
  });
}
