import '../entities/genre_trend.dart';
import '../repositories/trends_repository.dart';

class GetTopTrends {
  final TrendsRepository repo;

  const GetTopTrends(this.repo);

  Future<List<GenreTrend>> call(int libraryId) => repo.getTopTrends(libraryId);
}
