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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            widget.width * 0.16,
            widget.height * 0.085,
            widget.width * 0.12,
            0,
          ),
          child: Row(
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
        ),
        SizedBox(height: widget.height / 30),
        LibraryLocationSelector(
          height: widget.height,
          width: widget.width,
          libraryName: subText,
          showChangeButton: showChangeButton,
        ),
      ],
    );
  }
}

class LibraryLocationSelector extends StatelessWidget {
  final double height;
  final double width;
  final String libraryName;
  final bool showChangeButton;

  const LibraryLocationSelector({
    super.key,
    required this.height,
    required this.width,
    required this.libraryName,
    required this.showChangeButton,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: width / 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: height / 25, color: Colors.black),
              SizedBox(width: width / 20),
              Text(
                'Library',
                style: TextStyle(
                    fontSize: height / 30, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFE3C0),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          libraryName,
                          maxLines: 1,
                          style: GoogleFonts.patrickHand(
                            fontSize: height / 55,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (showChangeButton) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => context.pushNamed(RouteNames.libraryAssociation),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3A436).withValues(alpha: 0.9),
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
                    child: const Icon(Icons.tune_rounded,
                        size: 18, color: Colors.black),
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
