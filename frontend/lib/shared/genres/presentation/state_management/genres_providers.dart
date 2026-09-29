import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/genres_remote_data_source.dart';
import '../../data/repositories/genres_repository_impl.dart';
import '../../domain/repositories/genres_repository.dart';
import '../../domain/usecases/get_user_genres.dart';

final genresRepositoryProvider = Provider<GenresRepository>(
  (ref) => GenresRepositoryImpl(GenresRemoteDataSourceImpl()),
);

final getUserGenresProvider = Provider<GetUserGenres>(
  (ref) => GetUserGenres(ref.watch(genresRepositoryProvider)),
);
