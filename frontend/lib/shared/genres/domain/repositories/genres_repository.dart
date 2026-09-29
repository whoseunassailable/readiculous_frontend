import '../entities/genre.dart';

abstract class GenresRepository {
  Future<List<Genre>> getUserGenres(String userId);
}
