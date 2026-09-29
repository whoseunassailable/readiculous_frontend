import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_error.dart';
import '../../../../core/session/session_provider.dart';
import '../../../../shared/genres/presentation/state_management/genres_providers.dart';

/// Saves the reader's genre preferences, from onboarding or the preferences
/// page. loading → AsyncLoading, saved → AsyncData, failed → AsyncError.
class GenrePreferencesController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> save(Set<int> genreIds) async {
    final userId = ref.read(sessionProvider).userId;
    if (userId == null) {
      state = AsyncError(
          const ApiError(message: 'Not logged in'), StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    try {
      await ref.read(saveUserGenresProvider).call(userId, genreIds);
      if (!ref.mounted) return;

      // Unlocks the app for readers coming from onboarding.
      await ref.read(sessionProvider.notifier).markGenrePrefsSet();
      ref.invalidate(userGenresProvider);

      if (!ref.mounted) return;
      state = const AsyncData(null);
    } catch (e, st) {
      if (!ref.mounted) return;
      state = AsyncError(e, st);
    }
  }
}

final genrePreferencesControllerProvider =
    AsyncNotifierProvider.autoDispose<GenrePreferencesController, void>(
  GenrePreferencesController.new,
);
