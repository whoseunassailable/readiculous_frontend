class GenreTrend {
  final int genreId;
  final String name;

  /// The genre's current trend score for the library (higher = more demand).
  final double score;

  const GenreTrend({
    required this.genreId,
    required this.name,
    required this.score,
  });
}
