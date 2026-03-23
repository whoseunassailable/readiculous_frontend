import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'book_genres_api_client.g.dart';

@RestApi()
abstract class BookGenresApiClient {
  factory BookGenresApiClient(Dio dio, {String? baseUrl}) =
      _BookGenresApiClient;

  @POST('/book-genres/')
  Future<Map<String, dynamic>> assignGenresToBook(
      @Body() Map<String, dynamic> body);

  @GET('/book-genres/{bookId}')
  Future<List<dynamic>> getGenresForBook(@Path('bookId') String bookId);

  @DELETE('/book-genres/{bookId}/{genreId}')
  Future<void> removeGenreFromBook(
    @Path('bookId') String bookId,
    @Path('genreId') String genreId,
  );
}
