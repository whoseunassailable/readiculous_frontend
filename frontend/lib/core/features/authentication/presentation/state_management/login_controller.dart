// lib/core/features/authentication/presentation/state_management/login_controller.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/cache/app_cache_service.dart';
import 'package:readiculous_frontend/core/cache/app_cache_warmer.dart';

import '../../data/data_sources/auth_remote_ds.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../network/api_error.dart';
import '../../../../network/clients/user_genres_api_client.dart';
import '../../../../network/dio_client.dart';
import '../../../../session/session_provider.dart';

// ── State ────────────────────────────────────────────────────────────────────

/// Represents the outcome of a login attempt.
/// AsyncNotifier<void> is used because:
///   - loading  → AsyncLoading()
///   - success  → AsyncData(null)   (navigation is handled in the UI layer)
///   - failure  → AsyncError(e, st)
typedef LoginState = AsyncValue<void>;

// ── Controller ───────────────────────────────────────────────────────────────

class LoginController extends AsyncNotifier<void> {
  late final _authRepo = AuthRepositoryImpl(AuthRemoteDataSource());

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

    final result = await _authRepo.login(email: email, password: password);
    if (!ref.mounted) return;

    if (result.isSuccess) {
      final payload = result.data;
      final user = payload?['user'];
      if (user is! Map<String, dynamic>) {
        if (!ref.mounted) return;
        state = AsyncError(
          ApiError(
            message: 'Invalid login response',
            details: payload.toString(),
          ),
          StackTrace.current,
        );
        return;
      }

      final userMap = user;
      final userId = userMap['user_id']?.toString();
      final role = userMap['role']?.toString();
      if (userId == null || userId.isEmpty || role == null || role.isEmpty) {
        if (!ref.mounted) return;
        state = AsyncError(
          ApiError(
            message: 'Login response missing session fields',
            details: payload.toString(),
          ),
          StackTrace.current,
        );
        return;
      }

      await ref.read(sessionProvider.notifier).setSession(
            userId: userId,
            role: role,
            email: email,
            password: password,
          );
      if (!ref.mounted) return;
      await AppCacheService.instance.saveCurrentUserProfile(userMap);

      if (role == 'user') {
        try {
          final genres = await UserGenresApiClient(DioClient.main)
              .getUserGenrePreferences(userId);
          if (!ref.mounted) return;
          await ref
              .read(sessionProvider.notifier)
              .setGenrePrefsStatus(genres.isNotEmpty);
        } catch (_) {
          if (!ref.mounted) return;
          await ref.read(sessionProvider.notifier).setGenrePrefsStatus(false);
        }
      } else {
        if (!ref.mounted) return;
        await ref.read(sessionProvider.notifier).setGenrePrefsStatus(false);
      }

      unawaited(AppCacheWarmer.warmForLoggedInUser(userId));

      // Signal success — the page will navigate in response.
      if (!ref.mounted) return;
      state = const AsyncData(null);
    } else {
      final error = result.error!;
      if (!ref.mounted) return;
      state = AsyncError(
        // Carry the original ApiError so the UI can display it.
        error,
        StackTrace.current,
      );
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
