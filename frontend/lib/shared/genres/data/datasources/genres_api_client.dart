import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../dtos/add_user_genres_request_dto.dart';
import '../dtos/genre_dto.dart';

part 'genres_api_client.g.dart';

@RestApi()
abstract class GenresApiClient {
  factory GenresApiClient(Dio dio, {String? baseUrl}) = _GenresApiClient;

  @GET('/genres/')
  Future<List<GenreDto>> getAllGenres();

  @GET('/user-genres/{userId}')
  Future<List<GenreDto>> getUserGenres(@Path('userId') String userId);

  /// Adds preferences; genres the user already has are ignored.
  @POST('/user-genres/')
  Future<void> addUserGenres(@Body() AddUserGenresRequestDto body);

  /// 404 if the user doesn't have this genre.
  @DELETE('/user-genres/{userId}/{genreId}')
  Future<void> removeUserGenre(
    @Path('userId') String userId,
    @Path('genreId') int genreId,
  );
}
