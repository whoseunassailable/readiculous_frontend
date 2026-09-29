import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/session/session_provider.dart';
import '../../../../core/utils/appbar.dart';
import '../../../../shared/library/presentation/state_management/library_providers.dart';
import '../../../../shared/recommendations/domain/entities/library_recommendation.dart';
import '../../../../shared/recommendations/domain/entities/restock_advice.dart';
import '../../../../shared/recommendations/presentation/state_management/recommendations_providers.dart';
import '../../domain/entities/idle_book.dart';
import '../state_management/suggested_books_providers.dart';

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.red.shade300,
      content:
          Text(message, style: GoogleFonts.patrickHand(color: Colors.black)),
    ),
  );
}

/// One tab per place a pick can be: waiting for a decision ([state] null),
/// or one of the three decisions. [guide] says what the tab holds.
typedef _PicksTab = ({String label, String? state, String guide, String empty});

const List<_PicksTab> _tabs = [
  (
    label: 'To review',
    state: null,
    guide: 'Suggested titles and books your readers are waiting for. '
        'Check the copies, then decide.',
    empty: 'Nothing to review.\nTap Generate Picks for new suggestions.',
  ),
  (
    label: 'Ordered',
    state: 'ORDERED',
    guide: "Books you've ordered copies of. The copies are added to Stock.",
    empty: 'No ordered books yet.',
  ),
  (
    label: 'Stocked',
    state: 'STOCKED',
    guide: 'Books you have enough copies of for now.',
    empty: 'No stocked books yet.',
  ),
  (
    label: 'Ignored',
    state: 'IGNORED',
    guide: 'Books you decided not to order for now. '
        'Similar books come up less often.',
    empty: 'No ignored books.',
  ),
];

String _copies(int n) => n == 1 ? '1 copy' : '$n copies';

/// What the librarian sees after marking a pick.
String _decisionMessage(String title, String state, {int? copies}) =>
    switch (state) {
      'ORDERED' when copies != null =>
        'Ordered ${_copies(copies)} of "$title". Added to Stock.',
      'ORDERED' => '"$title" moved to Ordered.',
      'STOCKED' => '"$title" marked stocked. No order needed.',
      'IGNORED' => '"$title" ignored for now. Similar books will come up less.',
      _ => '"$title" updated.',
    };

/// The suggestion line under a pick's copies and readers.
String _adviceText(RestockAdvice advice) => switch (advice.reason) {
      RestockReason.shortfall =>
        'Suggested: order ${_copies(advice.suggestedOrder)}.',
      RestockReason.gradual =>
        'Suggested: order ${_copies(advice.suggestedOrder)} for now. '
            'Few read it each month, so order gradually.',
      RestockReason.starter =>
        'Suggested: order 1 copy to try it. New title, demand expected.',
      RestockReason.enoughOnShelf =>
        'Enough copies on the shelf. No need to order.',
      RestockReason.coveredByReturns =>
        'Copies coming back soon will cover it. No need to order.',
      RestockReason.noDemand => 'No demand yet. No need to order.',
    };

bool _inTab(_PicksTab tab, LibraryRecommendation rec) =>
    tab.state == null ? rec.isPending : rec.state == tab.state;

/// A librarian's stocking picks: generate them, then mark each one
/// ordered, stocked or ignored (which also feeds the library's genre trends).
class LibraryPicksPage extends ConsumerWidget {
  const LibraryPicksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(currentLibraryRecommendationsProvider);
    final idleTitles = ref.watch(idleShelfProvider).asData?.value?.totalTitles;

