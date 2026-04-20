import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_roles.dart';
import '../constants/routes.dart';
import '../features/authentication/presentation/pages/login_page.dart';
import '../features/authentication/presentation/pages/register_page.dart';
import '../features/books/pages/add_book.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/library_database/presentation/pages/view_book_details.dart';
import '../features/library_database/presentation/pages/view_database.dart';
import '../features/genre_trends/presentation/pages/genre_trends_page.dart';
import '../features/genre_preferences/presentation/pages/genre_preferences_page.dart';
import '../features/my_books/presentation/pages/my_books_page.dart';
import '../features/library_association/presentation/pages/library_association_page.dart';
import '../features/library_inventory/presentation/pages/library_inventory_page.dart';
import '../features/settings/presentation/pages/logout_page.dart';
import '../features/settings/presentation/pages/profile_page.dart';
import '../features/suggested_books/presentation/books_recommendation_for_library.dart';
import '../features/suggested_books/presentation/books_recommendation_page_for_user.dart';
import '../features/suggested_books/presentation/preferred_genre.dart';
import '../session/session_provider.dart';
import '../session/session_state.dart';

/// Pure redirect logic — extracted so it can be unit-tested without a widget tree.
/// Returns the target path to navigate to, or null if no redirect is needed.
///
/// NOTE: GoRouter 17+ calls the top-level redirect only ONCE per navigation,
/// so this function must compute the final destination in a single step (no
/// redirect chains).
String? computeAuthRedirect(SessionState session, String location) {
  if (!session.initialized) return null;

  final loggedIn = session.userId != null && session.role != null;
  final isAtLogin = location == '/';
  final isAtRegister = location == '/register_page';
  final isAtOnboarding = location == '/preferred_location';
  final needsOnboarding =
      session.role == AppRoles.user && session.hasGenrePrefs != true;

  // Guest user: allow only login and register pages
  if (!loggedIn) {
    return (isAtLogin || isAtRegister) ? null : '/';
  }

  // Logged-in user at login/register: jump directly to the right landing page
  if (isAtLogin || isAtRegister) {
    return needsOnboarding ? '/preferred_location' : '/home_page';
  }

  // User without genre prefs: block all pages except onboarding
  if (needsOnboarding && !isAtOnboarding) {
    return '/preferred_location';
  }

  // User with genre prefs: prevent revisiting onboarding
  if (session.role == AppRoles.user &&
      session.hasGenrePrefs == true &&
      isAtOnboarding) {
    return '/home_page';
  }

  return null;
}

/// GoRouter refresh bridge for Riverpod
class GoRouterRefresh extends ChangeNotifier {
  GoRouterRefresh(WidgetRef ref) {
    // listenManual works outside of build (no debugDoingBuild assertion)
    ref.listenManual(sessionProvider, (prev, next) {
      notifyListeners();
    });
  }
}

class Routing {
  final WidgetRef ref;
  Routing(this.ref);

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefresh(ref), // ✅ now correct

    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.loginPage,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home_page',
        name: RouteNames.homePage,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/register_page',
        name: RouteNames.registerPage,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/add_book_details',
        name: RouteNames.addBook,
        builder: (context, state) => const AddBook(),
      ),
      GoRoute(
        path: '/view_book_details',
        name: RouteNames.viewBookDetailsPage,
        builder: (context, state) =>
            ViewBookDetails(book: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(
        path: '/view_database',
        name: RouteNames.viewDatabase,
        builder: (context, state) => const ViewDatabase(),
      ),
      GoRoute(
        path: '/preferred_location',
        name: RouteNames.preferredGenre,
        builder: (context, state) => const PreferredGenre(),
      ),
      GoRoute(
        path: '/book_recommendation_page_for_user',
        name: RouteNames.bookRecommendationPageForUser,
        builder: (context, state) => const BookRecommendationPageForUser(),
      ),
      GoRoute(
        path: '/book_recommendation_page_for_library',
        name: RouteNames.bookRecommendationPageForLibrary,
        builder: (context, state) => const BookRecommendationPageForLibrary(),
      ),
      GoRoute(
        path: '/profile_page',
        name: RouteNames.profilePage,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/logout_page',
        name: RouteNames.logoutPage,
        builder: (context, state) => const LogoutPage(),
      ),
      GoRoute(
        path: '/my_books',
        name: RouteNames.myBooks,
        builder: (context, state) => const MyBooksPage(),
      ),
      GoRoute(
        path: '/genre_trends',
        name: RouteNames.genreTrends,
        builder: (context, state) => const GenreTrendsPage(),
      ),
      GoRoute(
        path: '/library_inventory',
        name: RouteNames.libraryInventory,
        builder: (context, state) => const LibraryInventoryPage(),
      ),
      GoRoute(
        path: '/genre_preferences',
        name: RouteNames.genrePreferences,
        builder: (context, state) => const GenrePreferencesPage(),
      ),
      GoRoute(
        path: '/library_association',
        name: RouteNames.libraryAssociation,
        builder: (context, state) => const LibraryAssociationPage(),
      ),
    ],

    redirect: (context, state) =>
        computeAuthRedirect(ref.read(sessionProvider), state.matchedLocation),
  );
}
