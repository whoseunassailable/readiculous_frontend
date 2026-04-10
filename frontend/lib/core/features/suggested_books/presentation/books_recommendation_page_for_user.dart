import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/bg_for_add_books.png'),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3A436),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0),
                          ],
                        ),
                        child: const Icon(MaterialCommunityIcons.arrow_left, color: Colors.black, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'My Recommendations',
                      style: GoogleFonts.patrickHand(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3A3329),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: recsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.black38),
                          const SizedBox(height: 12),
                          Text(
                            'Recommendations unavailable',
                            style: GoogleFonts.patrickHand(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF3A3329)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'The ML service may be offline. Add more books to your reading list and try again later.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.patrickHand(fontSize: 15, color: const Color(0xFF3A3329).withOpacity(0.65)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (books) {
                    if (books.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('📚', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 12),
                              Text(
                                'No recommendations yet',
                                style: GoogleFonts.patrickHand(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF3A3329)),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Rate some books you\'ve finished and set your genre preferences to get personalised picks.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.patrickHand(fontSize: 15, color: const Color(0xFF3A3329).withOpacity(0.65)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      itemCount: books.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) {
                        final book = books[i] as Map<String, dynamic>;
                        return BookInfoCard(
                          height: h * 0.15,
                          width: w * 0.9,
                          title: book['title']?.toString() ?? 'Unknown Title',
                          author: book['author']?.toString() ?? 'Unknown Author',
                          genre: _formatGenre(book['genre']?.toString()),
                          rating: (book['rating'] as num?)?.toDouble() ?? 0.0,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatGenre(String? genre, {int maxGenres = 9}) {
    if (genre == null || genre.trim().isEmpty) return 'Unknown Genre';
    final genreList = genre.split(',').map((g) => g.trim()).toList();
    return genreList.take(maxGenres).join(', ');
  }
}