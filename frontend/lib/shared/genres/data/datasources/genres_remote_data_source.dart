import '../../../../core/network/dio_client.dart';
import '../dtos/add_user_genres_request_dto.dart';
import '../dtos/genre_dto.dart';
import 'genres_api_client.dart';

abstract class GenresRemoteDataSource {
  Future<List<GenreDto>> fetchAllGenres();
  Future<List<GenreDto>> fetchUserGenres(String userId);
  Future<void> addUserGenres(String userId, List<int> genreIds);
  Future<void> removeUserGenre(String userId, int genreId);
}

class GenresRemoteDataSourceImpl implements GenresRemoteDataSource {
  final GenresApiClient _client = GenresApiClient(DioClient.main);

  @override
  Future<List<GenreDto>> fetchAllGenres() => _client.getAllGenres();

  @override
  Future<List<GenreDto>> fetchUserGenres(String userId) =>
      _client.getUserGenres(userId);

  @override
  Future<void> addUserGenres(String userId, List<int> genreIds) =>
      _client.addUserGenres(
          AddUserGenresRequestDto(userId: userId, genreIds: genreIds));

  @override
  Future<void> removeUserGenre(String userId, int genreId) =>
      _client.removeUserGenre(userId, genreId);
}
