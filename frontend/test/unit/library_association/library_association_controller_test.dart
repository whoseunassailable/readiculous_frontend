import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/core/network/api_error.dart';
import 'package:readiculous_frontend/core/session/session_notifier.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/core/session/session_state.dart';
import 'package:readiculous_frontend/features/library_association/presentation/state_management/library_association_controller.dart';
import 'package:readiculous_frontend/shared/library/domain/entities/library.dart';
import 'package:readiculous_frontend/shared/library/domain/repositories/library_repository.dart';
import 'package:readiculous_frontend/shared/library/presentation/state_management/library_providers.dart';

/// A server with one saved library per user.
class _FakeRepository implements LibraryRepository {
  final saved = <String, int>{};
  final calls = <String>[];
  ApiError? error;
  int catalogLoads = 0;

  @override
  Future<void> setReaderLibrary(String userId, int libraryId) async {
    calls.add('reader $userId $libraryId');
    if (error != null) throw error!;
    saved[userId] = libraryId;
  }

  @override
  Future<void> assignLibrarian(String userId, int libraryId) async {
    calls.add('librarian $userId $libraryId');
    if (error != null) throw error!;
    saved[userId] = libraryId;
  }

  @override
  Future<Library?> getUserLibrary(String userId) async {
    final id = saved[userId];
    return id == null ? null : Library(libraryId: id, name: 'Library $id');
  }

  @override
  Future<List<Library>> getAllLibraries() async {
    catalogLoads++;
    return const [
      Library(libraryId: 4, name: 'Chinatown'),
      Library(libraryId: 7, name: 'Woodlawn'),
    ];
  }
}

class _FixedSession extends SessionNotifier {
  final SessionState _state;
  _FixedSession(this._state);

  @override
  SessionState build() => _state;
}

ProviderContainer _container(
    String? userId, String role, LibraryRepository repo) {
  final c = ProviderContainer(overrides: [
    sessionProvider.overrideWith(() => _FixedSession(
        SessionState(initialized: true, userId: userId, role: role))),
    libraryRepositoryProvider.overrideWithValue(repo),
  ]);
  addTearDown(c.dispose);
  c.listen(libraryAssociationControllerProvider, (_, __) {});
  return c;
}

void main() {
  test('a reader saves their home library, and it is refetched', () async {
    final repo = _FakeRepository()..saved['u1'] = 4;
    final c = _container('u1', 'user', repo);
    c.listen(userLibraryProvider('u1'), (_, __) {});
    expect((await c.read(userLibraryProvider('u1').future))?.libraryId, 4);

    await c.read(libraryAssociationControllerProvider.notifier).save(7);

    expect(repo.calls, ['reader u1 7']);
    expect(
        c.read(libraryAssociationControllerProvider), isA<AsyncData<void>>());
    expect((await c.read(userLibraryProvider('u1').future))?.libraryId, 7);
  });

  test('a librarian is assigned instead', () async {
    final repo = _FakeRepository();
    final c = _container('lib1', 'librarian', repo);

    await c.read(libraryAssociationControllerProvider.notifier).save(4);

    expect(repo.calls, ['librarian lib1 4']);
  });

  test('a rejected save is an error carrying the server message', () async {
    final repo = _FakeRepository()
      ..error = const ApiError(statusCode: 404, message: 'Library not found');
    final c = _container('u1', 'user', repo);

    await c.read(libraryAssociationControllerProvider.notifier).save(999);

    final state = c.read(libraryAssociationControllerProvider);
    expect(state.hasError, true);
    expect(state.error.toString(), 'Library not found');
  });

  test('logged out ⇒ error, without a request', () async {
    final repo = _FakeRepository();
    final c = _container(null, 'user', repo);

    await c.read(libraryAssociationControllerProvider.notifier).save(4);

    expect(c.read(libraryAssociationControllerProvider).hasError, true);
    expect(repo.calls, isEmpty);
  });

  test('allLibrariesProvider loads the catalog once and keeps it', () async {
    final repo = _FakeRepository();
    final c = _container('u1', 'user', repo);

    expect((await c.read(allLibrariesProvider.future)).length, 2);
    expect((await c.read(allLibrariesProvider.future)).length, 2);
    expect(repo.catalogLoads, 1);
  });
}
