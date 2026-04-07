import '../../../../network/dio_client.dart';
import '../dtos/book_dto.dart';
import '../dtos/library_dto.dart';
import 'home_api_client.dart';

abstract class HomeRemoteDataSource {
  Future<BookDto> fetchFeaturedBook();
  Future<LibraryDto?> fetchUserLibrary(String userId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final HomeApiClient _client = HomeApiClient(DioClient.main);

  @override
  Future<BookDto> fetchFeaturedBook() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return const BookDto(
      id: 'featured-1',
      title: 'The Name of the Wind',
      author: 'Patrick Rothfuss',
      primaryGenre: 'Fantasy',
    );
  }

  @override
  Future<LibraryDto?> fetchUserLibrary(String userId) async {
    final response = await _client.getUserLibrary(userId);
    return response.library;
  }
}
