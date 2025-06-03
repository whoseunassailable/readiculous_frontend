class StudentModel {
  String? studentId; // Nullable
  String firstName;
  String lastName;
  String email;
  String phone;
  String dateOfBirth;
  String password;
  String location; // New required field

  StudentModel({
    this.studentId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.password,
    required this.location, // Add in constructor
  });

  StudentModel copyWith({
    String? studentId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? password,
    String? location, // Add in copyWith
  }) =>
      StudentModel(
        studentId: studentId ?? this.studentId,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        password: password ?? this.password,
        location: location ?? this.location,
      );

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        studentId: json["student_id"]?.toString(),
        firstName: json["first_name"] ?? "",
        lastName: json["last_name"] ?? "",
        email: json["email"] ?? "",
        phone: json["phone"] ?? "",
        dateOfBirth: json["date_of_birth"] ?? "",
        password: json["password"] ?? "",
        location: json["location"] ?? "", // Parse from JSON
      );

  Map<String, dynamic> toJson() => {
        if (studentId != null) "student_id": studentId,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone": phone,
        "date_of_birth": dateOfBirth,
        "password": password,
        "location": location, // Include in serialization
      };
}
