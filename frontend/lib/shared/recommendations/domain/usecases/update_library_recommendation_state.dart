import '../repositories/recommendations_repository.dart';

class UpdateLibraryRecommendationState {
  final RecommendationsRepository repo;

  const UpdateLibraryRecommendationState(this.repo);

  /// [copies] only with ORDERED: how many to add to the library's stock.
  Future<void> call(int recommendationId, String state, {int? copies}) =>
      repo.updateLibraryRecommendationState(recommendationId, state,
          copies: copies);
}
