import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repo;

  const LoginUser(this.repo);

  Future<User> call({required String email, required String password}) =>
      repo.login(email: email, password: password);
}
