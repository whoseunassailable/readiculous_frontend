import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../network/clients/recommendations_api_client.dart';
import '../../../network/dio_client.dart';
import '../../../session/session_provider.dart';
import '../../../utils/appbar.dart';
import '../../home/presentation/state_management/user_library_provider.dart';
import 'state_management/library_recommendations_controller.dart';

class BookRecommendationPageForLibrary extends ConsumerWidget {
  const BookRecommendationPageForLibrary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(libraryRecommendationsControllerProvider);

    return Scaffold(
      appBar: StylishAppBar(
        title: 'Library Picks',
        homepage: false,
        actions: [_RetrainButton()],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitHeight,
            image: AssetImage('assets/images/home.png'),
          ),
        ),
        child: recsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              'Could not load recommendations.\nTry again.',
              textAlign: TextAlign.center,
              style: GoogleFonts.patrickHand(fontSize: 16),
            ),
          ),
          data: (recs) {
            final books = recs.cast<Map<String, dynamic>>();

            if (books.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'No recommendations yet.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.patrickHand(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3A3329),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap the button below to generate\nbook picks based on local reader trends.',
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

            // Split by status for a cleaner view
            final newRecs =
                books.where((b) => (b['state'] ?? 'NEW') == 'NEW').toList();
            final actionedRecs = books
                .where((b) => (b['state'] ?? 'NEW') != 'NEW')
                .toList();

            return ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              children: [
                if (newRecs.isNotEmpty) ...[
                  _SectionLabel(
                    label: 'Awaiting Action',
                    count: newRecs.length,
                    color: const Color(0xFFFFE4A0),
                  ),
                  const SizedBox(height: 10),
                  ...newRecs.map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _LibraryRecCard(book: b),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                if (actionedRecs.isNotEmpty) ...[
                  _SectionLabel(
                    label: 'Actioned',
                    count: actionedRecs.length,
                    color: const Color(0xFFD9D9D9),
                  ),
                  const SizedBox(height: 10),
                  ...actionedRecs.map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _LibraryRecCard(book: b),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      floatingActionButton: _GenerateFab(),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SectionLabel({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26,
                  offset: Offset(2, 2),
                  blurRadius: 0),
            ],
          ),
          child: Text(
            '$label  $count',
            style: GoogleFonts.patrickHand(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _LibraryRecCard extends ConsumerWidget {
  final Map<String, dynamic> book;

  const _LibraryRecCard({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recId = (book['recommendation_id'] ?? book['id'])?.toString();
    final state = book['state'] as String? ?? 'NEW';
    final title = book['title']?.toString() ?? 'Unknown Title';
    final author = book['author']?.toString() ?? 'Unknown Author';
    final demandLevel = book['demand_level']?.toString() ?? 'MEDIUM';
    final demandScore =
        (book['demand_score'] as num?)?.toDouble() ?? 0.0;
    final genre = _trimGenre(book['genre']?.toString());

    return Container(
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
          // ── Top row: title + demand badge ──
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
              _DemandBadge(level: demandLevel),
            ],
          ),
          const SizedBox(height: 4),
          // ── Author + genre ──
          Text(
            'by $author',
            style: GoogleFonts.patrickHand(
              fontSize: 13,
              color: const Color(0xFF3A3329).withOpacity(0.60),
            ),
          ),
          if (genre.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              genre,
              style: GoogleFonts.patrickHand(
                fontSize: 12,
                color: const Color(0xFF3A3329).withOpacity(0.50),
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 6),
          // ── ML score bar ──
          _ScoreBar(score: demandScore),
          const SizedBox(height: 12),
          const Divider(color: Colors.black12, height: 1),
          const SizedBox(height: 10),
          // ── Action buttons ──
          if (recId != null)
            _ActionRow(
              currentState: state,
              onAction: (newState) async {
                await RecommendationsApiClient(DioClient.main)
                    .updateLibraryRecommendationState(
                  recId,
                  {'state': newState},
                );
                ref.invalidate(libraryRecommendationsControllerProvider);
              },
            ),
        ],
      ),
    );
  }

  String _trimGenre(String? genre, {int max = 3}) {
    if (genre == null || genre.trim().isEmpty) return '';
    return genre.split(',').map((g) => g.trim()).take(max).join(', ');
  }
}

// ─── Demand badge ─────────────────────────────────────────────────────────────

class _DemandBadge extends StatelessWidget {
  final String level;
  const _DemandBadge({required this.level});

  Color get _color {
    switch (level.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFFFC7C2); // peach-red
      case 'LOW':
        return const Color(0xFFB7D8FF); // soft blue
      default:
        return const Color(0xFFFFE4A0); // pale yellow
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black, width: 1.8),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, offset: Offset(1.5, 2), blurRadius: 0),
        ],
      ),
      child: Text(
        level.toUpperCase(),
        style: GoogleFonts.patrickHand(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

// ─── Score bar ────────────────────────────────────────────────────────────────

class _ScoreBar extends StatelessWidget {
  final double score; // 0.0 – 1.0

  const _ScoreBar({required this.score});

  @override
  Widget build(BuildContext context) {
    final clamped = score.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Demand score',
              style: GoogleFonts.patrickHand(
                fontSize: 11,
                color: const Color(0xFF3A3329).withOpacity(0.55),
              ),
            ),
            Text(
              '${(clamped * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.patrickHand(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3A3329),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: 7,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFFF3A436),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Action row ───────────────────────────────────────────────────────────────

class _ActionRow extends StatefulWidget {
  final String currentState;
  final Future<void> Function(String state) onAction;

  const _ActionRow({
    required this.currentState,
    required this.onAction,
  });

  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  bool _busy = false;
  late String _state;

  static const _actions = [
    ('ORDERED', Color(0xFFF9AA33)),   // amber
    ('STOCKED', Color(0xFFBFE3C0)),   // green
    ('IGNORED', Color(0xFFD9D9D9)),   // grey
  ];

  @override
  void initState() {
    super.initState();
    _state = widget.currentState;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _actions.map((pair) {
        final (label, color) = pair;
        final isActive = _state == label;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: _busy || isActive
                  ? null
                  : () async {
                      setState(() {
                        _busy = true;
                        _state = label;
                      });
                      await widget.onAction(label);
                      if (mounted) setState(() => _busy = false);
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? color : color.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.black,
                    width: isActive ? 2.2 : 1.5,
                  ),
                  boxShadow: isActive
                      ? const [
                          BoxShadow(
                            color: Colors.black38,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: _busy && _state == label
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          label,
                          style: GoogleFonts.patrickHand(
                            fontSize: 12,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Generate FAB ─────────────────────────────────────────────────────────────

class _GenerateFab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_GenerateFab> createState() => _GenerateFabState();
}

class _GenerateFabState extends ConsumerState<_GenerateFab> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: const Color(0xFFF3A436),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: const BorderSide(color: Colors.black, width: 2),
      ),
      onPressed: _loading ? null : _generate,
      icon: _loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black,
              ),
            )
          : const Icon(Icons.auto_awesome, color: Colors.black),
      label: Text(
        _loading ? 'Generating...' : 'Generate Picks',
        style: GoogleFonts.patrickHand(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Future<void> _generate() async {
    final userId = ref.read(sessionProvider).userId;
    if (userId == null) return;

    final library = ref.read(userLibraryProvider(userId)).asData?.value;
    if (library == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade300,
            content: Text(
              'No library associated. Go to Choose Library first.',
              style: GoogleFonts.patrickHand(color: Colors.black),
            ),
          ),
        );
      }
      return;
    }

    setState(() => _loading = true);
    try {
      await DioClient.main.post(
        '/recommendations/libraries/${library.libraryId}/generate',
        data: {'top_n_books': 10},
      );
      ref.invalidate(libraryRecommendationsControllerProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade300,
            content: Text(
              'Could not generate picks. Is the ML service running?',
              style: GoogleFonts.patrickHand(color: Colors.black),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

// ─── Retrain button ───────────────────────────────────────────────────────────

class _RetrainButton extends ConsumerStatefulWidget {
  @override
  ConsumerState<_RetrainButton> createState() => _RetrainButtonState();
}

class _RetrainButtonState extends ConsumerState<_RetrainButton> {
  bool _busy = false;

  Future<void> _retrain() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Retrain ML models?',
          style: GoogleFonts.patrickHand(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This incorporates all new user ratings into the recommendation models. '
          'It may take a minute.',
          style: GoogleFonts.patrickHand(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.patrickHand()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3A436),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Retrain', style: GoogleFonts.patrickHand(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await DioClient.main.post('/ml/retrain');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFBFE3C0),
            content: Text(
              'Models retrained successfully.',
              style: GoogleFonts.patrickHand(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        );
        ref.invalidate(libraryRecommendationsControllerProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade300,
            content: Text(
              'Retrain failed. Check the ML service.',
              style: GoogleFonts.patrickHand(color: Colors.black),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: _busy
          ? const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
            )
          : IconButton(
              tooltip: 'Retrain models',
              icon: const Icon(Icons.model_training, color: Colors.white),
              onPressed: _retrain,
            ),
    );
  }
}
