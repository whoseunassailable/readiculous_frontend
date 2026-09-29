import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/constants/app_roles.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/shared/library/domain/entities/library.dart';
import 'package:readiculous_frontend/shared/library/presentation/state_management/library_providers.dart';

import '../state_management/library_association_controller.dart';

class LibraryAssociationPage extends ConsumerStatefulWidget {
  const LibraryAssociationPage({super.key});

  @override
  ConsumerState<LibraryAssociationPage> createState() =>
      _LibraryAssociationPageState();
}

class _LibraryAssociationPageState
    extends ConsumerState<LibraryAssociationPage> {
  int? _selectedLibraryId;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Library> _filter(List<Library> libraries) {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return libraries;
    return libraries
        .where((lib) =>
            lib.name.toLowerCase().contains(q) ||
            (lib.location ?? '').toLowerCase().contains(q))
        .toList();
  }

  /// Saved → confirm and go back; failed → say why (e.g. "Library not
  /// found") and stay.
  void _onSaveStateChanged(AsyncValue<void>? previous, AsyncValue<void> next) {
    next.whenOrNull(
      data: (_) {
        if (previous?.isLoading != true) return;
        final isLibrarian =
            ref.read(sessionProvider).role == AppRoles.librarian;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFF3A436),
            content: Text(
              isLibrarian
                  ? 'Library association saved.'
                  : 'Preferred library saved.',
              style: GoogleFonts.patrickHand(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
        );
        context.pop();
      },
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save library: $error')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      libraryAssociationControllerProvider,
      _onSaveStateChanged,
    );
    final saving = ref.watch(
      libraryAssociationControllerProvider.select((s) => s.isLoading),
    );
    final session = ref.watch(sessionProvider);
    final userId = session.userId;
    final isLibrarian = session.role == AppRoles.librarian;
    final currentLibraryAsync =
        userId == null ? null : ref.watch(userLibraryProvider(userId));
    final currentLibrary = currentLibraryAsync?.asData?.value;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/bg_for_add_books.png'),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Custom crayon header ──
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
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Icon(MaterialCommunityIcons.arrow_left,
                            color: Colors.black, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Choose Library',
                      style: GoogleFonts.patrickHand(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3A3329),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(child: _buildPicker(currentLibrary, isLibrarian)),
            ],
          ),
        ),
      ),
      // ── Pinned Save button ──
      floatingActionButton: _selectedLibraryId != null && userId != null
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFFF3A436),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.black, width: 2),
              ),
              elevation: 4,
              onPressed: saving
                  ? null
                  : () => ref
                      .read(libraryAssociationControllerProvider.notifier)
                      .save(_selectedLibraryId!),
              label: saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : Text(
                      isLibrarian ? 'Save Association' : 'Save Library',
                      style: GoogleFonts.patrickHand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              icon: saving
                  ? const SizedBox.shrink()
                  : const Icon(Icons.save_outlined),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// Search bar and library list.
  Widget _buildPicker(Library? currentLibrary, bool isLibrarian) {
    final librariesAsync = ref.watch(allLibrariesProvider);
    return Column(
      children: [
        // ── Search bar ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.80),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, offset: Offset(2, 2), blurRadius: 0),
              ],
            ),
            child: TextField(
              controller: _searchCtrl,
              style: GoogleFonts.patrickHand(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search by city, zip, name…',
                hintStyle: GoogleFonts.patrickHand(
                    color: Colors.black38, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () => _searchCtrl.clear(),
                        child: const Icon(Icons.close,
                            color: Colors.black45, size: 20),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        if (isLibrarian)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Text(
              "Pick the library you manage. You can't change it later.",
              textAlign: TextAlign.center,
              style: GoogleFonts.patrickHand(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3A3329),
              ),
            ),
          ),
        const SizedBox(height: 12),
        // ── List ──
        Expanded(
          child: librariesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                'Could not load libraries.\n$e',
                textAlign: TextAlign.center,
                style: GoogleFonts.patrickHand(fontSize: 16),
              ),
            ),
            data: (libraries) {
              _selectedLibraryId ??= currentLibrary?.libraryId;

              final filtered = _filter(libraries);
              final hasBanner = currentLibrary != null;

              // Built lazily: the full list is ~16.5k libraries.
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: (hasBanner ? 1 : 0) +
                    (filtered.isEmpty ? 1 : filtered.length),
                itemBuilder: (context, index) {
                  if (currentLibrary != null) {
                    if (index == 0) {
                      return _CurrentLibraryBanner(name: currentLibrary.name);
                    }
                    index--;
                  }
                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          'No libraries match\n"${_searchCtrl.text}"',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.patrickHand(
                            fontSize: 17,
                            color:
                                const Color(0xFF3A3329).withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                    );
                  }
                  final library = filtered[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LibraryCard(
                      library: library,
                      selected: _selectedLibraryId == library.libraryId,
                      isCurrent: currentLibrary?.libraryId == library.libraryId,
                      onTap: () => setState(
                          () => _selectedLibraryId = library.libraryId),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CurrentLibraryBanner extends StatelessWidget {
  final String name;

  const _CurrentLibraryBanner({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFB7D8FF).withValues(alpha: 0.80),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, offset: Offset(2, 2), blurRadius: 0),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.verified, color: Colors.black, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Current: $name',
                style: GoogleFonts.patrickHand(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3A3329),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final Library library;
  final bool selected;
  final bool isCurrent;
  final VoidCallback? onTap;

  const _LibraryCard({
    required this.library,
    required this.selected,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final location = library.location;
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textWidth = constraints.maxWidth.clamp(0, 320) * 0.66;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFBFE3C0).withValues(alpha: 0.88)
                  : Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.black,
                width: selected ? 2.5 : 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(selected ? 3 : 2, selected ? 3 : 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isCurrent ? Icons.verified : Icons.local_library_outlined,
                  color: Colors.black,
                  size: 22,
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: textWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        library.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.patrickHand(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3A3329),
                        ),
                      ),
                      if (location != null && location.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.place_outlined,
                                size: 13, color: Colors.black54),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.patrickHand(
                                  fontSize: 13,
                                  color: const Color(0xFF3A3329)
                                      .withValues(alpha: 0.65),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 24,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: selected
                          ? const Icon(Icons.check_circle,
                              key: ValueKey('check'),
                              color: Colors.black,
                              size: 22)
                          : const SizedBox.shrink(key: ValueKey('empty')),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
