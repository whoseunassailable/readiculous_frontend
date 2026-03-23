// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_genres_api_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _UserGenresApiClient implements UserGenresApiClient {
  _UserGenresApiClient(this._dio, {String? baseUrl}) {
    if (baseUrl != null) _dio.options.baseUrl = baseUrl;
  }

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> addUserGenrePreferences(
      Map<String, dynamic> body) async {
    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'POST').compose(_dio.options, '/user-genres/', data: body),
    );
    return response.data!;
  }

  @override
  Future<List<dynamic>> getUserGenrePreferences(String userId) async {
    final response = await _dio.fetch<List<dynamic>>(
      Options(method: 'GET').compose(_dio.options, '/user-genres/$userId'),
    );
    return response.data!;
  }

  @override
  Future<void> removeUserGenrePreference(String userId, String genreId) async {
    await _dio.fetch<dynamic>(
      Options(method: 'DELETE')
          .compose(_dio.options, '/user-genres/$userId/$genreId'),
    );
  }
}
