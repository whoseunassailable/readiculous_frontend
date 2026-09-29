import 'package:dio/dio.dart';

import '../../../../core/network/api_error.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/genre.dart';
import '../../domain/repositories/genres_repository.dart';
import '../datasources/genres_remote_data_source.dart';

class GenresRepositoryImpl implements GenresRepository {
  final GenresRemoteDataSource remote;

  const GenresRepositoryImpl(this.remote);

  @override
  Future<List<Genre>> getAllGenres() async {
    try {
      final dtos = await remote.fetchAllGenres();
      return dtos.map((dto) => dto.toEntity()).toList();
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('getAllGenres failed', error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e('getAllGenres unexpected error', error: e, stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }

  @override
  Future<List<Genre>> getUserGenres(String userId) async {
    try {
      final dtos = await remote.fetchUserGenres(userId);
      return dtos.map((dto) => dto.toEntity()).toList();
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('getUserGenres failed (userId: $userId)', error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e('getUserGenres unexpected error (userId: $userId)',
          error: e, stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }

  @override
  Future<void> addUserGenres(String userId, List<int> genreIds) async {
    try {
      await remote.addUserGenres(userId, genreIds);
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('addUserGenres failed (userId: $userId)', error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e('addUserGenres unexpected error (userId: $userId)',
          error: e, stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }

  @override
  Future<void> removeUserGenre(String userId, int genreId) async {
    try {
      await remote.removeUserGenre(userId, genreId);
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('removeUserGenre failed (userId: $userId, genreId: $genreId)',
          error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e(
          'removeUserGenre unexpected error (userId: $userId, genreId: $genreId)',
          error: e,
          stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }
}
