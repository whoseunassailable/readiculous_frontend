import '../repositories/profile_repository.dart';

class ChangePassword {
  final ProfileRepository repo;

  const ChangePassword(this.repo);

  Future<void> call({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) =>
      repo.changePassword(
        userId: userId,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
}
