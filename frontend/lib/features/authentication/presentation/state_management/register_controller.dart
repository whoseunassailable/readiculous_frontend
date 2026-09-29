import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';

import 'auth_providers.dart';

// ── Controller ───────────────────────────────────────────────────────────────

/// AsyncNotifier<void> is used because:
///   - loading  → AsyncLoading()
///   - success  → AsyncData(null)   (navigation is handled in the UI layer)
///   - failure  → AsyncError(e, st)
class RegisterController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No initial async work needed — start in the idle/data state.
  }

  /// Called by the UI once the form has passed validation.
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String dateOfBirth,
    required String password,
    required String location,
    required String role,
  }) async {
    state = const AsyncLoading();

    try {
      final user = await ref.read(registerUserProvider).call(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            dateOfBirth: dateOfBirth,
            password: password,
            location: location,
            role: role,
          );
      if (!ref.mounted) return;

      await ref.read(sessionProvider.notifier).setSession(
            userId: user.userId,
            email: user.email,
            role: user.role,
          );

      if (!ref.mounted) return;
      state = const AsyncData(null);
    } catch (e, st) {
      if (!ref.mounted) return;
      state = AsyncError(e, st);
    }
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final registerControllerProvider =
    AsyncNotifierProvider.autoDispose<RegisterController, void>(
  RegisterController.new,
);
