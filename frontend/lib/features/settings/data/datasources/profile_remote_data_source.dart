import '../../../../core/network/dio_client.dart';
import '../dtos/change_password_request_dto.dart';
import '../dtos/update_profile_request_dto.dart';
import '../dtos/user_profile_dto.dart';
import 'profile_api_client.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileDto> fetchProfile(String userId);
  Future<UserProfileDto> updateProfile(
      String userId, UpdateProfileRequestDto request);
  Future<void> changePassword(String userId, ChangePasswordRequestDto request);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ProfileApiClient _client = ProfileApiClient(DioClient.main);

  @override
  Future<UserProfileDto> fetchProfile(String userId) =>
      _client.getProfile(userId);

  @override
  Future<UserProfileDto> updateProfile(
      String userId, UpdateProfileRequestDto request) async {
    final response = await _client.updateProfile(userId, request);
    return response.user;
  }

  @override
  Future<void> changePassword(
          String userId, ChangePasswordRequestDto request) =>
      _client.changePassword(userId, request);
}
