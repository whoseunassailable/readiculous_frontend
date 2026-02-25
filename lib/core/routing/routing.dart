import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/routes.dart';
import '../features/authentication/presentation/login_page.dart';
import '../features/authentication/presentation/register_page.dart';
import '../features/books/pages/add_book.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/library_database/presentation/pages/view_book_details.dart';
import '../features/library_database/presentation/pages/view_database.dart';
import '../features/settings/presentation/pages/logout_page.dart';
import '../features/settings/presentation/pages/profile_page.dart';
import '../features/suggested_books/presentation/books_recommendation_for_library.dart';
import '../features/suggested_books/presentation/books_recommendation_page_for_user.dart';
import '../features/suggested_books/presentation/preferred_genre.dart';
import '../session/session_provider.dart';

/// ✅ GoRouter refresh bridge for Riverpod
class GoRouterRefresh extends ChangeNotifier {
  GoRouterRefresh(WidgetRef ref) {
    // WidgetRef.listen exists and works fine here
    ref.listen(sessionProvider, (prev, next) {
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
        builder: (context, state) => const ViewBookDetails(),
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
    ],

    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      if (!session.initialized) return null;
      final loggedIn = session.userId != null && session.role != null;

      final isAtLogin = state.matchedLocation == '/';
      final isAtRegister = state.matchedLocation == '/register_page';

      if (!loggedIn) {
        return (isAtLogin || isAtRegister) ? null : '/';
      }

      if (loggedIn && (isAtLogin || isAtRegister)) {
        return '/home_page';
      }

      return null;
    },
  );
}
