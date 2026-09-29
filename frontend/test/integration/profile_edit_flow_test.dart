/// Editing a profile through the real router, pages and controllers (only the
/// repository is faked). Guards two bugs found on device: saving left a stale
/// copy of the edit page open (a router refresh triggered by the email change
/// raced the pop), and the profile page kept showing the old values.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/config/routing/routing.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/core/widgets/minimalistic_button.dart';
import 'package:readiculous_frontend/features/settings/domain/entities/user_profile.dart';
import 'package:readiculous_frontend/features/settings/domain/repositories/profile_repository.dart';
import 'package:readiculous_frontend/features/settings/presentation/pages/profile_page.dart';
import 'package:readiculous_frontend/features/settings/presentation/pages/edit_profile_page.dart';
import 'package:readiculous_frontend/features/settings/presentation/state_management/profile_providers.dart';
import 'package:readiculous_frontend/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestApp extends ConsumerStatefulWidget {
  const _TestApp();

  @override
  ConsumerState<_TestApp> createState() => _TestAppState();
}

class _TestAppState extends ConsumerState<_TestApp> {
  late final GoRouter router = Routing(ref).router;

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
      );
}

const _profile = UserProfile(
  userId: 'lib1',
  firstName: 'Grace',
  lastName: 'Hernandez',
  email: 'grace@example.com',
  role: 'librarian',
  location: 'Chicago',
);

/// Profile storage that behaves like the backend: updates are visible to the
/// next read.
class _FakeProfileRepository implements ProfileRepository {
  UserProfile profile = _profile;

  @override
  Future<UserProfile> getProfile(String userId) async => profile;

  @override
  Future<UserProfile> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String location,
    String? phone,
    String? dateOfBirth,
  }) async {
    return profile = UserProfile(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      role: profile.role,
      location: location,
      phone: phone,
      dateOfBirth: dateOfBirth,
    );
  }

  @override
  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {}
}

/// The home page under the pushed route overflows with the test font; its
/// layout isn't what this test checks.
void _suppressOverflowErrors() {
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    original?.call(details);
  };
  addTearDown(() => FlutterError.onError = original);
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('an email change keeps the open edit page and its input',
      (tester) async {
    _suppressOverflowErrors();
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    // A logged-in librarian (no genre-onboarding gate), home page stubbed out.
    SharedPreferences.setMockInitialValues({
      'is_logged_in': true,
      'user_id': 'lib1',
      'role': 'librarian',
      'email': 'grace@example.com',
    });
    final container = ProviderContainer(overrides: [
      currentUserProfileProvider.overrideWith((ref) async => _profile),
    ]);
    await container.read(sessionProvider.notifier).init();

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const _TestApp(),
    ));
    final router = tester.state<_TestAppState>(find.byType(_TestApp)).router;
    router.push('/edit_profile');
    await tester.pumpAndSettle();
    expect(find.byType(EditProfilePage), findsOneWidget);

    // Type something, then change only the email in the session.
    final lastName = find.byType(TextFormField).at(1);
    await tester.enterText(lastName, 'Typed');
    await container
        .read(sessionProvider.notifier)
        .setEmail('grace.new@example.com');
    await tester.pumpAndSettle();

    expect(find.byType(EditProfilePage), findsOneWidget);
    expect(find.text('Typed'), findsOneWidget,
        reason: 'the edit page must not be rebuilt from scratch');

    // The dashboard underneath retries its (stubbed-out) requests; tear the
    // app down so no retry timers outlive the test.
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await tester.pump(const Duration(minutes: 1));
  });

  testWidgets('saving an edit returns to the profile showing the new values',
      (tester) async {
    _suppressOverflowErrors();
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({
      'is_logged_in': true,
      'user_id': 'lib1',
      'role': 'librarian',
      'email': 'grace@example.com',
    });
    final repo = _FakeProfileRepository();
    final container = ProviderContainer(overrides: [
      profileRepositoryProvider.overrideWithValue(repo),
    ]);
    await container.read(sessionProvider.notifier).init();

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const _TestApp(),
    ));
    final router = tester.state<_TestAppState>(find.byType(_TestApp)).router;
    router.push('/profile_page');
    await tester.pumpAndSettle();
    router.push('/edit_profile');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), 'Edited');
    await tester.enterText(
        find.byType(TextFormField).at(2), 'grace.new@example.com');
    await tester.tap(find.byType(MinimalistButton));
    await tester.pumpAndSettle();

    expect(find.byType(EditProfilePage), findsNothing,
        reason: 'a successful save closes the edit page');
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.text('Edited'), findsOneWidget);
    expect(container.read(sessionProvider).email, 'grace.new@example.com');

    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await tester.pump(const Duration(minutes: 1));
  });
}
