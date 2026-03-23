import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'books_api_client.g.dart';

@RestApi()
abstract class BooksApiClient {
  factory BooksApiClient(Dio dio, {String? baseUrl}) = _BooksApiClient;

  @GET('/books/')
  Future<List<dynamic>> getAllBooks();

  @GET('/books/{bookId}')
  Future<Map<String, dynamic>> getBook(@Path('bookId') String bookId);

  @POST('/books/')
  Future<Map<String, dynamic>> createBook(@Body() Map<String, dynamic> body);

  @PUT('/books/{bookId}')
  Future<Map<String, dynamic>> updateBook(
    @Path('bookId') String bookId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/books/{bookId}')
  Future<void> deleteBook(@Path('bookId') String bookId);
}
