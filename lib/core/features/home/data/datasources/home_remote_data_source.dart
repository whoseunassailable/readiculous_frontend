import '../dtos/book_dto.dart';

abstract class HomeRemoteDataSource {
  Future<BookDto> fetchFeaturedBook();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  @override
  Future<BookDto> fetchFeaturedBook() async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    // fake JSON (this is where HTTP response would go)
    final json = <String, dynamic>{
      "id": "featured-1",
      "title": "The Name of the Wind",
      "author": "Patrick Rothfuss",
      "primaryGenre": "Fantasy",
    };

    return BookDto.fromJson(json);
  }
}
