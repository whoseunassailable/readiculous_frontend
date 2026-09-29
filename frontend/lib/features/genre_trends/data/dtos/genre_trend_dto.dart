import '../../domain/entities/genre_trend.dart';

class GenreTrendDto {
  final int genreId;
  final String genreName;
  final double score;

  const GenreTrendDto({
    required this.genreId,
    required this.genreName,
    required this.score,
  });

  factory GenreTrendDto.fromJson(Map<String, dynamic> json) {
    return GenreTrendDto(
      genreId: json['genre_id'] as int,
      genreName: json['genre_name'] as String,
      // Tolerates MySQL DECIMAL arriving as a string.
      score: double.tryParse('${json['score']}') ?? 0,
    );
  }

  GenreTrend toEntity() => GenreTrend(
        genreId: genreId,
        name: genreName,
        score: score,
      );
}
