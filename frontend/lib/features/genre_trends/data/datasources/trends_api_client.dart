import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../dtos/genre_trend_dto.dart';

part 'trends_api_client.g.dart';

@RestApi()
abstract class TrendsApiClient {
  factory TrendsApiClient(Dio dio, {String? baseUrl}) = _TrendsApiClient;

  /// Current trend score per genre for a library, highest first.
  @GET('/trends/top')
  Future<List<GenreTrendDto>> getTopTrends(@Query('library_id') int libraryId);
}
