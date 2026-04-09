class UserModel {
  String? userId;
  String firstName;
  String lastName;
  String email;
  String phone;
  String dateOfBirth;
  String password;
  String location;
  String role;

  UserModel({
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.password,
    required this.location,
    this.role = 'user',
  });

  UserModel copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? password,
    String? location,
    String? role,
  }) =>
      UserModel(
        userId: userId ?? this.userId,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        password: password ?? this.password,
        location: location ?? this.location,
        role: role ?? this.role,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userId: json["user_id"]?.toString(),
        firstName: json["first_name"] ?? "",
        lastName: json["last_name"] ?? "",
        email: json["email"] ?? "",
        phone: json["phone"] ?? "",
        dateOfBirth: json["date_of_birth"] ?? "",
        password: json["password"] ?? "",
        location: json["location"] ?? "",
        role: json["role"] ?? "user",
      );

  Map<String, dynamic> toJson() => {
        if (userId != null) "user_id": userId,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone": phone,
        "date_of_birth": dateOfBirth,
        "password": password,
        "location": location,
        "role": role,
      };
}