    return DefaultTabController(
      length: _tabs.length + 1,
      child: Scaffold(
        appBar: StylishAppBar(
          title: 'Library Picks',
          actions: [const _HelpButton(), _RetrainButton()],
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
            data: (books) => Column(
              children: [
                _PicksTabBar(
                  labels: [
                    for (final tab in _tabs)
                      '${tab.label} (${books.where((b) => _inTab(tab, b)).length})',
                    'Make space${idleTitles == null ? '' : ' ($idleTitles)'}',
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      for (final tab in _tabs)
                        _PicksList(
                          picks: books.where((b) => _inTab(tab, b)).toList(),
                          tab: tab,
                        ),
                      const _MakeSpaceList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: _GenerateFab(),
      ),
    );
  }
}

// ─── Tabs ─────────────────────────────────────────────────────────────────────

class _PicksTabBar extends StatelessWidget {
  final List<String> labels;

  const _PicksTabBar({required this.labels});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: TabBar(
        // Five tabs don't fit a phone's width side by side.
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: const Color(0xFFF3A436),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: const Color(0xFF3A3329),
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        labelStyle:
            GoogleFonts.patrickHand(fontSize: 15, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.patrickHand(fontSize: 15),
        tabs: [for (final label in labels) Tab(height: 36, text: label)],
      ),
    );
  }
}

class _PicksList extends StatelessWidget {
  final List<LibraryRecommendation> picks;
  final _PicksTab tab;

  const _PicksList({required this.picks, required this.tab});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Bottom padding keeps the last card clear of Generate Picks.
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      // The guide, then the picks (or a note that there are none).
      itemCount: 1 + (picks.isEmpty ? 1 : picks.length),
      itemBuilder: (_, i) {
        if (i == 0) return _TabGuide(text: tab.guide);
        if (picks.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              tab.empty,
              textAlign: TextAlign.center,
              style: GoogleFonts.patrickHand(
                fontSize: 17,
                color: const Color(0xFF3A3329).withValues(alpha: 0.7),
              ),
            ),
          );
        }
        final pick = picks[i - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _LibraryRecCard(
            key: ValueKey(pick.recommendationId),
            recommendation: pick,
          ),
        );
      },
    );
  }
}

class _TabGuide extends StatelessWidget {
  final String text;

  const _TabGuide({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF3).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black26, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFF3A3329)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.patrickHand(
                  fontSize: 14, color: const Color(0xFF3A3329)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Help ─────────────────────────────────────────────────────────────────────

class _HelpButton extends StatelessWidget {
  const _HelpButton();

  static const _points = [
    (
      'Generate Picks',
      'Suggests new titles from what your readers like, and lists books '
          "your readers are waiting for that you can't cover yet."
    ),
    (
      'In stock',
      'Copies on the shelf out of the copies you own. The rest are lent out.'
    ),
    ('Waiting', "This library's readers who want to read it."),
    (
      'Back soon',
      'Lent copies likely returned within a week. An estimate: a reader '
          'reading it counts as a 21-day loan.'
    ),
    (
      'Per month',
      'Readers of this book here each month, averaged over 3 months.'
    ),
    (
      'Suggested order',
      'Waiting minus on the shelf minus back soon. For a book few people '
          "read each month, about a month's worth, so you can order gradually."
    ),
    (
      'Ordered',
      'Order copies. You choose how many (the suggestion is filled in), and '
          "they're added to Stock."
    ),
    ('Stocked', 'You have enough copies for now. Nothing to order.'),
    ('Ignored', 'Not now. Similar books come up less often.'),
    (
      'Make space',
      'Books nobody here has read, borrowed or asked for in 6 months. '
          'Free their copies to make room for books readers want.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'How picks work',
      icon: const Icon(Icons.help_outline, color: Colors.white),
      onPressed: () => showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('How Library Picks work',
              style: GoogleFonts.patrickHand(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (name, meaning) in _points)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: '$name: ',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: meaning),
                      ]),
                      style: GoogleFonts.patrickHand(fontSize: 15),
                    ),
                  ),
                Text(
                  'You can change a decision at any time from any tab.',
                  style: GoogleFonts.patrickHand(
                      fontSize: 15, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Got it', style: GoogleFonts.patrickHand()),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _LibraryRecCard extends ConsumerWidget {
  final LibraryRecommendation recommendation;

  const _LibraryRecCard({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = recommendation.title;
    final author = recommendation.author ?? 'Unknown Author';
    final demandLevel = recommendation.demandLevel ?? 'MEDIUM';
    final advice = RestockAdvice.forPick(recommendation);

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
          // ── Author ──
          Text(
            'by $author',
            style: GoogleFonts.patrickHand(
              fontSize: 13,
              color: const Color(0xFF3A3329).withOpacity(0.60),
            ),
          ),
          const SizedBox(height: 6),
          // ── ML score bar ──
          _ScoreBar(score: recommendation.demandScore),
          const SizedBox(height: 10),
          _StockBox(pick: recommendation, advice: advice),
          const SizedBox(height: 12),
          const Divider(color: Colors.black12, height: 1),
          const SizedBox(height: 10),
          // ── Action buttons ──
          _ActionRow(
            currentState: recommendation.state ?? 'NEW',
            askCopies: () => showDialog<int>(
              context: context,
              builder: (_) => _OrderCopiesDialog(
                title: title,
                suggested: advice.suggestedOrder,
              ),
            ),
            onAction: (newState, copies) async {
              try {
                await ref.read(updateLibraryRecommendationStateProvider).call(
                    recommendation.recommendationId, newState,
                    copies: copies);
                ref.invalidate(libraryRecommendationsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      _decisionMessage(title, newState, copies: copies),
                      style: GoogleFonts.patrickHand(fontSize: 15),
                    ),
                  ));
                }
              } catch (e) {
                if (context.mounted) _showError(context, e.toString());
              }
            },
          ),
        ],
      ),
    );
  }
}

