import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'trends_api_client.g.dart';

@RestApi()
abstract class TrendsApiClient {
  factory TrendsApiClient(Dio dio, {String? baseUrl}) = _TrendsApiClient;

  @GET('/trends/libraries/{libraryId}')
  Future<List<dynamic>> getLibraryTrends(@Path('libraryId') String libraryId);

  /// Pass [libraryId] to scope to a specific library, or omit for global.
  @GET('/trends/top')
  Future<List<dynamic>> getTopTrends(
      {@Query('library_id') String? libraryId});

  @POST('/trends/')
  Future<Map<String, dynamic>> upsertTrendScore(
      @Body() Map<String, dynamic> body);
}
