import '../../../../utils/app_logger.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/library.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remote;

  const HomeRepositoryImpl(this.remote);

  @override
  Future<Book> getFeaturedBook() async {
    try {
      final dto = await remote.fetchFeaturedBook();
      return dto.toEntity();
    } catch (e, st) {
      AppLogger.e('getFeaturedBook failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<Library?> getUserLibrary(String userId) async {
    try {
      final dto = await remote.fetchUserLibrary(userId);
      return dto?.toEntity();
    } catch (e, st) {
      AppLogger.e('getUserLibrary failed (userId: $userId)',
          error: e, stackTrace: st);
      rethrow;
    }
  }
}
