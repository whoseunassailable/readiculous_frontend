import '../repositories/genres_repository.dart';

/// Makes [genreIds] the user's exact set of preferred genres. Compares with
/// what the server has now, removes the genres no longer chosen and adds the
/// new ones, so it's safe to call with a stale view of the preferences.
class SaveUserGenres {
  final GenresRepository repo;

  const SaveUserGenres(this.repo);

  Future<void> call(String userId, Set<int> genreIds) async {
    final current =
        (await repo.getUserGenres(userId)).map((g) => g.genreId).toSet();

    for (final genreId in current.difference(genreIds)) {
      await repo.removeUserGenre(userId, genreId);
    }

    final toAdd = genreIds.difference(current);
    if (toAdd.isNotEmpty) {
      await repo.addUserGenres(userId, toAdd.toList());
    }
  }
}
