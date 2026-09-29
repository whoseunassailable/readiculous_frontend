import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_error.dart';
import '../../../../core/session/session_provider.dart';
import 'profile_providers.dart';

/// Changes the logged-in user's password. loading → AsyncLoading, changed →
/// AsyncData, failed (e.g. wrong current password) → AsyncError.
class ChangePasswordController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> change({
    required String currentPassword,
    required String newPassword,
  }) async {
    final userId = ref.read(sessionProvider).userId;
    if (userId == null) {
      state = AsyncError(
          const ApiError(message: 'Not logged in'), StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    try {
      await ref.read(changePasswordProvider).call(
            userId: userId,
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
      if (!ref.mounted) return;
      state = const AsyncData(null);
    } catch (e, st) {
      if (!ref.mounted) return;
      state = AsyncError(e, st);
    }
  }
}

final changePasswordControllerProvider =
    AsyncNotifierProvider.autoDispose<ChangePasswordController, void>(
  ChangePasswordController.new,
);
