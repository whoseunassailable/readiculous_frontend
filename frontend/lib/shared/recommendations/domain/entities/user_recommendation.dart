class UserRecommendation {
  final int recommendationId;
  final int bookId;
  final String title;
  final String? author;
  final String? coverUrl;

  /// The book's genres, or the genres the pick was generated for when the
  /// book has none on record.
  final List<String> genres;
  final double score;
  final String? reason;

  const UserRecommendation({
    required this.recommendationId,
    required this.bookId,
    required this.title,
    this.author,
    this.coverUrl,
    this.genres = const [],
    required this.score,
    this.reason,
  });
}
