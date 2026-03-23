import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'genres_api_client.g.dart';

@RestApi()
abstract class GenresApiClient {
  factory GenresApiClient(Dio dio, {String? baseUrl}) = _GenresApiClient;

  @GET('/genres/')
  Future<List<dynamic>> getAllGenres();

  @POST('/genres/')
  Future<Map<String, dynamic>> createGenre(@Body() Map<String, dynamic> body);

  @DELETE('/genres/{genreId}')
  Future<void> deleteGenre(@Path('genreId') String genreId);
}
