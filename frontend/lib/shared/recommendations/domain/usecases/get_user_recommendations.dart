import '../entities/user_recommendation.dart';
import '../repositories/recommendations_repository.dart';

class GetUserRecommendations {
  final RecommendationsRepository repo;

  const GetUserRecommendations(this.repo);

  Future<List<UserRecommendation>> call(String userId) =>
      repo.getUserRecommendations(userId);
}
