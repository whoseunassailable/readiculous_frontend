import '../entities/library.dart';

abstract class HomeRepository {
  Future<Library?> getUserLibrary(String userId);
}
