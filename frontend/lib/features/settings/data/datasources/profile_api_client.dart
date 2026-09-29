import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../dtos/change_password_request_dto.dart';
import '../dtos/update_profile_request_dto.dart';
import '../dtos/update_profile_response_dto.dart';
import '../dtos/user_profile_dto.dart';

part 'profile_api_client.g.dart';

@RestApi()
abstract class ProfileApiClient {
  factory ProfileApiClient(Dio dio, {String? baseUrl}) = _ProfileApiClient;

  @GET('/users/{userId}')
  Future<UserProfileDto> getProfile(@Path('userId') String userId);

  @PUT('/users/{userId}')
  Future<UpdateProfileResponseDto> updateProfile(
    @Path('userId') String userId,
    @Body() UpdateProfileRequestDto body,
  );

  @PUT('/users/{userId}/password')
  Future<void> changePassword(
    @Path('userId') String userId,
    @Body() ChangePasswordRequestDto body,
  );
}
