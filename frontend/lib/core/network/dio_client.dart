import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioClient {
  DioClient._(); // no instances

  static final _logger = PrettyDioLogger(
    requestHeader: false,
    requestBody: false,
    responseBody: false,
    responseHeader: false,
    error: true,
    compact: true,
  );

  static final Dio main = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:5000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )
    ..transformer = BackgroundTransformer()
    ..interceptors.add(_logger);

}
