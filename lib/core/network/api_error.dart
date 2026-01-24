import 'package:dio/dio.dart';

class ApiError {
  final int? statusCode;
  final String message;
  final dynamic details;

  const ApiError({
    this.statusCode,
    required this.message,
    this.details,
  });

  /// Converts DioException into ApiError
  factory ApiError.fromDio(DioException e) {
    // Server responded with error status
    if (e.response != null) {
      final status = e.response?.statusCode;
      final data = e.response?.data;

      String msg = 'Something went wrong';
      if (data is Map) {
        msg = data['message'] ?? data['error'] ?? data['detail'] ?? msg;
      }

      return ApiError(
        statusCode: status,
        message: msg.toString(),
        details: data,
      );
    }

    // No response from server
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiError(message: 'Request timed out');

      case DioExceptionType.connectionError:
        return const ApiError(message: 'No internet connection');

      case DioExceptionType.cancel:
        return const ApiError(message: 'Request was cancelled');

      case DioExceptionType.badCertificate:
        return const ApiError(message: 'Bad SSL certificate');

      default:
        return ApiError(message: e.message ?? 'Unexpected error');
    }
  }
}
