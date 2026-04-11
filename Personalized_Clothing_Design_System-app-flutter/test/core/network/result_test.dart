import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:personalized_clothing_design_system/core/network/client/api_exception.dart';
import 'package:personalized_clothing_design_system/core/network/client/result.dart';

void main() {
  group('Result', () {
    test('Success 应持有数�?, () {
      const result = Success(42);
      expect(result.data, 42);
      expect(result, isA<Result<int>>());
    });

    test('Failure 应持有异�?, () {
      const result = Failure<int>(ApiException.timeout);
      expect(result.exception.code, -1);
      expect(result, isA<Result<int>>());
    });
  });

  group('apiCall', () {
    test('正常调用应返�?Success', () async {
      final result = await apiCall(() async => 'hello');

      expect(result, isA<Success<String>>());
      expect((result as Success<String>).data, 'hello');
    });

    test('DioException (�?ApiException) 应返�?Failure', () async {
      final result = await apiCall<String>(() async {
        throw DioException(
          type: DioExceptionType.unknown,
          requestOptions: RequestOptions(),
          error: const ApiException(code: 42, message: 'custom'),
        );
      });

      expect(result, isA<Failure<String>>());
      expect((result as Failure<String>).exception.code, 42);
    });

    test('DioException (�?ApiException) 应通过 fromDioException 转换', () async {
      final result = await apiCall<String>(() async {
        throw DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(),
        );
      });

      expect(result, isA<Failure<String>>());
      expect((result as Failure<String>).exception.code, -1);
    });

    test('�?DioException 应返�?unknown Failure', () async {
      final result = await apiCall<String>(() async {
        throw Exception('boom');
      });

      expect(result, isA<Failure<String>>());
      expect((result as Failure<String>).exception.code, -999);
    });
  });

  group('Result pattern matching', () {
    test('switch 应能匹配 Success �?Failure', () {
      const Result<int> success = Success(1);
      const Result<int> failure = Failure(ApiException.timeout);

      String matchResult(Result<int> r) => switch (r) {
            Success(:final data) => 'ok:$data',
            Failure(:final exception) => 'err:${exception.code}',
          };

      expect(matchResult(success), 'ok:1');
      expect(matchResult(failure), 'err:-1');
    });
  });
}
