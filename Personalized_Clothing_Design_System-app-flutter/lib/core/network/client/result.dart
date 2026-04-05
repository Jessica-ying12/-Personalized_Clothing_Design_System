import 'package:dio/dio.dart';

import 'api_exception.dart';

sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Failure<T> extends Result<T> {
  const Failure(this.exception);
  final ApiException exception;
}

Future<Result<T>> apiCall<T>(Future<T> Function() call) async {
  try {
    return Success(await call());
  } on DioException catch (e) {
    if (e.error is ApiException) {
      return Failure(e.error as ApiException);
    }
    return Failure(ApiException.fromDioException(e));
  } catch (e) {
    return Failure(ApiException.unknown(e));
  }
}
