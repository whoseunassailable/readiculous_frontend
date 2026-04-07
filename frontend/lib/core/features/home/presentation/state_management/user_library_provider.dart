import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/features/home/data/datasources/home_remote_data_source.dart';
import 'package:readiculous_frontend/core/features/home/data/repositories/home_repository_impl.dart';
import 'package:readiculous_frontend/core/features/home/domain/entities/library.dart';

final userLibraryProvider =
    FutureProvider.autoDispose.family<Library?, String>((ref, userId) {
  final repo = HomeRepositoryImpl(HomeRemoteDataSourceImpl());
  return repo.getUserLibrary(userId);
});
