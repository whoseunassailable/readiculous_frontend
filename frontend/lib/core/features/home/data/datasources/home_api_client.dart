import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../dtos/library_response_dto.dart';

part 'home_api_client.g.dart';

@RestApi()
abstract class HomeApiClient {
  factory HomeApiClient(Dio dio, {String? baseUrl}) = _HomeApiClient;

  @GET('/users/{userId}/library')
  Future<LibraryResponseDto> getUserLibrary(@Path('userId') String userId);
}
