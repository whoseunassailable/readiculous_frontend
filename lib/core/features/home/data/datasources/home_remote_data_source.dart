import 'dart:async';
import 'package:dio/dio.dart';

import '../../../../network/dio_client.dart';
import '../dtos/book_dto.dart';
import '../dtos/library_dto.dart';

abstract class HomeRemoteDataSource {
  Future<BookDto> fetchFeaturedBook();
  Future<LibraryDto?> fetchUserLibrary(String userId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? DioClient.main;

  final Dio _dio;

  @override
  Future<BookDto> fetchFeaturedBook() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final featuredBookJson = <String, dynamic>{
      "id": "featured-1",
      "title": "The Name of the Wind",
      "author": "Patrick Rothfuss",
      "primaryGenre": "Fantasy",
    };

    return BookDto.fromJson(featuredBookJson);
  }

  @override
  Future<LibraryDto?> fetchUserLibrary(String userId) async {
    try {
      // baseUrl already ends with /api
      final res = await _dio.get<Map<String, dynamic>>(
        'users/$userId/library',
      );

      final data = res.data;
      if (data == null) return null; // or throw if you expect body always

      final libJson = data['library'];
      if (libJson == null) return null;

      if (libJson is! Map<String, dynamic>) {
        throw const FormatException('Expected "library" to be a JSON object');
      }

      return LibraryDto.fromJson(libJson);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      throw Exception(
          'Failed to fetch user library (status: $status, body: $body)');
    }
  }
}
