// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'librarians_api_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _LibrariansApiClient implements LibrariansApiClient {
  _LibrariansApiClient(this._dio, {String? baseUrl}) {
    if (baseUrl != null) _dio.options.baseUrl = baseUrl;
  }

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> assignLibrarian(
      Map<String, dynamic> body) async {
    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'POST')
          .compose(_dio.options, '/librarians/assign', data: body),
    );
    return response.data!;
  }

  @override
  Future<List<dynamic>> getLibrariansForLibrary(String libraryId) async {
    final response = await _dio.fetch<List<dynamic>>(
      Options(method: 'GET')
          .compose(_dio.options, '/librarians/$libraryId'),
    );
    return response.data!;
  }

  @override
  Future<void> unassignLibrarian(String userId, String libraryId) async {
    await _dio.fetch<dynamic>(
      Options(method: 'DELETE')
          .compose(_dio.options, '/librarians/$userId/$libraryId'),
    );
  }
}
