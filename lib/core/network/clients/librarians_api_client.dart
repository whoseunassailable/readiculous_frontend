import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'librarians_api_client.g.dart';

@RestApi()
abstract class LibrariansApiClient {
  factory LibrariansApiClient(Dio dio, {String? baseUrl}) =
      _LibrariansApiClient;

  @POST('/librarians/assign')
  Future<Map<String, dynamic>> assignLibrarian(
      @Body() Map<String, dynamic> body);

  @GET('/librarians/{libraryId}')
  Future<List<dynamic>> getLibrariansForLibrary(
      @Path('libraryId') String libraryId);

  @DELETE('/librarians/{userId}/{libraryId}')
  Future<void> unassignLibrarian(
    @Path('userId') String userId,
    @Path('libraryId') String libraryId,
  );
}
