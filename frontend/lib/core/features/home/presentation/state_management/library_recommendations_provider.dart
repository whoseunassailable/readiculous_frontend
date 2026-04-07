import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/network/clients/recommendations_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';

final libraryRecommendationsProvider =
    FutureProvider.autoDispose.family<List<dynamic>, String>(
  (ref, libraryId) => RecommendationsApiClient(DioClient.main)
      .getLibraryRecommendations(libraryId),
);
