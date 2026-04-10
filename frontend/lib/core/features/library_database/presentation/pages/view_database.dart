import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/constants/app_roles.dart';
import 'package:readiculous_frontend/core/constants/routes.dart';
import 'package:readiculous_frontend/core/features/home/presentation/state_management/genres_provider.dart';
import 'package:readiculous_frontend/core/features/home/presentation/state_management/user_library_provider.dart';
import 'package:readiculous_frontend/core/features/library_database/presentation/state_management/library_database_provider.dart';
import 'package:readiculous_frontend/core/network/clients/books_api_client.dart';
import 'package:readiculous_frontend/core/network/clients/library_books_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';

class ViewDatabase extends ConsumerStatefulWidget {
  const ViewDatabase({super.key});

  @override
  ConsumerState<ViewDatabase> createState() => _ViewDatabaseState();
}

class _ViewDatabaseState extends ConsumerState<ViewDatabase> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGenre = 'All Genres';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
  }

  void _handleSearchChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final userId = session.userId;
    final role = session.role;
    final libraryAsync =
        userId == null ? null : ref.watch(userLibraryProvider(userId));
    final inventoryAsync = ref.watch(currentLibraryInventoryProvider);
    final activityAsync = ref.watch(currentLibraryActivityProvider);
    final genresAsync = ref.watch(allGenresProvider);

    String? currentLibraryId;
    if (libraryAsync != null) {
      libraryAsync.whenData((lib) => currentLibraryId = lib?.libraryId.toString());
    }

    return Scaffold(
      floatingActionButton: role == AppRoles.librarian && currentLibraryId != null
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFF3A436),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: const BorderSide(color: Colors.black, width: 2),
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 28),
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _AddBookSheet(libraryId: currentLibraryId!),
              ),
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_page.png'),
            fit: BoxFit.fitHeight,
          ),
        ),
        child: SafeArea(
          child: libraryAsync == null
              ? const _CenteredMessage(
                  title: 'No session found.',
                  subtitle: 'Log in again to view your library.',
                )
              : libraryAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _CenteredMessage(
                    title: 'Could not load your library.',
                    subtitle: '$e',
                  ),
                  data: (library) {
                    if (library == null) {
                      return _NoLibraryAssigned(
                        onChooseLibrary: () =>
                            context.pushNamed(RouteNames.libraryAssociation),
                      );
                    }

                    return genresAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => _DatabaseBody(
                        role: role,
                        libraryName: library.name,
                        libraryLocation: library.location,
                        selectedGenre: _selectedGenre,
                        onGenreChanged: (value) =>
                            setState(() => _selectedGenre = value),
                        searchController: _searchController,
                        availableGenres: const ['All Genres'],
                        inventoryAsync: inventoryAsync,
                        activityAsync: activityAsync,
                      ),
                      data: (genres) => _DatabaseBody(
                        role: role,
                        libraryName: library.name,
                        libraryLocation: library.location,
                        selectedGenre: _selectedGenre,
                        onGenreChanged: (value) =>
                            setState(() => _selectedGenre = value),
                        searchController: _searchController,
                        availableGenres: ['All Genres', ...genres],
                        inventoryAsync: inventoryAsync,
                        activityAsync: activityAsync,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _DatabaseBody extends StatelessWidget {
  final String? role;
  final String libraryName;
  final String? libraryLocation;
  final String selectedGenre;
  final ValueChanged<String> onGenreChanged;
  final TextEditingController searchController;
  final List<String> availableGenres;
  final AsyncValue<List<Map<String, dynamic>>> inventoryAsync;
  final AsyncValue<List<Map<String, dynamic>>> activityAsync;

  const _DatabaseBody({
    required this.role,
    required this.libraryName,
    required this.libraryLocation,
    required this.selectedGenre,
    required this.onGenreChanged,
    required this.searchController,
    required this.availableGenres,
    required this.inventoryAsync,
    required this.activityAsync,
  });

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      children: [
        _PinnedHeader(
          title: 'Library Database',
          trailing: _HeaderAction(
            icon: Icons.home_outlined,
            label: 'Home',
            onTap: () => context.goNamed(RouteNames.homePage),
          ),
        ),
        const SizedBox(height: 14),
        _LibraryPulseCard(
          libraryName: libraryName,
          libraryLocation: libraryLocation,
        ),
        const SizedBox(height: 18),
        _ControlRow(
          selectedGenre: selectedGenre,
          genres: availableGenres,
          onGenreChanged: onGenreChanged,
          searchController: searchController,
        ),
        const SizedBox(height: 12),
        Text(
          'Browse books on the shelf. Use the search or genre filter to narrow down.',
          style: GoogleFonts.patrickHand(
            fontSize: 15,
            color: const Color(0xFF43352A).withOpacity(0.75),
          ),
        ),
        const SizedBox(height: 16),
        inventoryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _PaperNotice(
            title: 'Could not load library books.',
            subtitle: '$e',
          ),
          data: (inventory) {
            final filtered = inventory.where((book) {
              final genres = (book['genres']?.toString() ?? '');
              final matchesGenre = selectedGenre == 'All Genres' ||
                  genres.toLowerCase().contains(selectedGenre.toLowerCase());
              final matchesText = query.isEmpty ||
                  (book['title']?.toString().toLowerCase() ?? '')
                      .contains(query) ||
                  (book['author']?.toString().toLowerCase() ?? '')
                      .contains(query);
              return matchesGenre && matchesText;
            }).toList();

            if (inventory.isEmpty) {
              return const _PaperNotice(
                title: 'No books in this library yet.',
                subtitle: 'A librarian can add books using the + button.',
              );
            }
            if (filtered.isEmpty) {
              return const _PaperNotice(
                title: 'No books match your search.',
                subtitle: 'Try a different title, author, or genre.',
              );
            }

            return _SectionCard(
              title: 'Books on Shelf',
              child: Column(
                children: filtered
                    .map(
                      (book) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _LibraryBookCard(book: book),
                      ),
                    )
                    .toList(),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        activityAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _PaperNotice(
            title: 'Could not load reader activity.',
            subtitle: '$e',
          ),
          data: (activity) {
            if (activity.isEmpty) {
              return const _PaperNotice(
                title: 'No reading activity yet.',
                subtitle: 'When library members add and track books, their activity shows up here.',
              );
            }

            return _SectionCard(
              title: 'What Readers Are Reading',
              child: Column(
                children: activity
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ReaderActivityCard(item: item),
                      ),
                    )
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PinnedHeader extends StatelessWidget {
  final String title;
  final Widget trailing;

  const _PinnedHeader({
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6E4C9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF7A5332), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x553E2A1D),
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.patrickHand(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF342116),
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE7BE8B),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFF7A5332), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF342116)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.patrickHand(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF342116),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryPulseCard extends StatelessWidget {
  final String libraryName;
  final String? libraryLocation;

  const _LibraryPulseCard({
    required this.libraryName,
    required this.libraryLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6E4C9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF7A5332), width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📚', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  libraryName,
                  style: GoogleFonts.patrickHand(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF342116),
                  ),
                ),
                if (libraryLocation != null && libraryLocation!.isNotEmpty)
                  Text(
                    libraryLocation!,
                    style: GoogleFonts.patrickHand(
                      fontSize: 16,
                      color: const Color(0xFF5E4736),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  'What readers nearby are pulling, saving, and asking for right now.',
                  style: GoogleFonts.patrickHand(
                    fontSize: 16,
                    color: const Color(0xFF5E4736),
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

class _ControlRow extends StatelessWidget {
  final String selectedGenre;
  final List<String> genres;
  final ValueChanged<String> onGenreChanged;
  final TextEditingController searchController;

  const _ControlRow({
    required this.selectedGenre,
    required this.genres,
    required this.onGenreChanged,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: _outlinedDecoration(),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedGenre,
                isExpanded: true,
                items: genres
                    .map(
                      (genre) => DropdownMenuItem<String>(
                        value: genre,
                        child: Text(
                          genre,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.patrickHand(
                            fontSize: 16,
                            color: const Color(0xFF342116),
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) onGenreChanged(value);
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 6,
          child: Container(
            decoration: _outlinedDecoration(),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search books...',
                hintStyle: GoogleFonts.patrickHand(),
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _outlinedDecoration() {
    return BoxDecoration(
      color: const Color(0xFFF7EBD8),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF7A5332), width: 2),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8EBDD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF7A5332), width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.patrickHand(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF342116),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _LibraryBookCard extends StatelessWidget {
  final Map<String, dynamic> book;

  const _LibraryBookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final available = num.tryParse(book['copies_available']?.toString() ?? '')?.toInt() ?? 0;
    final total = num.tryParse(book['copies_total']?.toString() ?? '')?.toInt() ?? 0;
    final threshold = num.tryParse(book['low_stock_threshold']?.toString() ?? '')?.toInt() ?? 0;

    String stockLabel;
    Color stockColor;
    IconData stockIcon;
    if (available <= 0) {
      stockLabel = 'Out of Stock';
      stockColor = const Color(0xFFFFC7C2);
      stockIcon = Icons.cancel_outlined;
    } else if (available <= threshold) {
      stockLabel = 'Low Stock';
      stockColor = const Color(0xFFFFE4A0);
      stockIcon = Icons.warning_amber_rounded;
    } else {
      stockLabel = 'In Stock';
      stockColor = const Color(0xFFBFE3C0);
      stockIcon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB98A5D), width: 2),
      ),
      child: InkWell(
        onTap: () => context.pushNamed(
          RouteNames.viewBookDetailsPage,
          extra: {
            ...book,
            'stock_label': stockLabel,
          },
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFB7D8FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF7A5332), width: 2),
              ),
              child:
                  const Icon(Icons.menu_book_rounded, color: Color(0xFF342116)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['title']?.toString() ?? 'Unknown Title',
                    style: GoogleFonts.patrickHand(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF342116),
                    ),
                  ),
                  Text(
                    book['author']?.toString() ?? 'Unknown Author',
                    style: GoogleFonts.patrickHand(
                      fontSize: 16,
                      color: const Color(0xFF5E4736),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if ((book['genres']?.toString() ?? '').isNotEmpty)
                        _MiniPill(
                          label:
                              book['genres'].toString().split(',').first.trim(),
                          color: const Color(0xFFB7D8FF),
                        ),
                      Text(
                        '$available of $total available',
                        style: GoogleFonts.patrickHand(
                          fontSize: 16,
                          color: const Color(0xFF6A5039),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: stockColor,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF7A5332), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(stockIcon, size: 16, color: const Color(0xFF342116)),
                  const SizedBox(width: 4),
                  Text(
                    stockLabel,
                    style: GoogleFonts.patrickHand(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF342116),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReaderActivityCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ReaderActivityCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final readingCount = num.tryParse(item['reading_count']?.toString() ?? '')?.toInt() ?? 0;
    final wantCount = num.tryParse(item['want_to_read_count']?.toString() ?? '')?.toInt() ?? 0;
    final readCount = num.tryParse(item['read_count']?.toString() ?? '')?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB98A5D), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['title']?.toString() ?? 'Unknown Title',
            style: GoogleFonts.patrickHand(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF342116),
            ),
          ),
          Text(
            item['author']?.toString() ?? 'Unknown Author',
            style: GoogleFonts.patrickHand(
              fontSize: 15,
              color: const Color(0xFF5E4736),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (readingCount > 0)
                _MiniPill(
                  label: '$readingCount reading now',
                  color: const Color(0xFFBFE3C0),
                ),
              if (wantCount > 0)
                _MiniPill(
                  label: '$wantCount queued',
                  color: const Color(0xFFFFE4A0),
                ),
              if (readCount > 0)
                _MiniPill(
                  label: '$readCount finished',
                  color: const Color(0xFFD7C6FF),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['reader_names']?.toString() ?? 'No readers listed',
            style: GoogleFonts.patrickHand(
              fontSize: 15,
              color: const Color(0xFF5E4736),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF7A5332), width: 1.2),
      ),
      child: Text(
        label,
        style: GoogleFonts.patrickHand(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF342116),
        ),
      ),
    );
  }
}

class _PaperNotice extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PaperNotice({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8EBDD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB98A5D), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.patrickHand(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF342116),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.patrickHand(
              fontSize: 16,
              color: const Color(0xFF5E4736),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoLibraryAssigned extends StatelessWidget {
  final VoidCallback onChooseLibrary;

  const _NoLibraryAssigned({required this.onChooseLibrary});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pick Your Library First',
              style: GoogleFonts.patrickHand(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF342116),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Choose a library so we can show what is on the shelves and what nearby readers are reading.',
              textAlign: TextAlign.center,
              style: GoogleFonts.patrickHand(
                fontSize: 18,
                color: const Color(0xFF5E4736),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onChooseLibrary,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE7BE8B),
                foregroundColor: const Color(0xFF342116),
                side: const BorderSide(color: Color(0xFF7A5332), width: 2),
              ),
              child: Text(
                'Choose Library',
                style: GoogleFonts.patrickHand(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.patrickHand(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF342116),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.patrickHand(
                fontSize: 17,
                color: const Color(0xFF5E4736),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Book Sheet (librarian only) ─────────────────────────────────────────

class _AddBookSheet extends ConsumerStatefulWidget {
  final String libraryId;
  const _AddBookSheet({required this.libraryId});

  @override
  ConsumerState<_AddBookSheet> createState() => _AddBookSheetState();
}

class _AddBookSheetState extends ConsumerState<_AddBookSheet> {
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _copiesCtrl = TextEditingController(text: '1');
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _descCtrl.dispose();
    _copiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Title is required.');
      return;
    }
    final copies = int.tryParse(_copiesCtrl.text.trim()) ?? 1;

    setState(() { _saving = true; _error = null; });
    try {
      final result = await BooksApiClient(DioClient.main).createBook({
        'title': title,
        'author': _authorCtrl.text.trim().isEmpty ? null : _authorCtrl.text.trim(),
        'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      });
      final bookId = result['book_id']?.toString();
      if (bookId != null) {
        await LibraryBooksApiClient(DioClient.main).addOrUpdateBookInventory({
          'library_id': int.parse(widget.libraryId),
          'book_id': int.parse(bookId),
          'copies_total': copies,
          'copies_available': copies,
        });
      }
      ref.invalidate(currentLibraryInventoryProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _saving = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Container(
      height: h * 0.72,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.black, width: 2),
          left: BorderSide(color: Colors.black, width: 2),
          right: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44, height: 5,
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(999)),
          ),
          const SizedBox(height: 14),
          Text('Add a Book to Library', style: GoogleFonts.patrickHand(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF3A3329))),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _field(_titleCtrl, 'Title *', Icons.menu_book_rounded),
                  const SizedBox(height: 12),
                  _field(_authorCtrl, 'Author', Icons.person_outline),
                  const SizedBox(height: 12),
                  _field(_descCtrl, 'Description (optional)', Icons.notes, maxLines: 3),
                  const SizedBox(height: 12),
                  _field(_copiesCtrl, 'Number of copies', Icons.library_books_outlined, keyboardType: TextInputType.number),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!, style: GoogleFonts.patrickHand(color: Colors.red, fontSize: 14)),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3A436),
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                  shadowColor: Colors.black,
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                    : Text('Add Book', style: GoogleFonts.patrickHand(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 0)],
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.patrickHand(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.patrickHand(color: Colors.black38, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.black54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
