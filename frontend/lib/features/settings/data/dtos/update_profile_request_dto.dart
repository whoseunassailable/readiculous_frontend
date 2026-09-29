class UpdateProfileRequestDto {
  final String firstName;
  final String lastName;
  final String email;
  final String location;
  final String? phone;
  final String? dateOfBirth;

  const UpdateProfileRequestDto({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.location,
    this.phone,
    this.dateOfBirth,
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'location': location,
        'phone': phone,
        'date_of_birth': dateOfBirth,
      };
}
