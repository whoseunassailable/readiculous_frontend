import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/features/home/data/datasources/home_remote_data_source.dart';
import 'package:readiculous_frontend/core/features/home/data/repositories/home_repository_impl.dart';
import 'package:readiculous_frontend/core/network/clients/trends_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';

/// Returns a list of [{ 'name': String, 'score': double }] sorted desc by score.
class GenreTrendsNotifier
    extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final userId = ref.read(sessionProvider).userId;
    if (userId == null) return [];

    final repo = HomeRepositoryImpl(HomeRemoteDataSourceImpl());
    final library = await repo.getUserLibrary(userId);
    if (library == null) return [];

    final raw = await TrendsApiClient(DioClient.main)
        .getTopTrends(libraryId: library.libraryId.toString());

    final items = raw
        .cast<Map<String, dynamic>>()
        .map((t) => {
              'name': t['name']?.toString() ?? t['genre']?.toString() ?? '?',
              'score': (t['score'] as num?)?.toDouble() ?? 0.0,
            })
        .toList();

    items.sort((a, b) =>
        (b['score'] as double).compareTo(a['score'] as double));

    return items;
  }
}

final genreTrendsProvider = AsyncNotifierProvider<GenreTrendsNotifier,
    List<Map<String, dynamic>>>(
  GenreTrendsNotifier.new,
);