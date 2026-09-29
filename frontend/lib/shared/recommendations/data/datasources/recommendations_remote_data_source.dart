import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../dtos/library_recommendation_dto.dart';
import '../dtos/recommendation_requests_dto.dart';
import '../dtos/user_recommendation_dto.dart';
import 'recommendations_api_client.dart';

abstract class RecommendationsRemoteDataSource {
  Future<List<UserRecommendationDto>> fetchUserRecommendations(String userId);
  Future<void> generateUserRecommendations(String userId, int topN);
  Future<List<LibraryRecommendationDto>> fetchLibraryRecommendations(
      int libraryId);
  Future<void> generateLibraryRecommendations(int libraryId, int topNBooks);
  Future<void> updateLibraryRecommendationState(
      int recommendationId, String state,
      {int? copies});
}

class RecommendationsRemoteDataSourceImpl
    implements RecommendationsRemoteDataSource {
  final RecommendationsApiClient _client =
      RecommendationsApiClient(DioClient.main);

  /// Generation waits on the ML service (and book lookups), which can take
  /// longer than the default 30 s.
  static final _generateOptions =
      Options(receiveTimeout: const Duration(minutes: 3));

  @override
  Future<List<UserRecommendationDto>> fetchUserRecommendations(String userId) =>
      _client.getUserRecommendations(userId);

  @override
  Future<void> generateUserRecommendations(String userId, int topN) =>
      _client.generateUserRecommendations(
        userId,
        GenerateUserRecommendationsRequestDto(topN: topN),
        _generateOptions,
      );

  @override
  Future<List<LibraryRecommendationDto>> fetchLibraryRecommendations(
          int libraryId) =>
      _client.getLibraryRecommendations(libraryId);

  @override
  Future<void> generateLibraryRecommendations(int libraryId, int topNBooks) =>
      _client.generateLibraryRecommendations(
        libraryId,
        GenerateLibraryRecommendationsRequestDto(topNBooks: topNBooks),
        _generateOptions,
      );

  @override
  Future<void> updateLibraryRecommendationState(
          int recommendationId, String state,
          {int? copies}) =>
      _client.updateLibraryRecommendationState(
        recommendationId,
        UpdateRecommendationStateRequestDto(state: state, copies: copies),
      );
}
