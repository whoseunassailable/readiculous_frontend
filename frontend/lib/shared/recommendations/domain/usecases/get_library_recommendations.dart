import '../entities/library_recommendation.dart';
import '../repositories/recommendations_repository.dart';

class GetLibraryRecommendations {
  final RecommendationsRepository repo;

  const GetLibraryRecommendations(this.repo);

  Future<List<LibraryRecommendation>> call(int libraryId) =>
      repo.getLibraryRecommendations(libraryId);
}
