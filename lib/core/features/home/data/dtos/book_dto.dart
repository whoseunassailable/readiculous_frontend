import '../../domain/entities/book.dart';

class BookDto {
  final String id;
  final String title;
  final String author;
  final String primaryGenre;

  const BookDto({
    required this.id,
    required this.title,
    required this.author,
    required this.primaryGenre,
  });

  factory BookDto.fromJson(Map<String, dynamic> json) {
    return BookDto(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      primaryGenre: json['primaryGenre'] as String,
    );
  }

  Book toEntity() {
    return Book(
      id: id,
      title: title,
      author: author,
      primaryGenre: primaryGenre,
    );
  }
}
