import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import 'ml_api_client.dart';

abstract class MlRemoteDataSource {
  Future<void> retrain();
}

class MlRemoteDataSourceImpl implements MlRemoteDataSource {
  final MlApiClient _client = MlApiClient(DioClient.main);

  /// The backend answers only after training finishes, which can take well
  /// over the default 30 s.
  static final _retrainOptions =
      Options(receiveTimeout: const Duration(minutes: 10));

  @override
  Future<void> retrain() => _client.retrain(_retrainOptions);
}
