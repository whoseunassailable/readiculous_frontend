import '../entities/library.dart';
import '../repositories/library_repository.dart';

class GetAllLibraries {
  final LibraryRepository repo;

  const GetAllLibraries(this.repo);

  Future<List<Library>> call() => repo.getAllLibraries();
}
