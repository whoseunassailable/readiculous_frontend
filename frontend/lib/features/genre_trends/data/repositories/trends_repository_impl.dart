import 'package:dio/dio.dart';

import '../../../../core/network/api_error.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/genre_trend.dart';
import '../../domain/repositories/trends_repository.dart';
import '../datasources/trends_remote_data_source.dart';

class TrendsRepositoryImpl implements TrendsRepository {
  final TrendsRemoteDataSource remote;

  const TrendsRepositoryImpl(this.remote);

  @override
  Future<List<GenreTrend>> getTopTrends(int libraryId) async {
    try {
      final dtos = await remote.fetchTopTrends(libraryId);
      return dtos.map((dto) => dto.toEntity()).toList();
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('getTopTrends failed (libraryId: $libraryId)', error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e('getTopTrends unexpected error (libraryId: $libraryId)',
          error: e, stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }
}
