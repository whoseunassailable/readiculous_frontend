import '../../../../core/network/dio_client.dart';
import '../dtos/genre_trend_dto.dart';
import 'trends_api_client.dart';

abstract class TrendsRemoteDataSource {
  Future<List<GenreTrendDto>> fetchTopTrends(int libraryId);
}

class TrendsRemoteDataSourceImpl implements TrendsRemoteDataSource {
  final TrendsApiClient _client = TrendsApiClient(DioClient.main);

  @override
  Future<List<GenreTrendDto>> fetchTopTrends(int libraryId) =>
      _client.getTopTrends(libraryId);
}
