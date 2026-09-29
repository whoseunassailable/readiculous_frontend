import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../dtos/genre_dto.dart';

part 'genres_api_client.g.dart';

@RestApi()
abstract class GenresApiClient {
  factory GenresApiClient(Dio dio, {String? baseUrl}) = _GenresApiClient;

  @GET('/user-genres/{userId}')
  Future<List<GenreDto>> getUserGenres(@Path('userId') String userId);
}
