import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/cache/app_cache_service.dart';
import '../../data/datasources/library_remote_data_source.dart';
import '../../data/repositories/library_repository_impl.dart';
import '../../domain/entities/library.dart';
import '../../domain/repositories/library_repository.dart';
import '../../domain/usecases/choose_library.dart';
import '../../domain/usecases/get_all_libraries.dart';
import '../../domain/usecases/get_user_library.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => LibraryRepositoryImpl(
    LibraryRemoteDataSourceImpl(),
    AppCacheService.instance,
  ),
);

final getUserLibraryProvider = Provider<GetUserLibrary>(
  (ref) => GetUserLibrary(ref.watch(libraryRepositoryProvider)),
);

final getAllLibrariesProvider = Provider<GetAllLibraries>(
  (ref) => GetAllLibraries(ref.watch(libraryRepositoryProvider)),
);

final chooseLibraryProvider = Provider<ChooseLibrary>(
  (ref) => ChooseLibrary(ref.watch(libraryRepositoryProvider)),
);

/// The user's home library (null until they pick one).
final userLibraryProvider = FutureProvider.autoDispose.family<Library?, String>(
  (ref, userId) => ref.watch(getUserLibraryProvider).call(userId),
);
