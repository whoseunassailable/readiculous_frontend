import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/constants/app_roles.dart';
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
    if (userRole == AppRoles.librarian && userId != null) {
      final libraryAsync = ref.watch(userLibraryProvider(userId));
      subText = libraryAsync.when(
        loading: () => 'Loading library…',
        error: (_, __) => 'No library assigned',
        data: (library) => library?.name ?? 'No library assigned',
      );
    } else {
      subText = 'Discover your next read';
    }

    return Column(
      children: [
        SizedBox(height: widget.height / 8.3),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(width: widget.width / 6),
            Image.asset(
              'assets/icons/library_pulse_icon.png',
              height: widget.height / 25,
            ),
            SizedBox(width: widget.width / 25),
            Text(
              S.of(context).libraryPulse,
              style: TextStyle(
                  fontSize: widget.height / 30, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(width: widget.width / 6),
            Text(
              subText,
              style: TextStyle(fontSize: widget.height / 60),
            ),
          ],
        ),
      ],
    );
  }
}
