import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/network/clients/libraries_api_client.dart';
import 'package:readiculous_frontend/core/network/clients/library_books_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';

import '../../../home/presentation/state_management/user_library_provider.dart';

final currentLibraryInventoryProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final userId = ref.watch(sessionProvider).userId;
  if (userId == null) return [];

  final library = await ref.watch(userLibraryProvider(userId).future);
  if (library == null) return [];

  final raw = await LibraryBooksApiClient(DioClient.main)
      .getBooksInLibrary(library.libraryId.toString());
  return raw.cast<Map<String, dynamic>>();
});

final currentLibraryActivityProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final userId = ref.watch(sessionProvider).userId;
  if (userId == null) return [];

  final library = await ref.watch(userLibraryProvider(userId).future);
  if (library == null) return [];

  final raw = await LibrariesApiClient(DioClient.main)
      .getLibraryReaderActivity(library.libraryId.toString());
  return raw.cast<Map<String, dynamic>>();
});
