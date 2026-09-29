import 'package:dio/dio.dart';

import '../../../../core/network/api_error.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/catalog_book.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_data_source.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource remote;

  const CatalogRepositoryImpl(this.remote);

  @override
  Future<List<CatalogBook>> searchBooks(String query, {int limit = 20}) async {
    try {
      final dtos = await remote.searchBooks(query, limit);
      return dtos.map((dto) => dto.toEntity()).toList();
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('searchBooks failed (query: $query)', error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e('searchBooks unexpected error (query: $query)',
          error: e, stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }
}
