import '../../domain/entities/catalog_book.dart';

/// A row from `GET /books?search=…`.
class CatalogBookDto {
  final int bookId;
  final String title;
  final String? author;

  const CatalogBookDto({
    required this.bookId,
    required this.title,
    this.author,
  });

  factory CatalogBookDto.fromJson(Map<String, dynamic> json) {
    return CatalogBookDto(
      bookId: json['book_id'] as int,
      title: json['title'] as String? ?? 'Unknown Title',
      author: json['author'] as String?,
    );
  }

  CatalogBook toEntity() =>
      CatalogBook(bookId: bookId, title: title, author: author);
}
