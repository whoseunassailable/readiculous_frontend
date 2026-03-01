import '../../domain/entities/book.dart';
import '../../domain/entities/library.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remote;

  const HomeRepositoryImpl(this.remote);

  @override
  Future<Book> getFeaturedBook() async {
    final dto = await remote.fetchFeaturedBook();
    return dto.toEntity();
  }

  @override
  Future<Library?> getUserLibrary(String userId) async {
    final dto = await remote.fetchUserLibrary(userId);
    return dto?.toEntity();
  }
}
