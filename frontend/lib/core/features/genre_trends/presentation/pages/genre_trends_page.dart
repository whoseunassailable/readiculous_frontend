import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/features/home/presentation/state_management/user_library_provider.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/core/utils/appbar.dart';
import '../state_management/genre_trends_provider.dart';

class GenreTrendsPage extends ConsumerWidget {
  const GenreTrendsPage({super.key});

  // Same 8-colour crayon palette used on the home page chips
  static const _palette = [
    Color(0xFFB7D8FF), // soft blue
    Color(0xFFBFE3C0), // muted green
    Color(0xFFD7C6FF), // lavender
    Color(0xFFFFC7C2), // peach/pink
    Color(0xFFE8D2B0), // tan
    Color(0xFFFFE4A0), // pale yellow
    Color(0xFFFFCCE5), // light pink
    Color(0xFFB2EBF2), // light cyan
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendsAsync = ref.watch(genreTrendsProvider);
    final userId = ref.watch(sessionProvider).userId;
    final libraryAsync =
        userId != null ? ref.watch(userLibraryProvider(userId)) : null;

    final libraryName = libraryAsync?.when(
          data: (lib) => lib?.name,
          loading: () => null,
          error: (_, __) => null,
        ) ??
        'Your Library';

    return Scaffold(
      appBar: StylishAppBar(title: 'Genre Trends', homepage: false),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitHeight,
            image: AssetImage('assets/images/home.png'),
          ),
        ),
        child: trendsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              'Could not load trends.\nTry again.',
              textAlign: TextAlign.center,
              style: GoogleFonts.patrickHand(fontSize: 16),
            ),
          ),
          data: (trends) => _TrendsBody(
            trends: trends,
            libraryName: libraryName,
            palette: _palette,
          ),
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _TrendsBody extends StatelessWidget {
  final List<Map<String, dynamic>> trends;
  final String libraryName;
  final List<Color> palette;

  const _TrendsBody({
    required this.trends,
    required this.libraryName,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No trend data yet.',
                style: GoogleFonts.patrickHand(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3A3329),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Trends build up as readers in your\narea log and rate books.',
                textAlign: TextAlign.center,
                style: GoogleFonts.patrickHand(
                  fontSize: 15,
                  color: const Color(0xFF3A3329).withOpacity(0.55),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final maxScore = (trends.first['score'] as double).clamp(0.001, double.infinity);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header card ──
          _HeaderCard(libraryName: libraryName, totalGenres: trends.length),
          const SizedBox(height: 24),

          // ── Section label ──
          Text(
            'Top genres by reader demand',
            style: GoogleFonts.patrickHand(
              fontSize: 13,
              color: const Color(0xFF3A3329).withOpacity(0.55),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),

          // ── Bar chart ──
          ...List.generate(trends.length, (i) {
            final item = trends[i];
            final name = item['name'] as String;
            final score = (item['score'] as double);
            final ratio = score / maxScore;
            final color = palette[i % palette.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _TrendBar(
                rank: i + 1,
                name: name,
                score: score,
                ratio: ratio,
                color: color,
                animDelay: Duration(milliseconds: 60 * i),
              ),
            );
          }),

          const SizedBox(height: 8),

          // ── Legend note ──
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Scores reflect reader activity in your library\'s area. '
                    'Bars are relative to the top genre.',
                    style: GoogleFonts.patrickHand(
                      fontSize: 12,
                      color: const Color(0xFF3A3329).withOpacity(0.65),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header card ──────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final String libraryName;
  final int totalGenres;

  const _HeaderCard({
    required this.libraryName,
    required this.totalGenres,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF3A436),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            libraryName,
            style: GoogleFonts.patrickHand(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$totalGenres genre${totalGenres == 1 ? '' : 's'} tracked',
            style: GoogleFonts.patrickHand(
              fontSize: 14,
              color: Colors.black.withOpacity(0.70),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Individual bar ───────────────────────────────────────────────────────────

class _TrendBar extends StatefulWidget {
  final int rank;
  final String name;
  final double score;
  final double ratio; // 0.0 – 1.0, relative to max
  final Color color;
  final Duration animDelay;

  const _TrendBar({
    required this.rank,
    required this.name,
    required this.score,
    required this.ratio,
    required this.color,
    required this.animDelay,
  });

  @override
  State<_TrendBar> createState() => _TrendBarState();
}

class _TrendBarState extends State<_TrendBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    Future.delayed(widget.animDelay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF3),
        borderRadius: BorderRadius.circular(14),
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
          // Genre name + rank
          Row(
            children: [
              // Rank bubble
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.8),
                ),
                child: Center(
                  child: Text(
                    '${widget.rank}',
                    style: GoogleFonts.patrickHand(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.name,
                  style: GoogleFonts.patrickHand(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3A3329),
                  ),
                ),
              ),
              // Score label
              Text(
                widget.score.toStringAsFixed(1),
                style: GoogleFonts.patrickHand(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3A3329),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Animated bar
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Track
                  Container(
                    height: 14,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(999),
                      border:
                          Border.all(color: Colors.black, width: 1.5),
                    ),
                  ),
                  // Fill
                  AnimatedBuilder(
                    animation: _anim,
                    builder: (_, __) => Container(
                      height: 14,
                      width: (constraints.maxWidth * widget.ratio *
                              _anim.value)
                          .clamp(14.0, constraints.maxWidth),
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: Colors.black, width: 1.5),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
