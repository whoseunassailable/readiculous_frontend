import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../utils/appbar.dart';
import '../../../utils/book_info_card.dart';
import '../../services/api_service.dart';

class BookRecommendationPageForLibrary extends StatefulWidget {
  const BookRecommendationPageForLibrary({super.key});

  @override
  _BookRecommendationPageForLibraryState createState() =>
      _BookRecommendationPageForLibraryState();
}

class _BookRecommendationPageForLibraryState
    extends State<BookRecommendationPageForLibrary> {
  final ApiService _api = ApiService();
  late Future<Map<String, dynamic>> _recommendationsFuture;

  @override
  void initState() {
    super.initState();
    _recommendationsFuture = _loadRecommendations();
  }

  Future<Map<String, dynamic>> _loadRecommendations() async {
    try {
      final preferences = await _api.getUserPreferences();
      final response = await _api.getBookRecommendations({
        "user_preferences": preferences["user_preferences"],
        "top_m_genres": preferences["top_m_genres"],
        "top_n_books": preferences["top_n_books"]
      });
      print("response : $response");
      return response;
    } catch (e) {
      throw Exception('Failed to load recommendations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StylishAppBar(
        title: AppLocalizations.of(context).readiculous,
        homepage: false,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _recommendationsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(child: Text('No recommendations found.'));
          }

          final responseData = snap.data!;
          final suggestions =
              responseData['recommendations'] as List<dynamic>? ?? [];

          // Collect all non-empty book lists from genres
          final allBooks = suggestions.cast<Map<String, dynamic>>();
          // suggestions.forEach((genre, books) {
          //   if (books is List && books.isNotEmpty) {
          //     allBooks.addAll(books.cast<Map<String, dynamic>>());
          //   }
          // });

          if (allBooks.isEmpty) {
            return const Center(
                child: Text('No books found in recommendations.'));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: ListView.separated(
              itemCount: allBooks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (ctx, i) {
                final b = allBooks[i];
                return BookInfoCard(
                  height: MediaQuery.of(ctx).size.height * 0.15,
                  width: MediaQuery.of(ctx).size.width * 0.9,
                  title: b['title']?.toString() ?? 'Unknown Title',
                  author: b['author']?.toString() ?? 'Unknown Author',
                  genre: _formatGenre(b['genre']?.toString()),
                  rating: (b['rating'] as num?)?.toDouble() ?? 0.0,
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatGenre(String? genre, {int maxGenres = 3}) {
    if (genre == null || genre.trim().isEmpty) return 'Unknown Genre';
    final genreList = genre.split(',').map((g) => g.trim()).toList();
    final trimmed = genreList.take(maxGenres).join(', ');
    return trimmed;
  }
}