// ─── Copies and readers ───────────────────────────────────────────────────────

class _StockBox extends StatelessWidget {
  final LibraryRecommendation pick;
  final RestockAdvice advice;

  const _StockBox({required this.pick, required this.advice});

  static String _readers(int n) =>
      n == 0 ? 'nobody yet' : (n == 1 ? '1 reader' : '$n readers');

  static String _perMonth(double n) {
    if (n == 0) return 'no readers here yet';
    final shown = n == n.roundToDouble() ? '${n.round()}' : '$n';
    return '~$shown here';
  }

  @override
  Widget build(BuildContext context) {
    final inStock = pick.copiesTotal == 0
        ? 'none yet'
        : '${pick.copiesAvailable} of ${pick.copiesTotal} available'
            '${pick.copiesOut > 0 ? ' (${pick.copiesOut} lent out)' : ''}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1E4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black26, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _factRow(Icons.inventory_2_outlined, 'In stock', inStock),
          _factRow(
              Icons.people_outline, 'Waiting', _readers(pick.readersWaiting)),
          if (pick.copiesOut > 0)
            _factRow(
              Icons.schedule,
              'Back soon',
              pick.backSoon == 0
                  ? 'none expected this week'
                  : '~${pick.backSoon} within 7 days (estimate)',
            ),
          _factRow(Icons.calendar_month_outlined, 'Per month',
              _perMonth(pick.readersPerMonth)),
          const Divider(color: Colors.black12, height: 14),
          Text(
            _adviceText(advice),
            style: GoogleFonts.patrickHand(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3A3329),
            ),
          ),
        ],
      ),
    );
  }
}

/// Asks how many copies to order, starting from the suggestion.
class _OrderCopiesDialog extends StatefulWidget {
  final String title;
  final int suggested;

  const _OrderCopiesDialog({required this.title, required this.suggested});

  @override
  State<_OrderCopiesDialog> createState() => _OrderCopiesDialogState();
}

class _OrderCopiesDialogState extends State<_OrderCopiesDialog> {
  late final _copies = TextEditingController(
      text: '${widget.suggested < 1 ? 1 : widget.suggested}');
  String? _error;

  @override
  void dispose() {
    _copies.dispose();
    super.dispose();
  }

