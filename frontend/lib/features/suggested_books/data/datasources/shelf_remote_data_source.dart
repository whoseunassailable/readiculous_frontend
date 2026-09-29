import '../../../../core/network/dio_client.dart';
import '../dtos/idle_shelf_dto.dart';
import 'shelf_api_client.dart';

abstract class ShelfRemoteDataSource {
  Future<IdleShelfDto> fetchIdleBooks(int libraryId);
  Future<void> removeCopies(int libraryId, int bookId, int copies);
}

class ShelfRemoteDataSourceImpl implements ShelfRemoteDataSource {
  final ShelfApiClient _client = ShelfApiClient(DioClient.main);

  @override
  Future<IdleShelfDto> fetchIdleBooks(int libraryId) =>
      _client.getIdleBooks(libraryId);

  @override
  Future<void> removeCopies(int libraryId, int bookId, int copies) => _client
      .removeCopies(libraryId, bookId, RemoveCopiesRequestDto(copies: copies));
}
