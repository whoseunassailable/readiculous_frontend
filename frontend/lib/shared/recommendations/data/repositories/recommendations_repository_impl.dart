import 'package:dio/dio.dart';

import '../../../../core/network/api_error.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/library_recommendation.dart';
import '../../domain/entities/user_recommendation.dart';
import '../../domain/repositories/recommendations_repository.dart';
import '../datasources/recommendations_remote_data_source.dart';

class RecommendationsRepositoryImpl implements RecommendationsRepository {
  final RecommendationsRemoteDataSource remote;

  const RecommendationsRepositoryImpl(this.remote);

  @override
  Future<List<UserRecommendation>> getUserRecommendations(String userId) async {
    try {
      final dtos = await remote.fetchUserRecommendations(userId);
      return dtos.map((dto) => dto.toEntity()).toList();
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('getUserRecommendations failed (userId: $userId)',
          error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e('getUserRecommendations unexpected error (userId: $userId)',
          error: e, stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }

  @override
  Future<void> generateUserRecommendations(String userId,
      {int topN = 10}) async {
    try {
      await remote.generateUserRecommendations(userId, topN);
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('generateUserRecommendations failed (userId: $userId)',
          error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e(
          'generateUserRecommendations unexpected error (userId: $userId)',
          error: e,
          stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }

  @override
  Future<List<LibraryRecommendation>> getLibraryRecommendations(
      int libraryId) async {
    try {
      final dtos = await remote.fetchLibraryRecommendations(libraryId);
      return dtos.map((dto) => dto.toEntity()).toList();
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('getLibraryRecommendations failed (libraryId: $libraryId)',
          error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e(
          'getLibraryRecommendations unexpected error (libraryId: $libraryId)',
          error: e,
          stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }

  @override
  Future<void> generateLibraryRecommendations(int libraryId,
      {int topNBooks = 10}) async {
    try {
      await remote.generateLibraryRecommendations(libraryId, topNBooks);
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e(
          'generateLibraryRecommendations failed (libraryId: $libraryId)',
          error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e(
          'generateLibraryRecommendations unexpected error (libraryId: $libraryId)',
          error: e,
          stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }

  @override
  Future<void> updateLibraryRecommendationState(
      int recommendationId, String state,
      {int? copies}) async {
    try {
      await remote.updateLibraryRecommendationState(recommendationId, state,
          copies: copies);
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e(
          'updateLibraryRecommendationState failed (id: $recommendationId)',
          error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e(
          'updateLibraryRecommendationState unexpected error (id: $recommendationId)',
          error: e,
          stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }
}