  void _order() {
    final n = int.tryParse(_copies.text.trim());
    if (n == null || n < 1 || n > 500) {
      setState(() => _error = 'Enter a number from 1 to 500');
      return;
    }
    Navigator.pop(context, n);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Order copies',
          style: GoogleFonts.patrickHand(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How many copies of "${widget.title}"? '
            "They're added to Stock.",
            style: GoogleFonts.patrickHand(fontSize: 15),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _copies,
            autofocus: true,
            keyboardType: TextInputType.number,
            onSubmitted: (_) => _order(),
            decoration: InputDecoration(
              labelText: 'Copies',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.patrickHand()),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF3A436),
            foregroundColor: Colors.black,
          ),
          onPressed: _order,
          child: Text('Order',
              style: GoogleFonts.patrickHand(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

/// One labelled fact on a card, e.g. "In stock   3 of 25 available".
Widget _factRow(IconData icon, String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 15, color: const Color(0xFF3A3329)),
          const SizedBox(width: 6),
          SizedBox(
            width: 74,
            child: Text(label,
                style: GoogleFonts.patrickHand(
                    fontSize: 13, color: const Color(0xFF3A3329))),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.patrickHand(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3A3329))),
          ),
        ],
      ),
    );

// ─── Make space ───────────────────────────────────────────────────────────────

/// Books nobody uses, with a suggestion to free their shelf space.
class _MakeSpaceList extends ConsumerWidget {
  const _MakeSpaceList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(idleShelfProvider).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('Could not load idle books.\n$e',
                textAlign: TextAlign.center,
                style: GoogleFonts.patrickHand(fontSize: 16)),
          ),
          data: (shelf) {
            if (shelf == null) {
              return Center(
                child: Text('No library linked yet.',
                    style: GoogleFonts.patrickHand(fontSize: 17)),
              );
            }
            final months = shelf.idleDays ~/ 30;
            final books = shelf.books;
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
              itemCount: 1 + (books.isEmpty ? 1 : books.length),
              itemBuilder: (_, i) {
                if (i == 0) {
                  return _TabGuide(
                    text: books.isEmpty
                        ? 'Books nobody here has used in $months months show '
                            'up here, to free their shelf space.'
                        : '${shelf.totalTitles} titles (${shelf.totalCopies} '
                            'copies) nobody here has read, borrowed or asked '
                            'for in $months months. Free their shelf space for '
                            'books readers want.',
                  );
                }
                if (books.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text('Every book on the shelf is being used.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.patrickHand(
                            fontSize: 17,
                            color: const Color(0xFF3A3329)
                                .withValues(alpha: 0.7))),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _IdleBookCard(
                    key: ValueKey(books[i - 1].bookId),
                    libraryId: shelf.libraryId,
                    book: books[i - 1],
                  ),
                );
              },
            );
          },
        );
  }
}

class _IdleBookCard extends ConsumerStatefulWidget {
  final int libraryId;
  final IdleBook book;

  const _IdleBookCard({super.key, required this.libraryId, required this.book});

  @override
  ConsumerState<_IdleBookCard> createState() => _IdleBookCardState();
}

class _IdleBookCardState extends ConsumerState<_IdleBookCard> {
  bool _removing = false;

  static String _lastUsed(DateTime? at) {
    if (at == null) return 'never';
    final days = DateTime.now().difference(at).inDays;
    return days >= 60 ? '${days ~/ 30} months ago' : '$days days ago';
  }

