import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyBookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final VoidCallback onDelete;
  final void Function(double rating)? onRate;
  final VoidCallback? onMarkFinished;
  final VoidCallback? onMoveToReading;
  final VoidCallback? onAddToReading;

  const MyBookCard({
    super.key,
    required this.book,
    required this.onDelete,
    this.onRate,
    this.onMarkFinished,
    this.onMoveToReading,
    this.onAddToReading,
  });

  @override
  Widget build(BuildContext context) {
    final status = book['status'] as String? ?? 'want_to_read';
    final rating = (book['rating'] as num?)?.toDouble() ?? 0.0;
    final title = book['title'] as String? ?? 'Unknown Title';
    final author = book['author'] as String? ?? 'Unknown Author';

    return Dismissible(
      key: Key('book_${book['book_id']}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFD62828),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
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
                    style: GoogleFonts.patrickHand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3A3329),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: status),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'by $author',
              style: GoogleFonts.patrickHand(
                fontSize: 13,
                color: const Color(0xFF3A3329).withOpacity(0.60),
              ),
            ),
            if (status == 'want_to_read') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (onAddToReading != null) ...[
                    Expanded(
                      child: _StatusButton(
                        label: 'ADD TO READING',
                        color: const Color(0xFFD7C6FF),
                        icon: Icons.menu_book_outlined,
                        onTap: onAddToReading!,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  _StatusButton(
                    label: 'Remove',
                    color: const Color(0xFFFFC7C2),
                    icon: Icons.remove_circle_outline,
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
            if (status == 'reading' && onMarkFinished != null) ...[
              const SizedBox(height: 10),
              _StatusButton(
                label: 'Finished Reading',
                color: const Color(0xFFD7C6FF),
                icon: Icons.check_circle_outline,
                onTap: onMarkFinished!,
              ),
            ],
            if (status == 'read') ...[
              const SizedBox(height: 10),
              _StarRating(rating: rating, onRate: onRate),
              if (onMoveToReading != null) ...[
                const SizedBox(height: 8),
                _StatusButton(
                  label: 'Move to Reading',
                  color: const Color(0xFFBFE3C0),
                  icon: Icons.menu_book_outlined,
                  onTap: onMoveToReading!,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  Color get _color {
    switch (status) {
      case 'reading':
        return const Color(0xFFBFE3C0);
      case 'read':
        return const Color(0xFFD7C6FF);
      default:
        return const Color(0xFFB7D8FF);
    }
  }

  String get _label {
    switch (status) {
      case 'reading':
        return 'Reading';
      case 'read':
        return 'Finished';
      default:
        return 'Want to Read';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black, width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(1.5, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        _label,
        style: GoogleFonts.patrickHand(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _StatusButton({required this.label, required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black, width: 1.8),
          boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 0)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.black87),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.patrickHand(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;
  final void Function(double)? onRate;

  const _StarRating({required this.rating, this.onRate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Your rating: ',
          style: GoogleFonts.patrickHand(
            fontSize: 12,
            color: const Color(0xFF3A3329).withOpacity(0.60),
          ),
        ),
        ...List.generate(5, (i) {
          final filled = (i + 1) <= rating;
          return GestureDetector(
            onTap: onRate != null ? () => onRate!(i + 1.0) : null,
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 24,
              color: const Color(0xFFF3A436),
            ),
          );
        }),
      ],
    );
  }
}
