import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../dtos/idle_shelf_dto.dart';

part 'shelf_api_client.g.dart';

@RestApi()
abstract class ShelfApiClient {
  factory ShelfApiClient(Dio dio, {String? baseUrl}) = _ShelfApiClient;

  /// Books nobody has read, borrowed or asked for in months.
  @GET('/library-books/{libraryId}/idle')
  Future<IdleShelfDto> getIdleBooks(@Path('libraryId') int libraryId);

  @POST('/library-books/{libraryId}/{bookId}/remove')
  Future<void> removeCopies(
    @Path('libraryId') int libraryId,
    @Path('bookId') int bookId,
    @Body() RemoveCopiesRequestDto body,
  );
}
