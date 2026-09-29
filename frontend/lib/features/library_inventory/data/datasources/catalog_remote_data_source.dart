import '../../../../core/network/dio_client.dart';
import '../dtos/catalog_book_dto.dart';
import 'catalog_api_client.dart';

abstract class CatalogRemoteDataSource {
  Future<List<CatalogBookDto>> searchBooks(String query, int limit);
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final CatalogApiClient _client = CatalogApiClient(DioClient.main);

  @override
  Future<List<CatalogBookDto>> searchBooks(String query, int limit) =>
      _client.searchBooks(query, limit);
}
