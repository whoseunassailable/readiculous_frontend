// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genres_api_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _GenresApiClient implements GenresApiClient {
  _GenresApiClient(this._dio, {String? baseUrl}) {
    if (baseUrl != null) _dio.options.baseUrl = baseUrl;
  }

  final Dio _dio;

  @override
  Future<List<dynamic>> getAllGenres() async {
    final response = await _dio.fetch<List<dynamic>>(
      Options(method: 'GET').compose(_dio.options, '/genres/'),
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> createGenre(Map<String, dynamic> body) async {
    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'POST').compose(_dio.options, '/genres/', data: body),
    );
    return response.data!;
  }

  @override
  Future<void> deleteGenre(String genreId) async {
    await _dio.fetch<dynamic>(
      Options(method: 'DELETE').compose(_dio.options, '/genres/$genreId'),
    );
  }
}
