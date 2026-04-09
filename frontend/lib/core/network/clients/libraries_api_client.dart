import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'libraries_api_client.g.dart';

@RestApi()
abstract class LibrariesApiClient {
  factory LibrariesApiClient(Dio dio, {String? baseUrl}) = _LibrariesApiClient;

  @GET('/libraries/')
  Future<List<dynamic>> getAllLibraries();

  @GET('/libraries/{libraryId}/activity')
  Future<List<dynamic>> getLibraryReaderActivity(
      @Path('libraryId') String libraryId);

  @POST('/libraries/')
  Future<Map<String, dynamic>> createLibrary(@Body() Map<String, dynamic> body);
}
