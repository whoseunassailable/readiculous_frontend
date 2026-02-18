import 'package:go_router/go_router.dart';
import 'package:readiculous_frontend/core/features/home/presentation/widgets/log_out_page_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

// GoRouter configuration
class Routing {
  final router = GoRouter(
    initialLocation: '/',
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
      // View book details page
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
    // errorPageBuilder: (context, state) {
    //   return const MaterialPage(child: ErrorPage());
    // },
    redirect: (context, state) async {
      // Perform the redirection based on the user's login status
      final isLoggedIn = await isUserLoggedIn();
      if (isLoggedIn && state.uri.toString() == '/') {
        return '/home_page';
      } else if (!isLoggedIn && state.uri.toString() != '/') {
        return '/';
      }
      return null;
    },
  );
}

Future<bool> isUserLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('email');
  String? userId = prefs.getString('userId');
  print("email : $email");
  print("userId : $userId");
  return email != null && userId != null;
}

// Save login state
Future<void> setLoginState(bool isLoggedIn) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_logged_in', isLoggedIn);
}
