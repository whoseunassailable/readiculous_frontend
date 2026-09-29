import 'user_dto.dart';

class RegisterResponseDto {
  final UserDto user;

  RegisterResponseDto({required this.user});

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) {
    return RegisterResponseDto(
      user: UserDto.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
