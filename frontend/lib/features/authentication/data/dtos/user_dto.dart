import '../../domain/entities/user.dart';

class UserDto {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String role;

  const UserDto({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      userId: json['user_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'role': role,
      };

  User toEntity() => User(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role,
      );
}
