import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../dtos/catalog_book_dto.dart';

part 'catalog_api_client.g.dart';

@RestApi()
abstract class CatalogApiClient {
  factory CatalogApiClient(Dio dio, {String? baseUrl}) = _CatalogApiClient;

  /// Books whose title or author contains [search], title order.
  @GET('/books/')
  Future<List<CatalogBookDto>> searchBooks(
    @Query('search') String search,
    @Query('limit') int limit,
  );
}
