import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'reads_api_client.g.dart';

@RestApi()
abstract class ReadsApiClient {
  factory ReadsApiClient(Dio dio, {String? baseUrl}) = _ReadsApiClient;

  @GET('/reads/{userId}')
  Future<List<dynamic>> getUserReadingList(@Path('userId') String userId);

  @POST('/reads/')
  Future<Map<String, dynamic>> addOrUpdateRead(
      @Body() Map<String, dynamic> body);

  @DELETE('/reads/{userId}/{bookId}')
  Future<void> removeFromReadingList(
    @Path('userId') String userId,
    @Path('bookId') String bookId,
  );
}
