import '../../../../core/network/dio_client.dart';
import '../dtos/library_dto.dart';
import 'home_api_client.dart';

abstract class HomeRemoteDataSource {
  Future<LibraryDto?> fetchUserLibrary(String userId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final HomeApiClient _client = HomeApiClient(DioClient.main);

  @override
  Future<LibraryDto?> fetchUserLibrary(String userId) async {
    final response = await _client.getUserLibrary(userId);
    return response.library;
  }
}
