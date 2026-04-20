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
    if (userId != null) {
      final libraryAsync = ref.watch(userLibraryProvider(userId));
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
        widget.height * 0.085,
        widget.width * 0.12,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: widget.width / 20),
              Text(
                S.of(context).libraryPulse,
                style: TextStyle(
                  fontSize: widget.height / 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: widget.width / 40),
              Image.asset(
                'assets/icons/library_pulse_icon.png',
                height: widget.height / 25,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: widget.width / 20),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    subText,
                    style: GoogleFonts.patrickHand(
                      fontSize: widget.height / 60,
                      color: const Color(0xFF3A3329).withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (showChangeButton) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () =>
                        context.pushNamed(RouteNames.libraryAssociation),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7C6FF),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: Text(
                        'Change',
                        style: GoogleFonts.patrickHand(
                          fontSize: widget.height / 70,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3A3329),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
