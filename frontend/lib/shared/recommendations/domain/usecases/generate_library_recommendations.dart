import '../repositories/recommendations_repository.dart';

class GenerateLibraryRecommendations {
  final RecommendationsRepository repo;

  const GenerateLibraryRecommendations(this.repo);

  Future<void> call(int libraryId, {int topNBooks = 10}) =>
      repo.generateLibraryRecommendations(libraryId, topNBooks: topNBooks);
}
