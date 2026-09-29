import '../../domain/entities/user_recommendation.dart';

class UserRecommendationDto {
  final int recommendationId;
  final int bookId;
  final String title;
  final String? author;
  final String? coverUrl;
  final String? genre;
  final double score;
  final String? reason;

  const UserRecommendationDto({
    required this.recommendationId,
    required this.bookId,
    required this.title,
    this.author,
    this.coverUrl,
    this.genre,
    required this.score,
    this.reason,
  });

  factory UserRecommendationDto.fromJson(Map<String, dynamic> json) {
    return UserRecommendationDto(
      recommendationId: json['recommendation_id'] as int,
      bookId: json['book_id'] as int,
      title: json['title'] as String,
      author: json['author'] as String?,
      coverUrl: json['cover_url'] as String?,
      // Comma-joined book genres, e.g. "Comedy, Mystery, Sci-Fi".
      genre: json['genre'] as String?,
      // MySQL DECIMAL arrives as a string, e.g. "0.8335".
      score: double.tryParse('${json['score']}') ?? 0,
      reason: json['reason'] as String?,
    );
  }

  UserRecommendation toEntity() => UserRecommendation(
        recommendationId: recommendationId,
        bookId: bookId,
        title: title,
        author: author,
        coverUrl: coverUrl,
        genres: _split(genre) ?? _split(_reasonGenres()) ?? const [],
        score: score,
        reason: reason,
      );

  /// The generator records its input as "Genres: A, B" in [reason].
  String? _reasonGenres() {
    const prefix = 'Genres:';
    final r = reason;
    return r != null && r.startsWith(prefix)
        ? r.substring(prefix.length)
        : null;
  }

  static List<String>? _split(String? csv) {
    final parts = (csv ?? '')
        .split(',')
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toList();
    return parts.isEmpty ? null : parts;
  }
}
