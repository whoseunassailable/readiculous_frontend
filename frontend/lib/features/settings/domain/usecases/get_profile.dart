import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile {
  final ProfileRepository repo;

  const GetProfile(this.repo);

  Future<UserProfile> call(String userId) => repo.getProfile(userId);
}
