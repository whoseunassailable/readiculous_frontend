class UserProfile {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String location;
  final String? phone;

  /// Calendar date as `yyyy-MM-dd` (no time, so no timezone shifts).
  final String? dateOfBirth;

  const UserProfile({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.location,
    this.phone,
    this.dateOfBirth,
  });
}
