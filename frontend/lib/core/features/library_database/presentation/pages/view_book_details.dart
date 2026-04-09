import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewBookDetails extends ConsumerWidget {
  final Map<String, dynamic>? book;

  const ViewBookDetails({super.key, this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    final title = book?['title']?.toString() ?? 'Book Details';
    final author = book?['author']?.toString() ?? 'Unknown Author';
    final genres = (book?['genres']?.toString() ?? '')
        .split(',')
        .map((genre) => genre.trim())
        .where((genre) => genre.isNotEmpty)
        .toList();
    final description =
        book?['description']?.toString().trim().isNotEmpty == true
            ? book!['description'].toString()
            : 'No description available yet.';
    final stockLabel = book?['stock_label']?.toString();
    final available = (book?['copies_available'] as num?)?.toInt();
    final total = (book?['copies_total'] as num?)?.toInt();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_page.png'),
            fit: BoxFit.fitHeight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6E4C9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF7A5332), width: 2),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 32),
                    Expanded(
                      child: Text(
                        'Book Details',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.patrickHand(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF342116),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => context.pop(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7BE8B),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF7A5332),
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.all(6),
                        child:
                            const Icon(Icons.close, color: Color(0xFF342116)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                constraints: BoxConstraints(minHeight: height * 0.56),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8EBDD),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF7A5332), width: 3),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 96,
                          height: 138,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB7D8FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF7A5332),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            size: 48,
                            color: Color(0xFF342116),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.patrickHand(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF342116),
                                ),
                              ),
                              Text(
                                author,
                                style: GoogleFonts.patrickHand(
                                  fontSize: 18,
                                  color: const Color(0xFF5E4736),
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (genres.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: genres
                                      .take(3)
                                      .map(
                                        (genre) => _InfoPill(
                                          label: genre,
                                          color: const Color(0xFFB7D8FF),
                                        ),
                                      )
                                      .toList(),
                                ),
                              if (stockLabel != null) ...[
                                const SizedBox(height: 10),
                                _InfoPill(
                                  label: stockLabel,
                                  color: const Color(0xFFBFE3C0),
                                ),
                              ],
                              if (available != null && total != null) ...[
                                const SizedBox(height: 10),
                                _InfoPill(
                                  label: '$available of $total available',
                                  color: const Color(0xFFFFE4A0),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Why It's Recommended:",
                      style: GoogleFonts.patrickHand(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF342116),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: GoogleFonts.patrickHand(
                        fontSize: 18,
                        color: const Color(0xFF43352A),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.center,
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF342116),
                          backgroundColor: const Color(0xFFF6E4C9),
                          side: const BorderSide(
                            color: Color(0xFF7A5332),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: GoogleFonts.patrickHand(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF7A5332), width: 1.4),
      ),
      child: Text(
        label,
        style: GoogleFonts.patrickHand(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF342116),
        ),
      ),
    );
  }
}
