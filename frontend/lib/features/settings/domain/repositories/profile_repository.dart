import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile(String userId);

  Future<UserProfile> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String location,
    String? phone,
    String? dateOfBirth,
  });

  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  });
}
