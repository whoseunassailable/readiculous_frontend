import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/my_books/presentation/state_management/my_books_provider.dart';
import 'state_management/user_recommendations_controller.dart';

class BookRecommendationPageForUser extends ConsumerStatefulWidget {
  const BookRecommendationPageForUser({super.key});

  @override
  ConsumerState<BookRecommendationPageForUser> createState() =>
      _BookRecommendationPageForUserState();
}

class _BookRecommendationPageForUserState
    extends ConsumerState<BookRecommendationPageForUser> {
  static const String _allGenres = 'All';
  String _selectedGenre = _allGenres;

  @override
  Widget build(BuildContext context) {
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
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Icon(
                          MaterialCommunityIcons.arrow_left,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'My Recommendations',
                        style: GoogleFonts.patrickHand(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3A3329),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: recsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.wifi_off_rounded,
                            size: 48,
                            color: Colors.black38,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Recommendations unavailable',
                            style: GoogleFonts.patrickHand(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3A3329),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'The ML service may be offline. Add more books to your reading list and try again later.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.patrickHand(
                              fontSize: 15,
                              color: const Color(0xFF3A3329)
                                  .withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (books) {
                    final normalizedBooks = books
                        .cast<Map<String, dynamic>>()
                        .map(_normalizeRecommendation)
                        .toList();

                    final availableGenres = <String>{
                      _allGenres,
                      ...normalizedBooks
                          .expand((book) => _extractGenres(book['genre']))
                          .where((genre) => genre.isNotEmpty),
                    }.toList();

                    if (!availableGenres.contains(_selectedGenre)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        setState(() => _selectedGenre = _allGenres);
                      });
                    }

                    final visibleBooks = _selectedGenre == _allGenres
                        ? normalizedBooks
                        : normalizedBooks.where((book) {
                            final genres = _extractGenres(book['genre']);
                            return genres.contains(_selectedGenre);
                          }).toList();

                    if (normalizedBooks.isEmpty) {
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
                                style: GoogleFonts.patrickHand(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF3A3329),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Rate some books you\'ve finished and set your genre preferences to get personalised picks.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.patrickHand(
                                  fontSize: 15,
                                  color: const Color(0xFF3A3329)
                                      .withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Filter by genre',
                              style: GoogleFonts.patrickHand(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF3A3329),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 42,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: availableGenres.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final genre = availableGenres[index];
                              final selected = genre == _selectedGenre;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedGenre = genre),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFFB7D8FF)
                                        : const Color(0xFFF8E7B8),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1.5,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(1, 1),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      genre,
                                      style: GoogleFonts.patrickHand(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF3A3329),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: visibleBooks.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text(
                                      'No recommendations in $_selectedGenre right now.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.patrickHand(
                                        fontSize: 18,
                                        color: const Color(0xFF3A3329),
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  itemCount: visibleBooks.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 14),
                                  itemBuilder: (context, i) {
                                    final book = visibleBooks[i];
                                    return _RecommendationCard(
                                      book: book,
                                      formatGenre: _formatGenre,
                                    );
                                  },
                                ),
                        ),
                      ],
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

  Map<String, dynamic> _normalizeRecommendation(Map<String, dynamic> book) {
    final next = Map<String, dynamic>.from(book);
    final genre = next['genre']?.toString().trim();

    if (genre == null || genre.isEmpty) {
      next['genre'] = _extractGenresFromReason(next['reason']?.toString());
    }

    return next;
  }

  List<String> _extractGenres(String? genre) {
    if (genre == null || genre.trim().isEmpty) return const [];
    return genre
        .split(',')
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toList();
  }

  String? _extractGenresFromReason(String? reason) {
    if (reason == null) return null;
    const prefix = 'Genres:';
    if (!reason.startsWith(prefix)) return null;
    final extracted = reason.substring(prefix.length).trim();
    return extracted.isEmpty ? null : extracted;
  }

  String _formatGenre(String? genre, {int maxGenres = 4}) {
    final genreList = _extractGenres(genre);
    if (genreList.isEmpty) return 'Unknown Genre';
    return genreList.take(maxGenres).join(', ');
  }
}

class _RecommendationCard extends ConsumerWidget {
  final Map<String, dynamic> book;
  final String Function(String?) formatGenre;

  const _RecommendationCard({
    required this.book,
    required this.formatGenre,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = book['title']?.toString() ?? 'Unknown Title';
    final author = book['author']?.toString() ?? 'Unknown Author';
    final genre = formatGenre(book['genre']?.toString());
    final rating = (book['rating'] as num?)?.toDouble() ?? 0.0;
    final bookId = book['book_id']?.toString() ?? '';

    final myBooks = ref.watch(myBooksProvider).asData?.value ?? const [];
    final isAdded = myBooks.any((b) => b['book_id']?.toString() == bookId);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB98A5D), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.patrickHand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3A3329),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (rating > 0)
                Text(
                  '${rating.toStringAsFixed(1)} ⭐',
                  style: GoogleFonts.patrickHand(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF3A436),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'by $author',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.patrickHand(
              fontSize: 14,
              color: const Color(0xFF3A3329).withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            genre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.patrickHand(
              fontSize: 13,
              color: const Color(0xFF3A3329).withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: isAdded
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDE8A6),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.black, width: 1.6),
                    ),
                    child: Text(
                      'Added',
                      style: GoogleFonts.patrickHand(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3A3329),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: bookId.isEmpty
                        ? null
                        : () async {
                            await ref.read(myBooksProvider.notifier).addOrUpdate(
                                  bookId: bookId,
                                  status: 'want_to_read',
                                );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('$title added to reading')),
                            );
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7C6FF),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.black, width: 1.8),
                      ),
                      child: Text(
                        'ADD TO READING',
                        style: GoogleFonts.patrickHand(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4D3277),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
