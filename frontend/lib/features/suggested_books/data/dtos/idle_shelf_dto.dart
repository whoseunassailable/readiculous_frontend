import '../../domain/entities/idle_book.dart';

/// `GET /library-books/:library_id/idle`.
class IdleShelfDto {
  final int idleDays;
  final int totalTitles;
  final int totalCopies;
  final List<IdleBookDto> books;

  const IdleShelfDto({
    required this.idleDays,
    required this.totalTitles,
    required this.totalCopies,
    required this.books,
  });

  factory IdleShelfDto.fromJson(Map<String, dynamic> json) => IdleShelfDto(
        idleDays: (json['idle_days'] as num).toInt(),
        totalTitles: (json['total_titles'] as num).toInt(),
        totalCopies: (json['total_copies'] as num).toInt(),
        books: [
          for (final b in json['books'] as List)
            IdleBookDto.fromJson(b as Map<String, dynamic>),
        ],
      );

  IdleShelf toEntity(int libraryId) => IdleShelf(
        libraryId: libraryId,
        idleDays: idleDays,
        totalTitles: totalTitles,
        totalCopies: totalCopies,
        books: [for (final b in books) b.toEntity()],
      );
}

class IdleBookDto {
  final int bookId;
  final String title;
  final String? author;
  final int copiesTotal;
  final DateTime? lastActivity;

  const IdleBookDto({
    required this.bookId,
    required this.title,
    this.author,
    required this.copiesTotal,
    this.lastActivity,
  });

  factory IdleBookDto.fromJson(Map<String, dynamic> json) => IdleBookDto(
        bookId: json['book_id'] as int,
        title: json['title'] as String? ?? 'Unknown Title',
        author: json['author'] as String?,
        copiesTotal: (json['copies_total'] as num).toInt(),
        lastActivity: DateTime.tryParse('${json['last_activity']}'),
      );

  IdleBook toEntity() => IdleBook(
        bookId: bookId,
        title: title,
        author: author,
        copiesTotal: copiesTotal,
        lastActivity: lastActivity,
      );
}

/// `POST /library-books/:library_id/:book_id/remove`.
class RemoveCopiesRequestDto {
  final int copies;
  const RemoveCopiesRequestDto({required this.copies});
  Map<String, dynamic> toJson() => {'copies': copies};
}
