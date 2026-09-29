// lib/core/session/session_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_notifier.dart';
import 'session_state.dart';

final sessionProvider =
    NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);
