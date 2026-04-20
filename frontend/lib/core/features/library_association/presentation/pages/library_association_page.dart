import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/cache/app_cache_service.dart';
import 'package:readiculous_frontend/core/constants/app_roles.dart';
import 'package:readiculous_frontend/core/network/clients/librarians_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';

import '../../../home/presentation/state_management/user_library_provider.dart';
import '../state_management/libraries_provider.dart';

class LibraryAssociationPage extends ConsumerStatefulWidget {
  const LibraryAssociationPage({super.key});

  @override
  ConsumerState<LibraryAssociationPage> createState() =>
      _LibraryAssociationPageState();
}

class _LibraryAssociationPageState
    extends ConsumerState<LibraryAssociationPage> {
  String? _selectedLibraryId;
  bool _saving = false;
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

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> libraries) {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return libraries;
    return libraries.where((lib) {
      final name = (lib['name']?.toString() ?? '').toLowerCase();
      final location = (lib['location']?.toString() ?? '').toLowerCase();
      return name.contains(q) || location.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final librariesAsync = ref.watch(allLibrariesProvider);
    final userId = session.userId;
    final role = session.role;
    final currentLibraryAsync =
        userId == null ? null : ref.watch(userLibraryProvider(userId));

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
              // ── Search bar ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.80),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          offset: Offset(2, 2),
                          blurRadius: 0),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: GoogleFonts.patrickHand(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Search by city, zip, name…',
                      hintStyle: GoogleFonts.patrickHand(
                          color: Colors.black38, fontSize: 14),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.black54),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () => _searchCtrl.clear(),
                              child: const Icon(Icons.close,
                                  color: Colors.black45, size: 20),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // ── List ──
              Expanded(
                child: librariesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text(
                      'Could not load libraries.\n$e',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.patrickHand(fontSize: 16),
                    ),
                  ),
                  data: (libraries) {
                    final currentLibrary = currentLibraryAsync?.maybeWhen(
                      data: (library) => library,
                      orElse: () => null,
                    );
                    _selectedLibraryId ??=
                        currentLibrary?.libraryId.toString();

                    final filtered = _filter(libraries);

                    return ListView(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      children: [
                        // Current association banner
                        if (currentLibrary != null) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB7D8FF).withOpacity(0.80),
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: Colors.black, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(2, 2),
                                    blurRadius: 0),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified,
                                    color: Colors.black, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Current: ${currentLibrary.name}',
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
                          const SizedBox(height: 12),
                        ],
                        if (filtered.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Center(
                              child: Text(
                                'No libraries match\n"${_searchCtrl.text}"',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.patrickHand(
                                  fontSize: 17,
                                  color: const Color(0xFF3A3329)
                                      .withOpacity(0.55),
                                ),
                              ),
                            ),
                          )
                        else
                          ...filtered.map(
                            (library) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _LibraryCard(
                                library: library,
                                selected: _selectedLibraryId ==
                                    library['library_id'].toString(),
                                isCurrent:
                                    currentLibrary?.libraryId.toString() ==
                                        library['library_id'].toString(),
                                onTap: () => setState(
                                  () => _selectedLibraryId =
                                      library['library_id'].toString(),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
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
              onPressed: _saving
                  ? null
                  : () => _saveAssociation(
                      context, userId, role ?? AppRoles.user),
              label: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : Text(
                      role == AppRoles.librarian
                          ? 'Save Association'
                          : 'Save Library',
                      style: GoogleFonts.patrickHand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              icon: _saving ? const SizedBox.shrink() : const Icon(Icons.save_outlined),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _saveAssociation(
    BuildContext context,
    String userId,
    String role,
  ) async {
    if (_selectedLibraryId == null || _saving) return;

    setState(() => _saving = true);
    try {
      if (role == AppRoles.librarian) {
        await LibrariansApiClient(DioClient.main).assignLibrarian({
          'user_id': userId,
          'library_id': int.parse(_selectedLibraryId!),
          'verified': 1,
        });
        await ref.read(sessionProvider.notifier).setRole(AppRoles.librarian);
      } else {
        await DioClient.main.post(
          '/users/$userId/library',
          data: {'library_id': int.parse(_selectedLibraryId!)},
        );
      }
      final libraries = ref.read(allLibrariesProvider).asData?.value;
      final selectedLibrary = libraries?.firstWhere(
        (library) => library['library_id'].toString() == _selectedLibraryId,
        orElse: () => <String, dynamic>{},
      );
      if (selectedLibrary != null && selectedLibrary.isNotEmpty) {
        await AppCacheService.instance.saveCurrentUserLibrary({
          'library_id': selectedLibrary['library_id'],
          'name': selectedLibrary['name'],
          'location': selectedLibrary['location'],
          'verified': selectedLibrary['verified'],
        });
      }
      ref.invalidate(userLibraryProvider(userId));

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFF3A436),
          content: Text(
            role == AppRoles.librarian
                ? 'Library association saved.'
                : 'Preferred library saved.',
            style: GoogleFonts.patrickHand(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      );
      if (context.mounted) context.pop();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save library association.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _LibraryCard extends StatelessWidget {
  final Map<String, dynamic> library;
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
    final location = library['location']?.toString();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFBFE3C0).withOpacity(0.88)
              : Colors.white.withOpacity(0.72),
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
          children: [
            Icon(
              isCurrent ? Icons.verified : Icons.local_library_outlined,
              color: Colors.black,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    library['name']?.toString() ?? 'Unnamed Library',
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
                        Text(
                          location,
                          style: GoogleFonts.patrickHand(
                            fontSize: 13,
                            color: const Color(0xFF3A3329).withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: selected
                  ? const Icon(Icons.check_circle,
                      key: ValueKey('check'), color: Colors.black, size: 22)
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ],
        ),
      ),
    );
  }
}
