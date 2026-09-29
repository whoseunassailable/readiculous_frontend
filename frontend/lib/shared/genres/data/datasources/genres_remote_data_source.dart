import '../../../../core/network/dio_client.dart';
import '../dtos/genre_dto.dart';
import 'genres_api_client.dart';

abstract class GenresRemoteDataSource {
  Future<List<GenreDto>> fetchUserGenres(String userId);
}

class GenresRemoteDataSourceImpl implements GenresRemoteDataSource {
  final GenresApiClient _client = GenresApiClient(DioClient.main);

  @override
  Future<List<GenreDto>> fetchUserGenres(String userId) =>
      _client.getUserGenres(userId);
}
