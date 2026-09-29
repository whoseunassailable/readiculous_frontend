import '../../domain/entities/genre.dart';

class GenreDto {
  final int genreId;
  final String name;

  const GenreDto({
    required this.genreId,
    required this.name,
  });

  factory GenreDto.fromJson(Map<String, dynamic> json) {
    return GenreDto(
      genreId: json['genre_id'] as int,
      name: json['name'] as String,
    );
  }

  Genre toEntity() => Genre(
        genreId: genreId,
        name: name,
      );
}
