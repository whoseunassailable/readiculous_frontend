import 'api_error.dart';

class ApiResult<T> {
  final T? data;
  final ApiError? error;

  const ApiResult._({this.data, this.error});

  factory ApiResult.success(T data) {
    return ApiResult._(data: data);
  }

  factory ApiResult.failure(ApiError error) {
    return ApiResult._(error: error);
  }

  bool get isSuccess => data != null && error == null;
  bool get isFailure => error != null;
}
