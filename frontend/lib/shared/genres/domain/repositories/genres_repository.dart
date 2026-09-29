import '../entities/genre.dart';

abstract class GenresRepository {
  Future<List<Genre>> getAllGenres();
  Future<List<Genre>> getUserGenres(String userId);
  Future<void> addUserGenres(String userId, List<int> genreIds);
  Future<void> removeUserGenre(String userId, int genreId);
}
