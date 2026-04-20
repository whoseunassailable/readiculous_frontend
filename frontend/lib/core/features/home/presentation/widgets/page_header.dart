import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/constants/app_roles.dart';
import 'package:readiculous_frontend/core/constants/routes.dart';
import 'package:readiculous_frontend/core/features/home/presentation/state_management/user_library_provider.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';

import '../../../../../generated/l10n.dart';

class PageHeader extends ConsumerStatefulWidget {
  final double height;
  final double width;

  const PageHeader({super.key, required this.height, required this.width});

  @override
  ConsumerState<PageHeader> createState() => _PageHeaderState();
}

class _PageHeaderState extends ConsumerState<PageHeader> {
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final userRole = session.role;
    final userId = session.userId;

    String subText;
    bool hasLibrary = false;
    if (userId != null) {
      final libraryAsync = ref.watch(userLibraryProvider(userId));
      libraryAsync.whenData((lib) => hasLibrary = lib != null);
      subText = libraryAsync.when(
        loading: () => 'Loading library…',
        error: (_, __) => 'No library assigned',
        data: (library) => library?.name ?? 'No library assigned',
      );
    } else {
      subText = 'Discover your next read';
    }

    final showChangeButton = userId != null && userRole != AppRoles.librarian;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        widget.width * 0.16,
        widget.height * 0.095,
        widget.width * 0.12,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/icons/library_pulse_icon.png',
                height: widget.height / 25,
              ),
              SizedBox(width: widget.width / 40),
              Text(
                S.of(context).libraryPulse,
                style: TextStyle(
                  fontSize: widget.height / 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  subText,
                  style: TextStyle(fontSize: widget.height / 60),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showChangeButton) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => context.pushNamed(RouteNames.libraryAssociation),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3A436),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.black, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      hasLibrary ? 'Change' : 'Select',
                      style: GoogleFonts.patrickHand(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
