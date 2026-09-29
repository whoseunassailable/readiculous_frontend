import '../entities/genre_trend.dart';

abstract class TrendsRepository {
  /// The library's genres by current trend score, highest first.
  Future<List<GenreTrend>> getTopTrends(int libraryId);
}
