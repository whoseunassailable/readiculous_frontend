import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'recommendations_api_client.g.dart';

@RestApi()
abstract class RecommendationsApiClient {
  factory RecommendationsApiClient(Dio dio, {String? baseUrl}) =
      _RecommendationsApiClient;

  // ── User recommendations ─────────────────────────────────────────────────

  @GET('/recommendations/users/{userId}')
  Future<List<dynamic>> getUserRecommendations(@Path('userId') String userId);

  @POST('/recommendations/users')
  Future<Map<String, dynamic>> createUserRecommendation(
      @Body() Map<String, dynamic> body);

  @DELETE('/recommendations/users/{recommendationId}')
  Future<void> deleteUserRecommendation(
      @Path('recommendationId') String recommendationId);

  // ── Library recommendations ───────────────────────────────────────────────

  @GET('/recommendations/libraries/{libraryId}')
  Future<List<dynamic>> getLibraryRecommendations(
      @Path('libraryId') String libraryId);

  @POST('/recommendations/libraries')
  Future<Map<String, dynamic>> createLibraryRecommendation(
      @Body() Map<String, dynamic> body);

  /// Update state: NEW | ORDERED | STOCKED | IGNORED
  @PATCH('/recommendations/libraries/{recommendationId}')
  Future<Map<String, dynamic>> updateLibraryRecommendationState(
    @Path('recommendationId') String recommendationId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/recommendations/libraries/{recommendationId}')
  Future<void> deleteLibraryRecommendation(
      @Path('recommendationId') String recommendationId);
}
