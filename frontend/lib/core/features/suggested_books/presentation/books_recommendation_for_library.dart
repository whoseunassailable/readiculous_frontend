import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../network/clients/recommendations_api_client.dart';
import '../../../network/dio_client.dart';
import '../../../utils/appbar.dart';
import '../../../utils/book_info_card.dart';
import 'state_management/library_recommendations_controller.dart';

class BookRecommendationPageForLibrary extends ConsumerWidget {
  const BookRecommendationPageForLibrary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(libraryRecommendationsControllerProvider);

    return Scaffold(
      appBar: StylishAppBar(
        title: AppLocalizations.of(context).readiculous,
        homepage: false,
      ),
      body: recsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (recs) {
          final books = recs.cast<Map<String, dynamic>>();
          if (books.isEmpty) {
            return const Center(child: Text('No recommendations found.'));
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: ListView.separated(
              itemCount: books.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final b = books[i];
                return _RecommendationTile(
                  book: b,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _RecommendationTile extends ConsumerWidget {
  final Map<String, dynamic> book;
  final double height;
  final double width;

  const _RecommendationTile({
    required this.book,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationId = book['recommendation_id']?.toString() ??
        book['id']?.toString();
    final state = book['state'] as String? ?? 'NEW';

    return GestureDetector(
      onTap: recommendationId == null
          ? null
          : () => _showStateBottomSheet(context, ref, recommendationId, state),
      child: Stack(
        children: [
          BookInfoCard(
            height: height * 0.15,
            width: width * 0.9,
            title: book['title']?.toString() ?? 'Unknown Title',
            author: book['author']?.toString() ?? 'Unknown Author',
            genre: _formatGenre(book['genre']?.toString()),
            rating: (book['rating'] as num?)?.toDouble() ?? 0.0,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: _StateChip(state: state),
          ),
        ],
      ),
    );
  }

  void _showStateBottomSheet(
    BuildContext context,
    WidgetRef ref,
    String recommendationId,
    String currentState,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _StatePickerSheet(
        recommendationId: recommendationId,
        currentState: currentState,
      ),
    );
  }

  String _formatGenre(String? genre, {int maxGenres = 3}) {
    if (genre == null || genre.trim().isEmpty) return 'Unknown Genre';
    final genreList = genre.split(',').map((g) => g.trim()).toList();
    return genreList.take(maxGenres).join(', ');
  }
}

class _StateChip extends StatelessWidget {
  final String state;
  const _StateChip({required this.state});

  static const _colors = {
    'NEW': Colors.blue,
    'ORDERED': Colors.orange,
    'STOCKED': Colors.green,
    'IGNORED': Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (_colors[state] ?? Colors.blue).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _colors[state] ?? Colors.blue),
      ),
      child: Text(
        state,
        style: TextStyle(
          fontSize: 11,
          color: _colors[state] ?? Colors.blue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatePickerSheet extends ConsumerWidget {
  final String recommendationId;
  final String currentState;

  const _StatePickerSheet({
    required this.recommendationId,
    required this.currentState,
  });

  static const _states = ['ORDERED', 'STOCKED', 'IGNORED'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update recommendation status',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ..._states.map(
              (s) => ListTile(
                title: Text(s),
                leading: Radio<String>(
                  value: s,
                  groupValue: currentState,
                  onChanged: (_) {},
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await RecommendationsApiClient(DioClient.main)
                      .updateLibraryRecommendationState(
                    recommendationId,
                    {'state': s},
                  );
                  ref.invalidate(libraryRecommendationsControllerProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
