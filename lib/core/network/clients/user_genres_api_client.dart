import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'user_genres_api_client.g.dart';

@RestApi()
abstract class UserGenresApiClient {
  factory UserGenresApiClient(Dio dio, {String? baseUrl}) =
      _UserGenresApiClient;

  @POST('/user-genres/')
  Future<Map<String, dynamic>> addUserGenrePreferences(
      @Body() Map<String, dynamic> body);

  @GET('/user-genres/{userId}')
  Future<List<dynamic>> getUserGenrePreferences(@Path('userId') String userId);

  @DELETE('/user-genres/{userId}/{genreId}')
  Future<void> removeUserGenrePreference(
    @Path('userId') String userId,
    @Path('genreId') String genreId,
  );
}
