import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/generated/l10n.dart';
import 'package:readiculous_frontend/shared/genres/domain/entities/genre.dart';
import 'package:readiculous_frontend/shared/genres/presentation/state_management/genres_providers.dart';
import 'package:readiculous_frontend/shared/recommendations/presentation/state_management/user_recommendations_notifier.dart';

import '../state_management/genre_preferences_controller.dart';

class GenrePreferencesPage extends ConsumerStatefulWidget {
  const GenrePreferencesPage({super.key});

  @override
  ConsumerState<GenrePreferencesPage> createState() =>
      _GenrePreferencesPageState();
}

class _GenrePreferencesPageState extends ConsumerState<GenrePreferencesPage> {
  /// The reader's picks on this screen; null until their saved genres load.
  Set<int>? _selected;

  /// Saved → regenerate recommendations for the new tastes and go back;
  /// failed → say why and stay.
  void _onSaveStateChanged(AsyncValue<void>? previous, AsyncValue<void> next) {
    next.whenOrNull(
      data: (_) {
        if (previous?.isLoading != true) return;
        ref.read(userRecommendationsProvider.notifier).generate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFF3A436),
            content: Text(
              S.of(context).genrePreferencesSaved,
              style: GoogleFonts.patrickHand(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        context.pop();
      },
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      ),
    );
  }

  void _onSavePressed() {
    final selected = _selected;
    if (selected == null) return;
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).pleaseSelectAtLeastOneGenre)),
      );
      return;
    }
    ref.read(genrePreferencesControllerProvider.notifier).save(selected);
  }

  void _toggle(int genreId) {
    setState(() {
      final selected = _selected!;
      if (!selected.remove(genreId)) selected.add(genreId);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      genrePreferencesControllerProvider,
      _onSaveStateChanged,
    );
    final saving = ref.watch(
      genrePreferencesControllerProvider.select((s) => s.isLoading),
    );
    final allGenresAsync = ref.watch(allGenresProvider);
    final userGenresAsync = ref.watch(userGenresProvider);

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
                            BoxShadow(
                                color: Colors.black,
                                offset: Offset(2, 2),
                                blurRadius: 0),
                          ],
                        ),
                        child: const Icon(MaterialCommunityIcons.arrow_left,
                            color: Colors.black, size: 20),
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
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _MessageCard(
                      title: 'Could not load genres.', subtitle: '$e'),
                  data: (allGenres) => userGenresAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => _MessageCard(
                        title: 'Could not load your preferences.',
                        subtitle: '$e'),
                    data: (saved) => _buildBody(allGenres, saved, saving),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<Genre> allGenres, List<Genre> saved, bool saving) {
    final savedIds = saved.map((g) => g.genreId).toSet();
    final selected = _selected ??= {...savedIds};
    final changed =
        selected.length != savedIds.length || !selected.containsAll(savedIds);

    // Selected genres first, then alphabetical. Colours follow each genre's
    // position in the catalog so they don't jump around when re-sorted.
    final colorIndex = {
      for (var i = 0; i < allGenres.length; i++) allGenres[i].genreId: i,
    };
    final sorted = [...allGenres]..sort((a, b) {
        final aSelected = selected.contains(a.genreId);
        final bSelected = selected.contains(b.genreId);
        if (aSelected != bSelected) return aSelected ? -1 : 1;
        return a.name.compareTo(b.name);
      });

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        _SummaryCard(selectedCount: selected.length, changed: changed),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final genre in sorted)
              _GenreToggleChip(
                label: genre.name,
                selected: selected.contains(genre.genreId),
                color: _palette[colorIndex[genre.genreId]! % _palette.length],
                onTap: () => _toggle(genre.genreId),
              ),
          ],
        ),
        const SizedBox(height: 22),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: saving ? null : _onSavePressed,
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
            child: saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black),
                  )
                : Text(
                    'Save Preferences',
                    style: GoogleFonts.patrickHand(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }
}

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
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tune Your Feed',
              style: GoogleFonts.patrickHand(
                  fontSize: 22, fontWeight: FontWeight.bold)),
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

  const _GenreToggleChip(
      {required this.label,
      required this.selected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white.withOpacity(0.82),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.black,
            width: selected ? 3.2 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(selected ? 0.24 : 0.10),
              offset: Offset(selected ? 5 : 2, selected ? 5 : 2),
              blurRadius: 0,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 16, color: Colors.black),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.patrickHand(
                fontSize: 15,
                fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
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
            Text(title,
                textAlign: TextAlign.center,
                style: GoogleFonts.patrickHand(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.patrickHand(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
