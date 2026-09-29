import '../../../../core/network/dio_client.dart';
import '../dtos/library_association_requests_dto.dart';
import '../dtos/library_dto.dart';
import 'library_api_client.dart';

abstract class LibraryRemoteDataSource {
  Future<List<LibraryDto>> fetchAllLibraries();
  Future<LibraryDto?> fetchUserLibrary(String userId);
  Future<void> setUserLibrary(String userId, int libraryId);
  Future<void> assignLibrarian(String userId, int libraryId);
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  final LibraryApiClient _client = LibraryApiClient(DioClient.main);

  @override
  Future<List<LibraryDto>> fetchAllLibraries() => _client.getAllLibraries();

  @override
  Future<LibraryDto?> fetchUserLibrary(String userId) async {
    final response = await _client.getUserLibrary(userId);
    return response.library;
  }

  @override
  Future<void> setUserLibrary(String userId, int libraryId) => _client
      .setUserLibrary(userId, SetUserLibraryRequestDto(libraryId: libraryId));

  @override
  Future<void> assignLibrarian(String userId, int libraryId) =>
      _client.assignLibrarian(
          AssignLibrarianRequestDto(userId: userId, libraryId: libraryId));
}
