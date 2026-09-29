class RegisterRequestDto {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String password;
  final String location;
  final String role;

  const RegisterRequestDto({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.password,
    required this.location,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'date_of_birth': dateOfBirth,
        'password': password,
        'location': location,
        'role': role,
      };
}
