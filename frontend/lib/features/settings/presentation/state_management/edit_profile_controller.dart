import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_error.dart';
import '../../../../core/session/session_provider.dart';
import 'profile_providers.dart';

/// Saves profile edits. loading → AsyncLoading, saved → AsyncData, failed →
/// AsyncError (the page shows the message and stays open).
class EditProfileController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> save({
    required String firstName,
    required String lastName,
    required String email,
    required String location,
    String? phone,
    String? dateOfBirth,
  }) async {
    final session = ref.read(sessionProvider);
    final userId = session.userId;
    if (userId == null) {
      state = AsyncError(
          const ApiError(message: 'Not logged in'), StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    try {
      final profile = await ref.read(updateProfileProvider).call(
            userId: userId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            location: location,
            phone: phone,
            dateOfBirth: dateOfBirth,
          );
      if (!ref.mounted) return;

      // The session remembers the email used to log in; keep it in step.
      if (profile.email != session.email) {
        await ref.read(sessionProvider.notifier).setEmail(profile.email);
      }
      ref.invalidate(currentUserProfileProvider);

      if (!ref.mounted) return;
      state = const AsyncData(null);
    } catch (e, st) {
      if (!ref.mounted) return;
      state = AsyncError(e, st);
    }
  }
}

final editProfileControllerProvider =
    AsyncNotifierProvider.autoDispose<EditProfileController, void>(
  EditProfileController.new,
);
