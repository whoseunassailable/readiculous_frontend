import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/network/clients/libraries_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';

final allLibrariesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final raw = await LibrariesApiClient(DioClient.main).getAllLibraries();
  final items = raw.cast<Map<String, dynamic>>().toList()
    ..sort((a, b) => (a['name']?.toString() ?? '')
        .toLowerCase()
        .compareTo((b['name']?.toString() ?? '').toLowerCase()));
  return items;
});