  Future<void> _free() async {
    final book = widget.book;
    final n = book.copiesToFree;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Free shelf space',
            style: GoogleFonts.patrickHand(fontWeight: FontWeight.bold)),
        content: Text(
          book.removesTitle
              ? 'Remove "${book.title}" from Stock? It\'s the only copy.'
              : 'Remove ${_copies(n)} of "${book.title}" from Stock? '
                  'You\'ll keep 1.',
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
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Remove',
                style: GoogleFonts.patrickHand(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _removing = true);
    try {
      await ref
          .read(removeCopiesProvider)
          .call(widget.libraryId, book.bookId, n);
      ref.invalidate(idleShelfProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          book.removesTitle
              ? '"${book.title}" removed from Stock.'
              : 'Removed ${_copies(n)} of "${book.title}". You kept 1.',
          style: GoogleFonts.patrickHand(fontSize: 15),
        ),
      ));
    } catch (e) {
      if (mounted) _showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _removing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.patrickHand(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3A3329))),
          if (book.author != null)
            Text('by ${book.author}',
                style: GoogleFonts.patrickHand(
                    fontSize: 13,
                    color: const Color(0xFF3A3329).withValues(alpha: 0.6))),
          const SizedBox(height: 8),
          _factRow(Icons.inventory_2_outlined, 'On shelf',
              '${_copies(book.copiesTotal)}, none lent out'),
          _factRow(Icons.history, 'Last used', _lastUsed(book.lastActivity)),
          const Divider(color: Colors.black12, height: 14),
          Text(
            book.removesTitle
                ? 'Suggested: remove it to make space.'
                : 'Suggested: keep 1, free ${_copies(book.copiesToFree)}.',
            style: GoogleFonts.patrickHand(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3A3329)),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _removing ? null : _free,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black, width: 1.5),
              ),
              icon: _removing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.remove_circle_outline, size: 18),
              label: Text(
                book.removesTitle
                    ? 'Remove from Stock'
                    : 'Free ${_copies(book.copiesToFree)}',
                style: GoogleFonts.patrickHand(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
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

  /// How many copies to order (null: cancelled). Asked before ORDERED.
  final Future<int?> Function() askCopies;
  final Future<void> Function(String state, int? copies) onAction;

  const _ActionRow({
    required this.currentState,
    required this.askCopies,
    required this.onAction,
  });

  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  /// The state being saved right now, if any.
  String? _pending;

  static const _actions = [
    ('ORDERED', 'Ordered', Icons.local_shipping_outlined, Color(0xFFF9AA33)),
    ('STOCKED', 'Stocked', Icons.inventory_2_outlined, Color(0xFFBFE3C0)),
    ('IGNORED', 'Ignored', Icons.block, Color(0xFFD9D9D9)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 3, bottom: 6),
          child: Text(
            'Mark as:',
            style: GoogleFonts.patrickHand(
                fontSize: 13, color: const Color(0xFF3A3329)),
          ),
        ),
        Row(children: _actions.map(_button).toList()),
      ],
    );
  }

  Widget _button((String, String, IconData, Color) action) {
    final (state, label, icon, color) = action;
    final busy = _pending != null;
    // What the server has; a failed change simply leaves it as it was.
    final isActive = widget.currentState == state;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: GestureDetector(
          // Ordered stays available: tapping it again orders more.
          onTap: busy || (isActive && state != 'ORDERED')
              ? null
              : () async {
                  // Ask first; show progress only while saving.
                  int? copies;
                  if (state == 'ORDERED') {
                    copies = await widget.askCopies();
                    if (copies == null) return; // cancelled
                  }
                  setState(() => _pending = state);
                  await widget.onAction(state, copies);
                  if (mounted) setState(() => _pending = null);
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? color : color.withValues(alpha: 0.35),
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
              child: _pending == state
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isActive ? Icons.check : icon,
                            size: 15, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          label,
                          style: GoogleFonts.patrickHand(
                            fontSize: 13,
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
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

    setState(() => _loading = true);
    try {
      final library = await ref.read(userLibraryProvider(userId).future);
      if (library == null) {
        if (mounted) {
          _showError(
              context, 'No library associated. Go to Choose Library first.');
        }
        return;
      }
      await ref
          .read(generateLibraryRecommendationsProvider)
          .call(library.libraryId);
      ref.invalidate(libraryRecommendationsProvider);
    } catch (e) {
      // e.g. "No genre preferences found for this library's members"
      if (mounted) _showError(context, 'Could not generate picks: $e');
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
            child: Text('Retrain',
                style: GoogleFonts.patrickHand(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(retrainModelsProvider).call();
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
        ref.invalidate(libraryRecommendationsProvider);
      }
    } catch (e) {
      if (mounted) _showError(context, 'Retrain failed: $e');
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
