import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repo;

  const RegisterUser(this.repo);

  Future<User> call({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String dateOfBirth,
    required String password,
    required String location,
    required String role,
  }) =>
      repo.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        dateOfBirth: dateOfBirth,
        password: password,
        location: location,
        role: role,
      );
}
