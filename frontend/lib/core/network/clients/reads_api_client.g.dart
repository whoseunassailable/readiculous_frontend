// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reads_api_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _ReadsApiClient implements ReadsApiClient {
  _ReadsApiClient(this._dio, {String? baseUrl}) {
    if (baseUrl != null) _dio.options.baseUrl = baseUrl;
  }

  final Dio _dio;

  @override
  Future<List<dynamic>> getUserReadingList(String userId) async {
    final response = await _dio.fetch<List<dynamic>>(
      Options(method: 'GET').compose(_dio.options, '/reads/$userId'),
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> addOrUpdateRead(
      Map<String, dynamic> body) async {
    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'POST').compose(_dio.options, '/reads/', data: body),
    );
    return response.data!;
  }

  @override
  Future<void> removeFromReadingList(String userId, String bookId) async {
    await _dio.fetch<dynamic>(
      Options(method: 'DELETE')
          .compose(_dio.options, '/reads/$userId/$bookId'),
    );
  }
}
