import '../entities/genre.dart';
import '../repositories/genres_repository.dart';

class GetAllGenres {
  final GenresRepository repo;

  const GetAllGenres(this.repo);

  Future<List<Genre>> call() => repo.getAllGenres();
}
