import 'package:dio/dio.dart';

import '../../../../core/network/api_error.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/idle_book.dart';
import '../../domain/repositories/shelf_repository.dart';
import '../datasources/shelf_remote_data_source.dart';

class ShelfRepositoryImpl implements ShelfRepository {
  final ShelfRemoteDataSource remote;

  const ShelfRepositoryImpl(this.remote);

  @override
  Future<IdleShelf> getIdleBooks(int libraryId) =>
      _guard('getIdleBooks (libraryId: $libraryId)', () async {
        return (await remote.fetchIdleBooks(libraryId)).toEntity(libraryId);
      });

  @override
  Future<void> removeCopies(int libraryId, int bookId, int copies) => _guard(
      'removeCopies (libraryId: $libraryId, bookId: $bookId)',
      () => remote.removeCopies(libraryId, bookId, copies));

  Future<T> _guard<T>(String what, Future<T> Function() run) async {
    try {
      return await run();
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('$what failed', error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e('$what unexpected error', error: e, stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }
}
