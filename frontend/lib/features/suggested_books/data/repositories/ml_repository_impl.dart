import 'package:dio/dio.dart';

import '../../../../core/network/api_error.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/repositories/ml_repository.dart';
import '../datasources/ml_remote_data_source.dart';

class MlRepositoryImpl implements MlRepository {
  final MlRemoteDataSource remote;

  const MlRepositoryImpl(this.remote);

  @override
  Future<void> retrain() async {
    try {
      await remote.retrain();
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('retrain failed', error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e('retrain unexpected error', error: e, stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }
}
