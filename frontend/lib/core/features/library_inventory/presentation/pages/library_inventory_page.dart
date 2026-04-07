import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/network/clients/books_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/core/utils/appbar.dart';

import '../../../home/presentation/state_management/user_library_provider.dart';
import '../state_management/library_inventory_provider.dart';

class LibraryInventoryPage extends ConsumerWidget {
  const LibraryInventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(libraryInventoryProvider);
    final userId = ref.watch(sessionProvider).userId;
    final libraryAsync =
        userId == null ? null : ref.watch(userLibraryProvider(userId));

    return Scaffold(
      appBar: StylishAppBar(title: 'Library Inventory', homepage: false),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitHeight,
            image: AssetImage('assets/images/home.png'),
          ),
        ),
        child: inventoryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _CenteredMessage(
            title: 'Could not load inventory.',
            subtitle: '$e',
          ),
          data: (items) {
            final library = libraryAsync?.maybeWhen(
              data: (library) => library,
              orElse: () => null,
            );
            final libraryName = library?.name ?? 'Your Library';
            if (library == null) {
              return const _CenteredMessage(
                title: 'No library linked yet.',
                subtitle: 'Assign this librarian account to a library first.',
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
              children: [
                _InventoryHeader(
                  libraryName: libraryName,
                  totalTitles: items.length,
                  lowStockCount: items.where(_isLowStock).length,
                ),
                const SizedBox(height: 18),
                if (items.isEmpty)
                  const _CenteredMessage(
                    title: 'No inventory tracked yet.',
                    subtitle:
                        'Add your first title to start monitoring copy counts.',
                  )
                else
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _InventoryCard(item: item),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: userId == null ||
              libraryAsync?.maybeWhen(
                    data: (library) => library,
                    orElse: () => null,
                  ) ==
                  null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: const Color(0xFFF3A436),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: const BorderSide(color: Colors.black, width: 2),
              ),
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _InventoryEditorSheet(
                  libraryId: libraryAsync!
                      .maybeWhen(
                        data: (library) => library,
                        orElse: () => null,
                      )!
                      .libraryId
                      .toString(),
                ),
              ),
              label: Text(
                'Add Book',
                style: GoogleFonts.patrickHand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: const Icon(Icons.add),
            ),
    );
  }
}

class _InventoryHeader extends StatelessWidget {
  final String libraryName;
  final int totalTitles;
  final int lowStockCount;

