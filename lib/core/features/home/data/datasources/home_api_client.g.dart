// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_api_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _HomeApiClient implements HomeApiClient {
  _HomeApiClient(this._dio, {String? baseUrl}) {
    if (baseUrl != null) {
      _dio.options.baseUrl = baseUrl;
    }
  }

  final Dio _dio;

  @override
  Future<LibraryResponseDto> getUserLibrary(String userId) async {
    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'GET')
          .compose(_dio.options, '/users/$userId/library'),
    );
    return LibraryResponseDto.fromJson(response.data!);
  }
}
