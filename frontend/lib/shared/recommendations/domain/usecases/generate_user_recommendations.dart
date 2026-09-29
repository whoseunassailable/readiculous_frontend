import '../repositories/recommendations_repository.dart';

class GenerateUserRecommendations {
  final RecommendationsRepository repo;

  const GenerateUserRecommendations(this.repo);

  Future<void> call(String userId, {int topN = 10}) =>
      repo.generateUserRecommendations(userId, topN: topN);
}
