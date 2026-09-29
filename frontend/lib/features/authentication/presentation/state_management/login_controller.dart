import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/cache/app_cache_warmer.dart';
import 'package:readiculous_frontend/core/constants/app_roles.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/core/utils/app_logger.dart';
import 'package:readiculous_frontend/shared/genres/presentation/state_management/genres_providers.dart';

import 'auth_providers.dart';

// ── Controller ───────────────────────────────────────────────────────────────

/// AsyncNotifier<void> is used because:
///   - loading  → AsyncLoading()
///   - success  → AsyncData(null)   (navigation is handled in the UI layer)
///   - failure  → AsyncError(e, st)
class LoginController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No initial async work needed — start in the idle/data state.
  }

  /// Called by the UI when the user taps "Login".
  Future<void> login({
    required String email,
    required String password,
  }) async {
    // Switch to loading and clear any previous error.
    state = const AsyncLoading();

    try {
      final user = await ref
          .read(loginUserProvider)
          .call(email: email, password: password);
      if (!ref.mounted) return;

      // Resolve genre-prefs status BEFORE establishing the session so the
      // router never sees a logged-in session with hasGenrePrefs still
      // unknown — that intermediate state was causing GoRouter to redirect
      // to the onboarding screen even for users who already had prefs set,
      // and the redirect unmounted this (autoDispose) controller before it
      // could correct the flag afterward.
      bool hasGenrePrefs = false;
      if (user.role == AppRoles.user) {
        try {
          final genres = await ref.read(getUserGenresProvider).call(user.userId);
          hasGenrePrefs = genres.isNotEmpty;
        } catch (e, st) {
          AppLogger.e('Failed to fetch genre prefs during login: $e',
              error: e, stackTrace: st);
        }
      }
      if (!ref.mounted) return;

      await ref.read(sessionProvider.notifier).setSession(
            userId: user.userId,
            role: user.role,
            email: email,
            hasGenrePrefs: hasGenrePrefs,
          );

      AppCacheWarmer.warmForLoggedInUser(user.userId);

      // Signal success — the page will navigate in response.
      if (!ref.mounted) return;
      state = const AsyncData(null);
    } catch (e, st) {
      // Carry the original ApiError so the UI can display it.
      if (!ref.mounted) return;
      state = AsyncError(e, st);
    }
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

/// AutoDispose: the controller (and any in-flight request) is cleaned up
/// automatically when the login page leaves the tree.
final loginControllerProvider =
    AsyncNotifierProvider.autoDispose<LoginController, void>(
  LoginController.new,
);
