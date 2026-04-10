import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/features/home/presentation/state_management/genres_provider.dart';
import 'package:readiculous_frontend/core/network/clients/genres_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';

import '../state_management/genre_preferences_provider.dart';

class GenrePreferencesPage extends ConsumerStatefulWidget {
  const GenrePreferencesPage({super.key});

  @override
  ConsumerState<GenrePreferencesPage> createState() =>
      _GenrePreferencesPageState();
}

class _GenrePreferencesPageState extends ConsumerState<GenrePreferencesPage> {
  final Set<String> _selectedGenreIds = {};
  bool _initializedSelection = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(sessionProvider).userId;
    final allGenresAsync = ref.watch(allGenresProvider);
    final preferencesAsync = ref.watch(genrePreferencesProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitHeight,
            image: AssetImage('assets/images/bg_for_add_books.png'),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom crayon header
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
                      'Genre Preferences',
                      style: GoogleFonts.patrickHand(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3A3329),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: allGenresAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _MessageCard(title: 'Could not load genres.', subtitle: '$e'),
                  data: (allGenres) => preferencesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => _MessageCard(title: 'Could not load your preferences.', subtitle: '$e'),
                    data: (prefs) {
                      final currentGenreIds = prefs
                          .map((g) => (g['genre_id'] ?? g['id']).toString())
                          .toSet();
                      if (!_initializedSelection) {
                        _selectedGenreIds
                          ..clear()
                          ..addAll(currentGenreIds);
                        _initializedSelection = true;
                      }

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                        children: [
                          _SummaryCard(
                            selectedCount: _selectedGenreIds.length,
                            changed: _selectedGenreIds.difference(currentGenreIds).isNotEmpty ||
                                currentGenreIds.difference(_selectedGenreIds).isNotEmpty,
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: List.generate(allGenres.length, (index) {
                              final genreName = allGenres[index];
                              final genreId = prefs
                                  .cast<Map<String, dynamic>?>()
                                  .firstWhere(
                                    (g) => g?['name'] == genreName,
                                    orElse: () => null,
                                  )?['genre_id']
                                  ?.toString();

                              return _GenreToggleChip(
                                label: genreName,
                                selected: genreId != null && _selectedGenreIds.contains(genreId),
                                color: _palette[index % _palette.length],
                                onTap: () async {
                                  final resolvedId = await _resolveGenreId(
                                    genreName: genreName,
                                    existingId: genreId,
                                  );
                                  if (resolvedId == null) return;
                                  setState(() {
                                    if (_selectedGenreIds.contains(resolvedId)) {
                                      _selectedGenreIds.remove(resolvedId);
                                    } else {
                                      _selectedGenreIds.add(resolvedId);
                                    }
                                  });
                                },
                              );
                            }),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: userId == null || _saving
                                  ? null
                                  : () => _save(userId, currentGenreIds),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF3A436),
                                foregroundColor: Colors.black,
                                elevation: 3,
                                shadowColor: Colors.black,
                                side: const BorderSide(color: Colors.black, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _saving
                                  ? const SizedBox(
                                      width: 20, height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                    )
                                  : Text(
                                      'Save Preferences',
                                      style: GoogleFonts.patrickHand(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _resolveGenreId({required String genreName, required String? existingId}) async {
    if (existingId != null) return existingId;
    final raw = await ref.read(_genreIdMapProvider.future);
    return raw[genreName];
  }

  Future<void> _save(String userId, Set<String> currentGenreIds) async {
    setState(() => _saving = true);
    try {
      await ref.read(genrePreferencesProvider.notifier).replaceSelections(
            userId: userId,
            currentGenreIds: currentGenreIds,
            nextGenreIds: _selectedGenreIds,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFF3A436),
          content: Text(
            'Genre preferences saved!',
            style: GoogleFonts.patrickHand(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 1800));
      if (!mounted) return;
      context.go('/home_page');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update preferences.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

final _genreIdMapProvider = FutureProvider<Map<String, String>>((ref) async {
  final raw = await GenresApiClient(DioClient.main).getAllGenres();
  final map = <String, String>{};
  for (final item in raw.cast<Map<String, dynamic>>()) {
    final name = item['name']?.toString();
    final id = (item['genre_id'] ?? item['id'])?.toString();
    if (name != null && id != null) map[name] = id;
  }
  return map;
});

const _palette = [
  Color(0xFFB7D8FF),
  Color(0xFFBFE3C0),
  Color(0xFFD7C6FF),
  Color(0xFFFFC7C2),
  Color(0xFFE8D2B0),
  Color(0xFFFFE4A0),
  Color(0xFFFFCCE5),
  Color(0xFFB2EBF2),
];

class _SummaryCard extends StatelessWidget {
  final int selectedCount;
  final bool changed;

  const _SummaryCard({required this.selectedCount, required this.changed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFD7C6FF).withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black, width: 2.5),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tune Your Feed', style: GoogleFonts.patrickHand(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            '$selectedCount genre${selectedCount == 1 ? '' : 's'} selected${changed ? ' • unsaved changes' : ''}',
            style: GoogleFonts.patrickHand(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _GenreToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _GenreToggleChip({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 0)],
        ),
        child: Text(
          label,
          style: GoogleFonts.patrickHand(
            fontSize: 15,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _MessageCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, textAlign: TextAlign.center, style: GoogleFonts.patrickHand(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.patrickHand(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}