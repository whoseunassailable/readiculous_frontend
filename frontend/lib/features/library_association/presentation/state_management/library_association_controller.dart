import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_roles.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/session/session_provider.dart';
import '../../../../shared/library/domain/entities/library.dart';
import '../../../../shared/library/presentation/state_management/library_providers.dart';

/// Every library, sorted by name. Kept in memory for the app run (~16.5k
/// rows) and fetched the first time someone opens Choose Library.
final allLibrariesProvider = FutureProvider<List<Library>>(
  (ref) => ref.watch(getAllLibrariesProvider).call(),
);

/// Saves the user's library choice. loading → AsyncLoading, saved →
/// AsyncData, failed → AsyncError.
class LibraryAssociationController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> save(int libraryId) async {
    final session = ref.read(sessionProvider);
    final userId = session.userId;
    if (userId == null) {
      state = AsyncError(
          const ApiError(message: 'Not logged in'), StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    try {
      await ref.read(chooseLibraryProvider).call(
            userId,
            libraryId,
            asLibrarian: session.role == AppRoles.librarian,
          );
      if (!ref.mounted) return;

      // Refetches the user's library; screens showing it (and its books,
      // picks and trends) follow.
      ref.invalidate(userLibraryProvider(userId));
      state = const AsyncData(null);
    } catch (e, st) {
      if (!ref.mounted) return;
      state = AsyncError(e, st);
    }
  }
}

final libraryAssociationControllerProvider =
    AsyncNotifierProvider.autoDispose<LibraryAssociationController, void>(
  LibraryAssociationController.new,
);
