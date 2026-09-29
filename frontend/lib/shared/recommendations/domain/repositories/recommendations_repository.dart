import '../entities/library_recommendation.dart';
import '../entities/user_recommendation.dart';

abstract class RecommendationsRepository {
  /// A reader's saved picks, best first.
  Future<List<UserRecommendation>> getUserRecommendations(String userId);

  /// Runs the model for a reader and saves fresh picks.
  Future<void> generateUserRecommendations(String userId, {int topN = 10});

  /// Saved stocking recommendations for a library, highest demand first.
  Future<List<LibraryRecommendation>> getLibraryRecommendations(int libraryId);

  /// Runs the model for a library and saves fresh picks.
  Future<void> generateLibraryRecommendations(int libraryId,
      {int topNBooks = 10});

  /// Records a librarian's decision: NEW | ORDERED | STOCKED | IGNORED.
  /// Records a librarian's decision. With ORDERED, [copies] are added to
  /// the library's stock for that book.
  Future<void> updateLibraryRecommendationState(
      int recommendationId, String state,
      {int? copies});
}
