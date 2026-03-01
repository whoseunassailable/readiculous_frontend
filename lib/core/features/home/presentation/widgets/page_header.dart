import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';

import '../../../../../generated/l10n.dart';
import '../../application/providers/home_providers.dart';

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
    final userRole = ref.watch(sessionProvider).role;
    final userId = ref.watch(sessionProvider).userId; // however you store it
    // Only watch the library provider when we actually have a userId.
    final libAsync = userId == null
        ? const AsyncValue<dynamic>.data(null)
        : ref.watch(userLibraryProvider(userId));

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
            (userRole == 'librarian')
                ? libAsync.when(
                    data: (lib) => Text(
                      lib?.name ?? "No library assigned",
                      style: TextStyle(fontSize: widget.height / 60),
                    ),
                    loading: () => Text(
                      "Loading...",
                      style: TextStyle(fontSize: widget.height / 60),
                    ),
                    error: (e, st) => Text(
                      "Error: $e",
                      style: TextStyle(fontSize: widget.height / 60),
                    ),
                  )
                : Text(
                    S.of(context).whatReadersWant,
                    style: TextStyle(fontSize: widget.height / 60),
                  ),
          ],
        ),
      ],
    );
  }
}
