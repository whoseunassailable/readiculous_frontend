class LibraryRecommendation {
  final int recommendationId;
  final int libraryId;
  final int bookId;
  final String title;
  final String? author;
  final String? coverUrl;
  final double demandScore;
  final String? demandLevel;
  final String? reason;

  /// NEW | ORDERED | STOCKED | IGNORED
  final String? state;

  /// Copies the library owns, and how many are on the shelf now.
  final int copiesTotal;
  final int copiesAvailable;

  /// This library's readers who want to read it.
  final int readersWaiting;

  /// Lent copies likely back within a week (an estimate: no loan records
  /// exist, so a reader "reading" it counts as a 21-day loan).
  final int backSoon;

  /// This library's readers per month, averaged over the last 3 months.
  final double readersPerMonth;

  const LibraryRecommendation({
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

  /// Copies lent out right now.
  int get copiesOut => copiesTotal - copiesAvailable;

  /// Not yet acted on by a librarian.
  bool get isPending => state == null || state == 'NEW';
}
