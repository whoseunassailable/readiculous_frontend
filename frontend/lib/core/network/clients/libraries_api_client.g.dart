// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'libraries_api_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _LibrariesApiClient implements LibrariesApiClient {
  _LibrariesApiClient(this._dio, {String? baseUrl}) {
    if (baseUrl != null) _dio.options.baseUrl = baseUrl;
  }

  final Dio _dio;

  @override
  Future<List<dynamic>> getAllLibraries() async {
    final response = await _dio.fetch<List<dynamic>>(
      Options(method: 'GET').compose(_dio.options, '/libraries/'),
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> createLibrary(Map<String, dynamic> body) async {
    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'POST')
          .compose(_dio.options, '/libraries/', data: body),
    );
    return response.data!;
  }
}
