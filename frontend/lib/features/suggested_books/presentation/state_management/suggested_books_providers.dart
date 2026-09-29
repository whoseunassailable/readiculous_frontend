import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/session/session_provider.dart';
import '../../../../shared/library/presentation/state_management/library_providers.dart';
import '../../data/datasources/ml_remote_data_source.dart';
import '../../data/datasources/shelf_remote_data_source.dart';
import '../../data/repositories/ml_repository_impl.dart';
import '../../data/repositories/shelf_repository_impl.dart';
import '../../domain/entities/idle_book.dart';
import '../../domain/repositories/ml_repository.dart';
import '../../domain/repositories/shelf_repository.dart';
import '../../domain/usecases/get_idle_books.dart';
import '../../domain/usecases/remove_copies.dart';
import '../../domain/usecases/retrain_models.dart';

final mlRepositoryProvider = Provider<MlRepository>(
  (ref) => MlRepositoryImpl(MlRemoteDataSourceImpl()),
);

final retrainModelsProvider = Provider<RetrainModels>(
  (ref) => RetrainModels(ref.watch(mlRepositoryProvider)),
);

final shelfRepositoryProvider = Provider<ShelfRepository>(
  (ref) => ShelfRepositoryImpl(ShelfRemoteDataSourceImpl()),
);

final getIdleBooksProvider = Provider<GetIdleBooks>(
  (ref) => GetIdleBooks(ref.watch(shelfRepositoryProvider)),
);

final removeCopiesProvider = Provider<RemoveCopies>(
  (ref) => RemoveCopies(ref.watch(shelfRepositoryProvider)),
);

/// The logged-in librarian's idle books (null without a library).
final idleShelfProvider = FutureProvider.autoDispose<IdleShelf?>((ref) async {
  final userId = ref.watch(sessionProvider.select((s) => s.userId));
  if (userId == null) return null;

  final library = await ref.watch(userLibraryProvider(userId).future);
  if (library == null) return null;

  return ref.watch(getIdleBooksProvider).call(library.libraryId);
});
