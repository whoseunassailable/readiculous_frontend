// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trends_api_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _TrendsApiClient implements TrendsApiClient {
  _TrendsApiClient(this._dio, {String? baseUrl}) {
    if (baseUrl != null) _dio.options.baseUrl = baseUrl;
  }

  final Dio _dio;

  @override
  Future<List<dynamic>> getLibraryTrends(String libraryId) async {
    final response = await _dio.fetch<List<dynamic>>(
      Options(method: 'GET')
          .compose(_dio.options, '/trends/libraries/$libraryId'),
    );
    return response.data!;
  }

  @override
  Future<List<dynamic>> getTopTrends({String? libraryId}) async {
    final queryParameters = <String, dynamic>{};
    if (libraryId != null) queryParameters['library_id'] = libraryId;
    final response = await _dio.fetch<List<dynamic>>(
      Options(method: 'GET').compose(_dio.options, '/trends/top',
          queryParameters: queryParameters),
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> upsertTrendScore(
      Map<String, dynamic> body) async {
    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'POST').compose(_dio.options, '/trends/', data: body),
    );
    return response.data!;
  }
}
