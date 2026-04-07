import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../utils/appbar.dart';
import '../../../utils/book_info_card.dart';
import 'state_management/user_recommendations_controller.dart';

class BookRecommendationPageForUser extends ConsumerWidget {
  const BookRecommendationPageForUser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    final recsAsync = ref.watch(userRecommendationsProvider);

    return Scaffold(
      appBar: StylishAppBar(
        title: AppLocalizations.of(context).readiculous,
        homepage: false,
      ),
      body: recsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (books) {
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
                  genre: _formatGenre(book['genre'] as String?),
                  rating: (book['rating'] as num).toDouble(),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatGenre(String? genre, {int maxGenres = 9}) {
    if (genre == null || genre.trim().isEmpty) return 'Unknown Genre';
    final genreList = genre.split(',').map((g) => g.trim()).toList();
    return genreList.take(maxGenres).join(', ');
  }
}
