// lib/core/session/session_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_notifier.dart';
import 'session_state.dart';

final sessionProvider =
    NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);

// Optional helper provider to ensure init runs once
final sessionInitProvider = FutureProvider<void>((ref) async {
  await ref.read(sessionProvider.notifier).init();
});
