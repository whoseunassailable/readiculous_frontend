import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/network/clients/library_books_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';

import '../../../home/presentation/state_management/user_library_provider.dart';

class LibraryInventoryNotifier
    extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final userId = ref.read(sessionProvider).userId;
    if (userId == null) return [];

    final library = await ref.read(userLibraryProvider(userId).future);
    if (library == null) return [];

    final raw = await LibraryBooksApiClient(DioClient.main)
        .getBooksInLibrary(library.libraryId.toString());

    final items = raw.cast<Map<String, dynamic>>().toList()
      ..sort((a, b) {
        final aLow = _isLowStock(a);
        final bLow = _isLowStock(b);
        if (aLow != bLow) return aLow ? -1 : 1;
        return (a['title']?.toString() ?? '')
            .toLowerCase()
            .compareTo((b['title']?.toString() ?? '').toLowerCase());
      });

    return items;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> saveInventoryItem({
    required String libraryId,
    required String bookId,
    required int copiesTotal,
    required int copiesAvailable,
    required int lowStockThreshold,
    bool isDeleted = false,
  }) async {
    await LibraryBooksApiClient(DioClient.main).addOrUpdateBookInventory({
      'library_id': int.parse(libraryId),
      'book_id': int.parse(bookId),
      'copies_total': copiesTotal,
      'copies_available': copiesAvailable,
      'low_stock_threshold': lowStockThreshold,
      'is_deleted': isDeleted ? 1 : 0,
    });

    await refresh();
  }

  static bool _isLowStock(Map<String, dynamic> item) {
    final available = (item['copies_available'] as num?)?.toInt() ?? 0;
    final threshold = (item['low_stock_threshold'] as num?)?.toInt() ?? 0;
    return available <= threshold;
  }
}

final libraryInventoryProvider =
    AsyncNotifierProvider<LibraryInventoryNotifier, List<Map<String, dynamic>>>(
  LibraryInventoryNotifier.new,
);
