import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/core/network/api_error.dart';
import 'package:readiculous_frontend/features/suggested_books/data/datasources/ml_remote_data_source.dart';
import 'package:readiculous_frontend/features/suggested_books/data/repositories/ml_repository_impl.dart';

class _FakeRemote implements MlRemoteDataSource {
  Object? error;
  int calls = 0;

  @override
  Future<void> retrain() async {
    calls++;
    if (error != null) throw error!;
  }
}

void main() {
  test('retrain reaches the data source', () async {
    final remote = _FakeRemote();
    await MlRepositoryImpl(remote).retrain();
    expect(remote.calls, 1);
  });

  test('a failed retrain keeps the backend message', () async {
    final options = RequestOptions(path: '/ml/retrain');
    final remote = _FakeRemote()
      ..error = DioException(
        requestOptions: options,
        response: Response(
            requestOptions: options,
            statusCode: 500,
            data: {'message': 'Retraining failed'}),
      );

    await expectLater(
      MlRepositoryImpl(remote).retrain(),
      throwsA(isA<ApiError>()
          .having((e) => e.message, 'message', 'Retraining failed')),
    );
  });
}
