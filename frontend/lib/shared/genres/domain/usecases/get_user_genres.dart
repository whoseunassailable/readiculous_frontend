import '../entities/genre.dart';
import '../repositories/genres_repository.dart';

class GetUserGenres {
  final GenresRepository repo;

  const GetUserGenres(this.repo);

  Future<List<Genre>> call(String userId) => repo.getUserGenres(userId);
}
