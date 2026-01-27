// lib/core/widgets/crayon/genre_chips.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A single “crayon style” selectable chip.
class CrayonGenreChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Base (unselected) fill color for the genre.
  final Color color;

  /// Optional small icon shown when selected.
  final bool showCheckmark;

  const CrayonGenreChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
    this.showCheckmark = true,
  });

  @override
  Widget build(BuildContext context) {
    final ink = Colors.black.withOpacity(0.70);

    // Unselected vs selected visuals
    final fill = selected ? _darken(color, 0.10) : color.withOpacity(0.55);
    final borderWidth = selected ? 3.2 : 2.4;
    final shadowOpacity = selected ? 0.18 : 0.12;
    final yOffset = selected ? 4.0 : 3.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: selected ? 0.99 : 1.0),
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: ink, width: borderWidth),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(shadowOpacity),
                  offset: Offset(2, yOffset),
                  blurRadius: 0, // sharp-ish, “handmade” look
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected && showCheckmark) ...[
                  const Icon(Icons.check, size: 18, color: Colors.black),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: GoogleFonts.patrickHand(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.90),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Simple darken helper (no extra deps)
  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    final l = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }
}

/// Horizontal (scrollable) multi-select chip row.
class CrayonGenreChipRow extends StatelessWidget {
  final List<String> genres;

  /// Currently selected genres
  final Set<String> selected;

  /// Called when a genre is toggled
  final ValueChanged<Set<String>> onChanged;

  /// Map of genre -> base color
  final Map<String, Color> genreColors;

  /// If true, only one can be selected at a time (radio behavior).
  final bool singleSelect;

  const CrayonGenreChipRow({
    super.key,
    required this.genres,
    required this.selected,
    required this.onChanged,
    required this.genreColors,
    this.singleSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final g = genres[i];
          final isSelected = selected.contains(g);
          final color = genreColors[g] ?? const Color(0xFFF2E2C6);

          return CrayonGenreChip(
            label: g,
            selected: isSelected,
            color: color,
            onTap: () {
              final next = Set<String>.from(selected);
              if (singleSelect) {
                next
                  ..clear()
                  ..add(g);
              } else {
                if (isSelected) {
                  next.remove(g);
                } else {
                  next.add(g);
                }
              }
              onChanged(next);
            },
          );
        },
      ),
    );
  }
}
