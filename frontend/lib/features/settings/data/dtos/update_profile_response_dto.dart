import 'user_profile_dto.dart';

class UpdateProfileResponseDto {
  final UserProfileDto user;

  UpdateProfileResponseDto({required this.user});

  factory UpdateProfileResponseDto.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponseDto(
      user: UserProfileDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
