import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/core/network/api_error.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/features/settings/domain/entities/user_profile.dart';
import 'package:readiculous_frontend/features/settings/domain/repositories/profile_repository.dart';
import 'package:readiculous_frontend/features/settings/presentation/state_management/change_password_controller.dart';
import 'package:readiculous_frontend/features/settings/presentation/state_management/edit_profile_controller.dart';
import 'package:readiculous_frontend/features/settings/presentation/state_management/profile_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepository implements ProfileRepository {
  ApiError? error;
  int profileFetches = 0;
  Map<String, String?>? lastUpdate;
  (String, String)? lastPasswordChange;

  UserProfile _profile(String email) => UserProfile(
        userId: 'u1',
        firstName: 'Ava',
        lastName: 'Martinez',
        email: email,
        role: 'user',
        location: 'Chicago',
      );

  @override
  Future<UserProfile> getProfile(String userId) async {
    profileFetches++;
    return _profile('ava@example.com');
  }

  @override
  Future<UserProfile> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String location,
    String? phone,
    String? dateOfBirth,
  }) async {
    if (error != null) throw error!;
    lastUpdate = {'firstName': firstName, 'email': email, 'phone': phone};
    return _profile(email);
  }

  @override
  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (error != null) throw error!;
    lastPasswordChange = (currentPassword, newPassword);
  }
}

Future<(ProviderContainer, _FakeRepository)> _loggedIn() async {
  SharedPreferences.setMockInitialValues({});
  final repo = _FakeRepository();
  final c = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(repo)]);
  addTearDown(c.dispose);
  await c
      .read(sessionProvider.notifier)
      .setSession(userId: 'u1', role: 'user', email: 'ava@example.com');
  c.listen(editProfileControllerProvider, (_, __) {});
  c.listen(changePasswordControllerProvider, (_, __) {});
  return (c, repo);
}

Future<void> _save(ProviderContainer c, {String email = 'ava@example.com'}) =>
    c.read(editProfileControllerProvider.notifier).save(
          firstName: 'Ava',
          lastName: 'Martinez',
          email: email,
          location: 'Chicago',
        );

void main() {
  group('EditProfileController', () {
    test('saves and refreshes the profile', () async {
      final (c, repo) = await _loggedIn();
      c.listen(currentUserProfileProvider, (_, __) {});
      await c.read(currentUserProfileProvider.future);
      final fetchesBefore = repo.profileFetches;

      await _save(c);
      await c.read(currentUserProfileProvider.future);

      expect(repo.lastUpdate?['firstName'], 'Ava');
      expect(c.read(editProfileControllerProvider), isA<AsyncData<void>>());
      expect(repo.profileFetches, greaterThan(fetchesBefore));
    });

    test('a new email is written to the session', () async {
      final (c, _) = await _loggedIn();

      await _save(c, email: 'ava.new@example.com');

      expect(c.read(sessionProvider).email, 'ava.new@example.com');
    });

    test('failure ⇒ AsyncError with the server message', () async {
      final (c, repo) = await _loggedIn();
      repo.error =
          const ApiError(statusCode: 409, message: 'Email already exists');

      await _save(c, email: 'taken@example.com');

      expect(c.read(editProfileControllerProvider).error.toString(),
          'Email already exists');
      expect(c.read(sessionProvider).email, 'ava@example.com');
    });
  });

  group('ChangePasswordController', () {
    test('changes the password', () async {
      final (c, repo) = await _loggedIn();

      await c
          .read(changePasswordControllerProvider.notifier)
          .change(currentPassword: 'Old@1234', newPassword: 'New@12345');

      expect(repo.lastPasswordChange, ('Old@1234', 'New@12345'));
      expect(c.read(changePasswordControllerProvider), isA<AsyncData<void>>());
    });

    test('wrong current password ⇒ AsyncError', () async {
      final (c, repo) = await _loggedIn();
      repo.error = const ApiError(
          statusCode: 401, message: 'Current password is incorrect');

      await c
          .read(changePasswordControllerProvider.notifier)
          .change(currentPassword: 'wrong', newPassword: 'New@12345');

      expect(c.read(changePasswordControllerProvider).error.toString(),
          'Current password is incorrect');
    });
  });
}
