// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_books_api_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _LibraryBooksApiClient implements LibraryBooksApiClient {
  _LibraryBooksApiClient(this._dio, {String? baseUrl}) {
    if (baseUrl != null) _dio.options.baseUrl = baseUrl;
  }

  final Dio _dio;

  @override
  Future<List<dynamic>> getBooksInLibrary(String libraryId) async {
    final response = await _dio.fetch<List<dynamic>>(
      Options(method: 'GET')
          .compose(_dio.options, '/library-books/$libraryId'),
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> addOrUpdateBookInventory(
      Map<String, dynamic> body) async {
    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'POST')
          .compose(_dio.options, '/library-books/', data: body),
    );
    return response.data!;
  }
}
