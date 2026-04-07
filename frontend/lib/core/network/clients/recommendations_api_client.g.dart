// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendations_api_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _RecommendationsApiClient implements RecommendationsApiClient {
  _RecommendationsApiClient(this._dio, {String? baseUrl}) {
    if (baseUrl != null) _dio.options.baseUrl = baseUrl;
  }

  final Dio _dio;

  @override
  Future<List<dynamic>> getUserRecommendations(String userId) async {
    final response = await _dio.fetch<List<dynamic>>(
      Options(method: 'GET')
          .compose(_dio.options, '/recommendations/users/$userId'),
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> createUserRecommendation(
      Map<String, dynamic> body) async {
    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'POST')
          .compose(_dio.options, '/recommendations/users', data: body),
    );
    return response.data!;
  }

  @override
  Future<void> deleteUserRecommendation(String recommendationId) async {
    await _dio.fetch<dynamic>(
      Options(method: 'DELETE')
          .compose(_dio.options, '/recommendations/users/$recommendationId'),
    );
  }

  @override
  Future<List<dynamic>> getLibraryRecommendations(String libraryId) async {
    final response = await _dio.fetch<List<dynamic>>(
      Options(method: 'GET')
          .compose(_dio.options, '/recommendations/libraries/$libraryId'),
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> createLibraryRecommendation(
      Map<String, dynamic> body) async {
    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'POST')
          .compose(_dio.options, '/recommendations/libraries', data: body),
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> updateLibraryRecommendationState(
      String recommendationId, Map<String, dynamic> body) async {
    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'PATCH').compose(
          _dio.options, '/recommendations/libraries/$recommendationId',
          data: body),
    );
    return response.data!;
  }

  @override
  Future<void> deleteLibraryRecommendation(String recommendationId) async {
    await _dio.fetch<dynamic>(
      Options(method: 'DELETE').compose(
          _dio.options, '/recommendations/libraries/$recommendationId'),
    );
  }
}
