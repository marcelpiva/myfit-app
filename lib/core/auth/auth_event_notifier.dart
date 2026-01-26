import 'dart:async';

/// Singleton notifier for auth events across the app.
/// Used to communicate auth failures from the API interceptor
/// to the auth provider without creating circular dependencies.
class AuthEventNotifier {
  static final AuthEventNotifier _instance = AuthEventNotifier._();
  static AuthEventNotifier get instance => _instance;

  AuthEventNotifier._();

  final _controller = StreamController<AuthEvent>.broadcast();

  /// Stream of auth events that listeners can subscribe to
  Stream<AuthEvent> get stream => _controller.stream;

  /// Emit a forced logout event (e.g., when token refresh fails)
  void emitForceLogout({String? reason}) {
    _controller.add(AuthEvent.forceLogout(reason: reason));
  }

  /// Dispose the controller (typically never called for singletons)
  void dispose() {
    _controller.close();
  }
}

/// Auth event types
enum AuthEventType {
  forceLogout,
}

/// Auth event with optional data
class AuthEvent {
  final AuthEventType type;
  final String? reason;

  AuthEvent._({required this.type, this.reason});

  factory AuthEvent.forceLogout({String? reason}) {
    return AuthEvent._(type: AuthEventType.forceLogout, reason: reason);
  }
}
