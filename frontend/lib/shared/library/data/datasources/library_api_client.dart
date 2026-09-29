import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../dtos/library_association_requests_dto.dart';
import '../dtos/library_dto.dart';
import '../dtos/user_library_response_dto.dart';

part 'library_api_client.g.dart';

@RestApi()
abstract class LibraryApiClient {
  factory LibraryApiClient(Dio dio, {String? baseUrl}) = _LibraryApiClient;

  /// Every library (~16.5k rows, ~2.9 MB).
  @GET('/libraries/')
  Future<List<LibraryDto>> getAllLibraries();

  @GET('/users/{userId}/library')
  Future<UserLibraryResponseDto> getUserLibrary(@Path('userId') String userId);

  /// Readers only; the backend rejects librarians (400).
  @POST('/users/{userId}/library')
  Future<void> setUserLibrary(
    @Path('userId') String userId,
    @Body() SetUserLibraryRequestDto body,
  );

  @POST('/librarians/assign')
  Future<void> assignLibrarian(@Body() AssignLibrarianRequestDto body);
}
