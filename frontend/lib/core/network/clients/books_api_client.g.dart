// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'books_api_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _BooksApiClient implements BooksApiClient {
  _BooksApiClient(this._dio, {String? baseUrl}) {
    if (baseUrl != null) _dio.options.baseUrl = baseUrl;
  }

  final Dio _dio;

  @override
  Future<List<dynamic>> getAllBooks() async {
    final response = await _dio.fetch<List<dynamic>>(
      Options(method: 'GET').compose(_dio.options, '/books/'),
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> getBook(String bookId) async {
    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'GET').compose(_dio.options, '/books/$bookId'),
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> createBook(Map<String, dynamic> body) async {
    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'POST').compose(_dio.options, '/books/', data: body),
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> updateBook(
      String bookId, Map<String, dynamic> body) async {
    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'PUT').compose(_dio.options, '/books/$bookId', data: body),
    );
    return response.data!;
  }

  @override
  Future<void> deleteBook(String bookId) async {
    await _dio.fetch<dynamic>(
      Options(method: 'DELETE').compose(_dio.options, '/books/$bookId'),
    );
  }
}
