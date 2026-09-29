import 'package:dio/dio.dart';

import '../../../../core/cache/app_cache_service.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/library.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_remote_data_source.dart';
import '../dtos/library_dto.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource remote;
  final AppCacheService cache;

  const LibraryRepositoryImpl(this.remote, this.cache);

  @override
  Future<List<Library>> getAllLibraries() async {
    try {
      final dtos = await remote.fetchAllLibraries();
      return dtos.map((dto) => dto.toEntity()).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('getAllLibraries failed', error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e('getAllLibraries unexpected error', error: e, stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }

  @override
  Future<void> setReaderLibrary(String userId, int libraryId) async {
    try {
      await remote.setUserLibrary(userId, libraryId);
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('setReaderLibrary failed (userId: $userId)', error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e('setReaderLibrary unexpected error (userId: $userId)',
          error: e, stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }

  @override
  Future<void> assignLibrarian(String userId, int libraryId) async {
    try {
      await remote.assignLibrarian(userId, libraryId);
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('assignLibrarian failed (userId: $userId)', error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e('assignLibrarian unexpected error (userId: $userId)',
          error: e, stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }

  /// Always asks the server first so a library changed elsewhere shows up
  /// immediately; the cached copy is only used when the server can't be
  /// reached.
  @override
  Future<Library?> getUserLibrary(String userId) async {
    try {
      final dto = await remote.fetchUserLibrary(userId);
      if (dto != null) {
        await cache
            .saveCurrentUserLibrary({...dto.toJson(), 'user_id': userId});
      }
      return dto?.toEntity();
    } on DioException catch (e) {
      final cached = await _cachedLibrary(userId);
      if (cached != null) return cached.toEntity();
      final error = ApiError.fromDio(e);
      AppLogger.e('getUserLibrary failed (userId: $userId)', error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e('getUserLibrary unexpected error (userId: $userId)',
          error: e, stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }

  /// The cached library, if it belongs to [userId]. A missing, foreign or
  /// unreadable entry is a cache miss.
  Future<LibraryDto?> _cachedLibrary(String userId) async {
    try {
      final cached = await cache.getCurrentUserLibrary();
      if (cached == null || cached['user_id'] != userId) return null;
      return LibraryDto.fromJson(cached);
    } catch (e) {
      AppLogger.e('Ignoring unreadable library cache', error: e);
      return null;
    }
  }
}
