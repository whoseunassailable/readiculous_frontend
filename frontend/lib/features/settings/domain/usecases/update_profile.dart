import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repo;

  const UpdateProfile(this.repo);

  Future<UserProfile> call({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String location,
    String? phone,
    String? dateOfBirth,
  }) =>
      repo.updateProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        location: location,
        phone: phone,
        dateOfBirth: dateOfBirth,
      );
}
