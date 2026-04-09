// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_api_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _UsersApiClient implements UsersApiClient {
  _UsersApiClient(this._dio, {String? baseUrl}) {
    if (baseUrl != null) _dio.options.baseUrl = baseUrl;
  }

  final Dio _dio;

  @override
  Future<List<dynamic>> getAllUsers() async {
    final response = await _dio.fetch<List<dynamic>>(
      Options(method: 'GET').compose(_dio.options, '/users/'),
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> getAllUsersWithPreferences() async {
    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'GET').compose(_dio.options, '/users/preferences'),
    );
    return response.data!;
  }

  @override
  Future<void> deleteUser(String userId) async {
    await _dio.fetch<dynamic>(
      Options(method: 'DELETE').compose(_dio.options, '/users/$userId'),
    );
  }
}
