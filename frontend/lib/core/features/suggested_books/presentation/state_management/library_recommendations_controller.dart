import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/features/home/data/datasources/home_remote_data_source.dart';
import 'package:readiculous_frontend/core/features/home/data/repositories/home_repository_impl.dart';
import 'package:readiculous_frontend/core/network/clients/recommendations_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';

class LibraryRecommendationsController extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    final userId = ref.read(sessionProvider).userId;
    if (userId == null) throw Exception('Not logged in');

    final repo = HomeRepositoryImpl(HomeRemoteDataSourceImpl());
    final library = await repo.getUserLibrary(userId);
    if (library == null) return [];

    return RecommendationsApiClient(DioClient.main)
        .getLibraryRecommendations(library.libraryId.toString());
  }
}

final libraryRecommendationsControllerProvider = AsyncNotifierProvider.autoDispose<
    LibraryRecommendationsController, List<dynamic>>(
  LibraryRecommendationsController.new,
);
