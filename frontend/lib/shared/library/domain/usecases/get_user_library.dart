import '../entities/library.dart';
import '../repositories/library_repository.dart';

class GetUserLibrary {
  final LibraryRepository repo;

  const GetUserLibrary(this.repo);

  Future<Library?> call(String userId) => repo.getUserLibrary(userId);
}
