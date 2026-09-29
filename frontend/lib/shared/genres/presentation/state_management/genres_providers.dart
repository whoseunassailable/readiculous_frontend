import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/session/session_provider.dart';
import '../../data/datasources/genres_remote_data_source.dart';
import '../../data/repositories/genres_repository_impl.dart';
import '../../domain/entities/genre.dart';
import '../../domain/repositories/genres_repository.dart';
import '../../domain/usecases/get_all_genres.dart';
import '../../domain/usecases/get_user_genres.dart';
import '../../domain/usecases/save_user_genres.dart';

final genresRepositoryProvider = Provider<GenresRepository>(
  (ref) => GenresRepositoryImpl(GenresRemoteDataSourceImpl()),
);

final getAllGenresProvider = Provider<GetAllGenres>(
  (ref) => GetAllGenres(ref.watch(genresRepositoryProvider)),
);

final getUserGenresProvider = Provider<GetUserGenres>(
  (ref) => GetUserGenres(ref.watch(genresRepositoryProvider)),
);

final saveUserGenresProvider = Provider<SaveUserGenres>(
  (ref) => SaveUserGenres(ref.watch(genresRepositoryProvider)),
);

/// The logged-in user's preferred genres (empty when logged out).
final userGenresProvider = FutureProvider.autoDispose<List<Genre>>(
  (ref) async {
    final userId = ref.watch(sessionProvider.select((s) => s.userId));
    if (userId == null) return [];
    return ref.watch(getUserGenresProvider).call(userId);
  },
);

/// Every genre in the catalog.
final allGenresProvider = FutureProvider.autoDispose<List<Genre>>(
  (ref) => ref.watch(getAllGenresProvider).call(),
);
