/// A book the library owns that nobody uses: every copy is on the shelf and
/// none of its readers has read, borrowed or asked for it in months.
class IdleBook {
  final int bookId;
  final String title;
  final String? author;
  final int copiesTotal;

  /// When one of the library's readers last read, borrowed or asked for it
  /// (null: never).
  final DateTime? lastActivity;

  const IdleBook({
    required this.bookId,
    required this.title,
    this.author,
    required this.copiesTotal,
    this.lastActivity,
  });

  /// Copies to take off the shelf: keep one in case someone asks, or remove
  /// the only copy.
  int get copiesToFree => copiesTotal > 1 ? copiesTotal - 1 : 1;

  /// Whether freeing [copiesToFree] takes the title out of stock.
  bool get removesTitle => copiesToFree >= copiesTotal;
}

/// The library's idle books, most copies first.
class IdleShelf {
  final int libraryId;

  /// "Idle" means untouched for this many days.
  final int idleDays;
  final int totalTitles;
  final int totalCopies;

  /// The first of them (the list is capped).
  final List<IdleBook> books;

  const IdleShelf({
    required this.libraryId,
    required this.idleDays,
    required this.totalTitles,
    required this.totalCopies,
    required this.books,
  });
}
