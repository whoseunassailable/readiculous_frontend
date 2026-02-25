// lib/core/session/session_state.dart
class SessionState {
  final String? role;
  final String? email;
  final String? userId;
  final String? token;
  final bool initialized;

  const SessionState({
    this.role,
    this.email,
    this.userId,
    this.token,
    this.initialized = false,
  });

  SessionState copyWith({
    String? role,
    String? email,
    String? userId,
    String? token,
    bool? initialized,
  }) {
    return SessionState(
      role: role ?? this.role,
      email: email ?? this.email,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      initialized: initialized ?? this.initialized,
    );
  }
}
