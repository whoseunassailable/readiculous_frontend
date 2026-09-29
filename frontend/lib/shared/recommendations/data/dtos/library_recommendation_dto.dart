import '../../domain/entities/library_recommendation.dart';

class LibraryRecommendationDto {
  final int recommendationId;
  final int libraryId;
  final int bookId;
  final String title;
  final String? author;
  final String? coverUrl;
  final double demandScore;
  final String? demandLevel;
  final String? reason;
  final String? state;
  final int copiesTotal;
  final int copiesAvailable;
  final int readersWaiting;
  final int backSoon;
  final double readersPerMonth;

  const LibraryRecommendationDto({
    required this.recommendationId,
    required this.libraryId,
    required this.bookId,
    required this.title,
    this.author,
    this.coverUrl,
    required this.demandScore,
    this.demandLevel,
    this.reason,
    this.state,
    this.copiesTotal = 0,
    this.copiesAvailable = 0,
    this.readersWaiting = 0,
    this.backSoon = 0,
    this.readersPerMonth = 0,
  });

  factory LibraryRecommendationDto.fromJson(Map<String, dynamic> json) {
    return LibraryRecommendationDto(
      recommendationId: json['recommendation_id'] as int,
      libraryId: json['library_id'] as int,
      bookId: json['book_id'] as int,
      title: json['title'] as String,
      author: json['author'] as String?,
      coverUrl: json['cover_url'] as String?,
      // MySQL DECIMAL arrives as a string, e.g. "0.9642".
      demandScore: double.tryParse('${json['demand_score']}') ?? 0,
      demandLevel: json['demand_level'] as String?,
      reason: json['reason'] as String?,
      state: json['state'] as String?,
      copiesTotal: (json['copies_total'] as num?)?.toInt() ?? 0,
      copiesAvailable: (json['copies_available'] as num?)?.toInt() ?? 0,
      readersWaiting: (json['readers_waiting'] as num?)?.toInt() ?? 0,
      backSoon: (json['back_soon'] as num?)?.toInt() ?? 0,
      readersPerMonth: double.tryParse('${json['readers_per_month']}') ?? 0,
    );
  }

  LibraryRecommendation toEntity() => LibraryRecommendation(
        recommendationId: recommendationId,
        libraryId: libraryId,
        bookId: bookId,
        title: title,
        author: author,
        coverUrl: coverUrl,
        demandScore: demandScore,
        demandLevel: demandLevel,
        reason: reason,
        state: state,
        copiesTotal: copiesTotal,
        copiesAvailable: copiesAvailable,
        readersWaiting: readersWaiting,
        backSoon: backSoon,
        readersPerMonth: readersPerMonth,
      );
}
