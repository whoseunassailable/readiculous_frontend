import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/home_remote_data_source.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/library.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/get_featured_book.dart';
import '../../domain/entities/book.dart';
import '../../domain/usecases/get_user_library.dart';

// DataSource
final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  return HomeRemoteDataSourceImpl();
});

// Repository
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final remote = ref.watch(homeRemoteDataSourceProvider);
  return HomeRepositoryImpl(remote);
});

// UseCase
final getFeaturedBookUseCaseProvider = Provider<GetFeaturedBook>((ref) {
  final repo = ref.watch(homeRepositoryProvider);
  return GetFeaturedBook(repo);
});

// State (loading/error/data) - this is your "Cubit equivalent"
final featuredBookProvider = FutureProvider<Book>((ref) async {
  final usecase = ref.watch(getFeaturedBookUseCaseProvider);
  return usecase();
});

// UseCase provider
final getUserLibraryUseCaseProvider = Provider<GetUserLibrary>((ref) {
  final repo = ref.watch(homeRepositoryProvider);
  return GetUserLibrary(repo);
});

// FutureProvider for UI
final userLibraryProvider =
    FutureProvider.family<Library?, String>((ref, userId) async {
  final usecase = ref.watch(getUserLibraryUseCaseProvider);
  return usecase(userId);
});
