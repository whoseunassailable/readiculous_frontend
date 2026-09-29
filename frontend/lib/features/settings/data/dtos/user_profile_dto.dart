import '../../domain/entities/user_profile.dart';

class UserProfileDto {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String location;
  final String? phone;
  final String? dateOfBirth;

  const UserProfileDto({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.location,
    this.phone,
    this.dateOfBirth,
  });

  /// Reads GET/PUT /users/:id. Also reads the smaller profile the login
  /// response caches (no phone, date of birth or location).
  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    final dob = json['date_of_birth'] as String?;
    return UserProfileDto(
      userId: json['user_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      location: json['location'] as String? ?? '',
      phone: json['phone'] as String?,
      // The API sends yyyy-MM-dd; older cached copies hold a full timestamp.
      dateOfBirth: dob == null || dob.length < 10 ? dob : dob.substring(0, 10),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'role': role,
        'location': location,
        'phone': phone,
        'date_of_birth': dateOfBirth,
      };

  UserProfile toEntity() => UserProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role,
        location: location,
        phone: phone,
        dateOfBirth: dateOfBirth,
      );
}
