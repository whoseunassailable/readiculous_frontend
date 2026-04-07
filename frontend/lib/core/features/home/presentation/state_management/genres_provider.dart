import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/network/clients/genres_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';

final allGenresProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final raw = await GenresApiClient(DioClient.main).getAllGenres();
  return raw
      .cast<Map<String, dynamic>>()
      .map((g) => g['name'] as String)
      .toList();
});
