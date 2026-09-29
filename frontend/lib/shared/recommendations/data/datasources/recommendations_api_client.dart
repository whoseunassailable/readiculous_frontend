import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../dtos/library_recommendation_dto.dart';
import '../dtos/recommendation_requests_dto.dart';
import '../dtos/user_recommendation_dto.dart';

part 'recommendations_api_client.g.dart';

@RestApi()
abstract class RecommendationsApiClient {
  factory RecommendationsApiClient(Dio dio, {String? baseUrl}) =
      _RecommendationsApiClient;

  // ── A reader's personal picks ──────────────────────────────────────────────

  @GET('/recommendations/users/{userId}')
  Future<List<UserRecommendationDto>> getUserRecommendations(
      @Path('userId') String userId);

  /// Runs the ML model and saves fresh picks (slow).
  @POST('/recommendations/users/{userId}/generate')
  Future<void> generateUserRecommendations(
    @Path('userId') String userId,
    @Body() GenerateUserRecommendationsRequestDto body,
    @DioOptions() Options options,
  );

  // ── A library's stocking picks ─────────────────────────────────────────────

  @GET('/recommendations/libraries/{libraryId}')
  Future<List<LibraryRecommendationDto>> getLibraryRecommendations(
      @Path('libraryId') int libraryId);

  /// Runs the ML model and saves fresh picks (slow).
  @POST('/recommendations/libraries/{libraryId}/generate')
  Future<void> generateLibraryRecommendations(
    @Path('libraryId') int libraryId,
    @Body() GenerateLibraryRecommendationsRequestDto body,
    @DioOptions() Options options,
  );

  /// A librarian's decision; also feeds the library's genre trends.
  @PATCH('/recommendations/libraries/{recommendationId}')
  Future<void> updateLibraryRecommendationState(
    @Path('recommendationId') int recommendationId,
    @Body() UpdateRecommendationStateRequestDto body,
  );
}
