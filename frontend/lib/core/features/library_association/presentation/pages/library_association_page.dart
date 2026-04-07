import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/constants/app_roles.dart';
import 'package:readiculous_frontend/core/network/clients/librarians_api_client.dart';
import 'package:readiculous_frontend/core/network/clients/libraries_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/core/utils/appbar.dart';

import '../../../home/presentation/state_management/user_library_provider.dart';

final allLibrariesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final raw = await LibrariesApiClient(DioClient.main).getAllLibraries();
  final items = raw.cast<Map<String, dynamic>>().toList()
    ..sort((a, b) => (a['name']?.toString() ?? '')
        .toLowerCase()
        .compareTo((b['name']?.toString() ?? '').toLowerCase()));
  return items;
});

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

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final librariesAsync = ref.watch(allLibrariesProvider);
    final userId = session.userId;
    final role = session.role;
    final currentLibraryAsync =
        userId == null ? null : ref.watch(userLibraryProvider(userId));

    return Scaffold(
      appBar: StylishAppBar(title: 'Library Association', homepage: false),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitHeight,
            image: AssetImage('assets/images/home.png'),
          ),
        ),
        child: librariesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _StatusMessage(
            title: 'Could not load libraries.',
            subtitle: '$e',
          ),
          data: (libraries) {
            final currentLibrary = currentLibraryAsync?.maybeWhen(
              data: (library) => library,
              orElse: () => null,
            );
            _selectedLibraryId ??= currentLibrary?.libraryId.toString();

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
              children: [
                _HeaderCard(
                  role: role,
                  currentLibraryName: currentLibrary?.name,
                ),
                const SizedBox(height: 18),
                ...libraries.map(
                  (library) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LibraryCard(
                      library: library,
                      selected: _selectedLibraryId ==
                          library['library_id'].toString(),
                      isCurrent: currentLibrary?.libraryId.toString() ==
                          library['library_id'].toString(),
                      onTap: () => setState(
                        () =>
                            _selectedLibraryId = library['library_id'].toString(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _SaveButton(
                  saving: _saving,
                  enabled: userId != null && _selectedLibraryId != null,
                  label: role == AppRoles.librarian
                      ? 'Save Association'
                      : 'Save Library',
                  onPressed: () => _saveAssociation(
                    context,
                    userId!,
                    role ?? AppRoles.user,
                  ),
                ),
              ],
            );
          },
        ),
      ),
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
      ref.invalidate(userLibraryProvider(userId));

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            role == AppRoles.librarian
                ? 'Library association saved.'
                : 'Preferred library saved.',
          ),
        ),
      );
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

class _HeaderCard extends StatelessWidget {
  final String? role;
  final String? currentLibraryName;

  const _HeaderCard({
    required this.role,
    required this.currentLibraryName,
  });

  @override
  Widget build(BuildContext context) {
    final isLibrarian = role == AppRoles.librarian;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFB7D8FF),
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
            isLibrarian ? 'Your Library Base' : 'Browse Libraries',
            style: GoogleFonts.patrickHand(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            currentLibraryName == null
                ? (isLibrarian
                    ? 'Pick the branch you manage so trends, picks, and inventory stay in sync.'
                    : 'Pick the library you want your reading activity to count toward.')
                : 'Current association: $currentLibraryName',
            style: GoogleFonts.patrickHand(
              fontSize: 14,
              color: Colors.black.withOpacity(0.72),
            ),
          ),
        ],
      ),
    );
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFBFE3C0) : const Color(0xFFFFFDF3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isCurrent ? Icons.verified : Icons.local_library_outlined,
              color: Colors.black,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    library['name']?.toString() ?? 'Unnamed Library',
                    style: GoogleFonts.patrickHand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3A3329),
                    ),
                  ),
                  if (location != null && location.isNotEmpty)
                    Text(
                      location,
                      style: GoogleFonts.patrickHand(
                        fontSize: 13,
                        color: const Color(0xFF3A3329).withOpacity(0.60),
                      ),
                    ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: Colors.black, size: 22),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool saving;
  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  const _SaveButton({
    required this.saving,
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: enabled && !saving ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF3A436),
          foregroundColor: Colors.black,
          elevation: 0,
          side: const BorderSide(color: Colors.black, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.black),
              )
            : Text(
                label,
                style: GoogleFonts.patrickHand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StatusMessage({
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.patrickHand(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
