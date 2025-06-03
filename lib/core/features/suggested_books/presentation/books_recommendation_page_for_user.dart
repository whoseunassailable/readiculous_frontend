import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../utils/appbar.dart';
import '../../../utils/book_info_card.dart';
import '../../admission_percent_calculator/domain/user_specific_genre_model.dart';
import '../../services/api_service.dart';

class BookRecommendationPageForUser extends StatefulWidget {
  const BookRecommendationPageForUser({super.key});

  @override
  _BookRecommendationPageForUserState createState() =>
      _BookRecommendationPageForUserState();
}

class _BookRecommendationPageForUserState
    extends State<BookRecommendationPageForUser> {
  final ApiService _api = ApiService();
  late Future<List<dynamic>> _recommendationsFuture;

  @override
  void initState() {
    super.initState();
    _recommendationsFuture = _loadRecommendations();
  }

  Future<List<dynamic>> _loadRecommendations() async {
    // 1) get the stored user ID
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      throw Exception('No user_id in SharedPreferences.');
    }

    // 2) fetch their genres from Node.js
    final List<UserSpecificGenreModel> userGenres =
        await _api.getUserGenres(userId);

    // 3) extract the genre names
    final genreNames =
        userGenres.map((g) => g.name).whereType<String>().toList();
    if (genreNames.isEmpty) {
      return []; // or throw if you’d rather handle this as an error
    }

    // 4) call your Flask recommend endpoint
    return _api.recommendBooksForUser(genreNames, topN: 10);
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: StylishAppBar(
        title: AppLocalizations.of(context).readiculous,
        homepage: false,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _recommendationsFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final books = snap.data ?? [];
          if (books.isEmpty) {
            return const Center(child: Text('No recommendations found.'));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: ListView.separated(
              itemCount: books.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final book = books[i] as Map<String, dynamic>;
                return BookInfoCard(
                  height: h * 0.15,
                  width: w * 0.9,
                  title: book['title'] as String,
                  author: book['author'] as String,
                  genre: book['genre'] as String,
                  rating: (book['rating'] as num).toDouble(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