  const _InventoryHeader({
    required this.libraryName,
    required this.totalTitles,
    required this.lowStockCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF3A436),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
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
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$totalTitles tracked title${totalTitles == 1 ? '' : 's'} • $lowStockCount low-stock alert${lowStockCount == 1 ? '' : 's'}',
            style: GoogleFonts.patrickHand(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _InventoryCard extends ConsumerWidget {
  final Map<String, dynamic> item;

  const _InventoryCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copiesTotal = (item['copies_total'] as num?)?.toInt() ?? 0;
    final copiesAvailable = (item['copies_available'] as num?)?.toInt() ?? 0;
    final lowStockThreshold =
        (item['low_stock_threshold'] as num?)?.toInt() ?? 0;
    final lowStock = _isLowStock(item);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lowStock ? const Color(0xFFFFE4A0) : const Color(0xFFFFFDF3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title']?.toString() ?? 'Unknown Title',
                      style: GoogleFonts.patrickHand(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3A3329),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${item['author']?.toString() ?? 'Unknown Author'}',
                      style: GoogleFonts.patrickHand(
                        fontSize: 13,
                        color: const Color(0xFF3A3329).withOpacity(0.60),
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(lowStock: lowStock),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _CountBubble(
                label: 'Total',
                value: copiesTotal,
                color: const Color(0xFFB7D8FF),
              ),
              const SizedBox(width: 10),
              _CountBubble(
                label: 'Available',
                value: copiesAvailable,
                color: const Color(0xFFBFE3C0),
              ),
              const SizedBox(width: 10),
              _CountBubble(
                label: 'Alert At',
                value: lowStockThreshold,
                color: const Color(0xFFFFC7C2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _InventoryEditorSheet(
                  libraryId: item['library_id'].toString(),
                  existingItem: item,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black, width: 2),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(
                'Update Counts',
                style: GoogleFonts.patrickHand(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool lowStock;

  const _StatusPill({required this.lowStock});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: lowStock ? const Color(0xFFFFC7C2) : const Color(0xFFBFE3C0),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black, width: 1.8),
      ),
      child: Text(
        lowStock ? 'LOW STOCK' : 'HEALTHY',
        style: GoogleFonts.patrickHand(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CountBubble extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _CountBubble({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 1.6),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: GoogleFonts.patrickHand(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.patrickHand(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryEditorSheet extends ConsumerStatefulWidget {
  final String libraryId;
  final Map<String, dynamic>? existingItem;

  const _InventoryEditorSheet({
    required this.libraryId,
    this.existingItem,
  });

  @override
  ConsumerState<_InventoryEditorSheet> createState() =>
      _InventoryEditorSheetState();
}

class _InventoryEditorSheetState extends ConsumerState<_InventoryEditorSheet> {
  final _searchCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _availableCtrl = TextEditingController();
  final _thresholdCtrl = TextEditingController();
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _filteredBooks = [];
  String? _selectedBookId;
  bool _loadingBooks = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    if (item != null) {
      _selectedBookId = item['book_id'].toString();
      _totalCtrl.text =
          ((item['copies_total'] as num?)?.toInt() ?? 0).toString();
      _availableCtrl.text =
          ((item['copies_available'] as num?)?.toInt() ?? 0).toString();
      _thresholdCtrl.text =
          ((item['low_stock_threshold'] as num?)?.toInt() ?? 1).toString();
      _searchCtrl.text = item['title']?.toString() ?? '';
    } else {
      _totalCtrl.text = '1';
      _availableCtrl.text = '1';
      _thresholdCtrl.text = '1';
    }
    _searchCtrl.addListener(_filterBooks);
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final raw = await BooksApiClient(DioClient.main).getAllBooks();
      if (!mounted) return;
      setState(() {
        _books = raw.cast<Map<String, dynamic>>();
        _filteredBooks = _books;
        _loadingBooks = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingBooks = false);
    }
  }

  void _filterBooks() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredBooks = q.isEmpty
          ? _books
          : _books.where((book) {
              final title = (book['title']?.toString() ?? '').toLowerCase();
              final author = (book['author']?.toString() ?? '').toLowerCase();
              return title.contains(q) || author.contains(q);
            }).toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _totalCtrl.dispose();
    _availableCtrl.dispose();
    _thresholdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.black, width: 2),
          left: BorderSide(color: Colors.black, width: 2),
          right: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              widget.existingItem == null
                  ? 'Add Inventory Item'
                  : 'Update Inventory',
              style: GoogleFonts.patrickHand(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3A3329),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchCtrl,
                decoration: _inputDecoration('Search title or author'),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _loadingBooks
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredBooks.length,
                      itemBuilder: (_, index) {
                        final book = _filteredBooks[index];
                        final bookId = book['book_id'].toString();
                        final selected = _selectedBookId == bookId;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            tileColor: selected
                                ? const Color(0xFFB7D8FF)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(
                                  color: Colors.black, width: 1.5),
                            ),
                            title: Text(
                              book['title']?.toString() ?? 'Unknown Title',
                              style: GoogleFonts.patrickHand(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              book['author']?.toString() ?? 'Unknown Author',
                              style: GoogleFonts.patrickHand(fontSize: 13),
                            ),
                            trailing: selected
                                ? const Icon(Icons.check_circle,
                                    color: Colors.black)
                                : null,
                            onTap: () => setState(() {
                              _selectedBookId = bookId;
                              _searchCtrl.text =
                                  book['title']?.toString() ?? '';
                            }),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _totalCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Total'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _availableCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Available'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _thresholdCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Alert At'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3A436),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    side: const BorderSide(color: Colors.black, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          'Save Inventory',
                          style: GoogleFonts.patrickHand(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final selectedBookId = _selectedBookId;
    final total = int.tryParse(_totalCtrl.text.trim());
    final available = int.tryParse(_availableCtrl.text.trim());
    final threshold = int.tryParse(_thresholdCtrl.text.trim());

    if (selectedBookId == null ||
        total == null ||
        available == null ||
        threshold == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a book and enter valid counts.')),
      );
      return;
    }

    if (available > total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Available copies cannot exceed total copies.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(libraryInventoryProvider.notifier).saveInventoryItem(
            libraryId: widget.libraryId,
            bookId: selectedBookId,
            copiesTotal: total,
            copiesAvailable: available,
            lowStockThreshold: threshold,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventory saved.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save inventory.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final String title;
  final String subtitle;

  const _CenteredMessage({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.patrickHand(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3A3329),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.patrickHand(
                fontSize: 15,
                color: const Color(0xFF3A3329).withOpacity(0.58),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _isLowStock(Map<String, dynamic> item) {
  final available = (item['copies_available'] as num?)?.toInt() ?? 0;
  final threshold = (item['low_stock_threshold'] as num?)?.toInt() ?? 0;
  return available <= threshold;
}
