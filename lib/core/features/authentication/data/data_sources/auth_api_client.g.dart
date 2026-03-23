// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_api_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _AuthApiClient implements AuthApiClient {
  _AuthApiClient(this._dio, {String? baseUrl}) {
    if (baseUrl != null) {
      _dio.options.baseUrl = baseUrl;
    }
  }

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'POST').compose(_dio.options, '/users/login', data: body),
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'POST')
          .compose(_dio.options, '/users/create', data: body),
    );
    return response.data!;
  }
}
