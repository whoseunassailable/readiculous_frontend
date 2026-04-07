import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/network/clients/reads_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';

class MyBooksNotifier
    extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final userId = ref.read(sessionProvider).userId;
    if (userId == null) return [];
    final raw =
        await ReadsApiClient(DioClient.main).getUserReadingList(userId);
    return raw.cast<Map<String, dynamic>>();
  }

  Future<void> addOrUpdate({
    required String bookId,
    required String status,
    double? rating,
  }) async {
    final userId = ref.read(sessionProvider).userId;
    if (userId == null) return;
    await ReadsApiClient(DioClient.main).addOrUpdateRead({
      'user_id': userId,
      'book_id': bookId,
      'status': status,
      if (rating != null) 'rating': rating,
    });
    ref.invalidateSelf();
  }

  Future<void> remove(String bookId) async {
    final userId = ref.read(sessionProvider).userId;
    if (userId == null) return;
    await ReadsApiClient(DioClient.main)
        .removeFromReadingList(userId, bookId);
    ref.invalidateSelf();
  }
}

final myBooksProvider =
    AsyncNotifierProvider<MyBooksNotifier, List<Map<String, dynamic>>>(
  MyBooksNotifier.new,
);