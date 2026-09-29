import '../entities/library.dart';
import '../repositories/home_repository.dart';

class GetUserLibrary {
  final HomeRepository repo;
  GetUserLibrary(this.repo);

  Future<Library?> call(String userId) => repo.getUserLibrary(userId);
}
