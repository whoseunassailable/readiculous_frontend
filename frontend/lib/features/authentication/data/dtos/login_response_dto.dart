import 'user_dto.dart';

class LoginResponseDto {
  final UserDto user;

  LoginResponseDto({required this.user});

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
