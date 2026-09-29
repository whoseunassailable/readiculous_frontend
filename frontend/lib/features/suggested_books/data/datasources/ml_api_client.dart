import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'ml_api_client.g.dart';

@RestApi()
abstract class MlApiClient {
  factory MlApiClient(Dio dio, {String? baseUrl}) = _MlApiClient;

  /// Retrains the recommendation models from the app's reading data and
  /// reloads them. Responds only when training has finished.
  @POST('/ml/retrain')
  Future<void> retrain(@DioOptions() Options options);
}
