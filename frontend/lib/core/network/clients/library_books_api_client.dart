import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'library_books_api_client.g.dart';

@RestApi()
abstract class LibraryBooksApiClient {
  factory LibraryBooksApiClient(Dio dio, {String? baseUrl}) =
      _LibraryBooksApiClient;

  @GET('/library-books/{libraryId}')
  Future<List<dynamic>> getBooksInLibrary(@Path('libraryId') String libraryId);

  @POST('/library-books/')
  Future<Map<String, dynamic>> addOrUpdateBookInventory(
      @Body() Map<String, dynamic> body);
}
