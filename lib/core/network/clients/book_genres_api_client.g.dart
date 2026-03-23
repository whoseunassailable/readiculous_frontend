// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_genres_api_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _BookGenresApiClient implements BookGenresApiClient {
  _BookGenresApiClient(this._dio, {String? baseUrl}) {
    if (baseUrl != null) _dio.options.baseUrl = baseUrl;
  }

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> assignGenresToBook(
      Map<String, dynamic> body) async {
    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'POST').compose(_dio.options, '/book-genres/', data: body),
    );
    return response.data!;
  }

  @override
  Future<List<dynamic>> getGenresForBook(String bookId) async {
    final response = await _dio.fetch<List<dynamic>>(
      Options(method: 'GET').compose(_dio.options, '/book-genres/$bookId'),
    );
    return response.data!;
  }

  @override
  Future<void> removeGenreFromBook(String bookId, String genreId) async {
    await _dio.fetch<dynamic>(
      Options(method: 'DELETE')
          .compose(_dio.options, '/book-genres/$bookId/$genreId'),
    );
  }
}
