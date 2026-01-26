import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_event_notifier.dart';
import '../../../../core/error/api_exceptions.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../data/models/auth_models.dart';

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Current authenticated user state
final currentUserProvider = StateProvider<UserResponse?>((ref) => null);

/// Auth state for tracking login/register operations
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Auth state class
class AuthState {
  final AuthStatus status;
  final UserResponse? user;
  final String? errorMessage;
  final bool? isNewUser;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isNewUser,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserResponse? user,
    String? errorMessage,
    bool? isNewUser,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get hasError => status == AuthStatus.error;
}

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref _ref;
  StreamSubscription<AuthEvent>? _authEventSubscription;

  AuthNotifier(this._authService, this._ref) : super(const AuthState()) {
    // Listen for force logout events from the API interceptor
    _authEventSubscription = AuthEventNotifier.instance.stream.listen(_onAuthEvent);
  }

  @override
  void dispose() {
    _authEventSubscription?.cancel();
    super.dispose();
  }

  /// Handle auth events from the interceptor
  void _onAuthEvent(AuthEvent event) {
    switch (event.type) {
      case AuthEventType.forceLogout:
        _handleForceLogout(event.reason);
        break;
    }
  }

  /// Handle force logout (triggered by API 401 errors)
  void _handleForceLogout(String? reason) {
    // Clear local state without calling logout API (already unauthorized)
    _ref.read(currentUserProvider.notifier).state = null;
    _ref.read(activeContextProvider.notifier).setContext(null);
    _ref.invalidate(membershipsProvider);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Initialize push notifications (only on mobile platforms)
  Future<void> _initPushNotifications() async {
    if (!kIsWeb) {
      final pushService = PushNotificationService();
      await pushService.init();
      // Re-register token to ensure it's sent with valid auth
      await pushService.registerToken();
    }
  }

  /// Check if user is already authenticated (on app start)
  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _ref.read(currentUserProvider.notifier).state = user;
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
        );
        // Initialize push notifications after successful auth check
        _initPushNotifications();
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      _ref.read(currentUserProvider.notifier).state = response.user;
      _ref.read(activeContextProvider.notifier).setContext(null);
      _ref.invalidate(membershipsProvider);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: response.user,
      );

      // Initialize push notifications after successful login
      _initPushNotifications();

      return true;
    } on ApiException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.userMessage,
      );
      return false;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: 'Erro ao fazer login. Tente novamente.',
      );
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String userType = 'student',
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final response = await _authService.register(
        email: email,
        password: password,
        name: name,
        userType: userType,
      );

      _ref.read(currentUserProvider.notifier).state = response.user;
      _ref.read(activeContextProvider.notifier).setContext(null);
      _ref.invalidate(membershipsProvider);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: response.user,
      );

      // Initialize push notifications after successful registration
      _initPushNotifications();

      return true;
    } on ApiException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.userMessage,
      );
      return false;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: 'Erro ao criar conta. Tente novamente.',
      );
      return false;
    }
  }

  /// Send email verification code
  Future<bool> sendVerificationCode({required String email}) async {
    return _authService.sendVerificationCode(email: email);
  }

  /// Verify email with code
  Future<bool> verifyEmail({
    required String email,
    required String code,
  }) async {
    final success = await _authService.verifyEmailCode(email: email, code: code);
    if (success && state.user != null) {
      // Update user state to reflect verified status
      final updatedUser = await _authService.getCurrentUser();
      if (updatedUser != null) {
        _ref.read(currentUserProvider.notifier).state = updatedUser;
        state = state.copyWith(user: updatedUser);
      }
    }
    return success;
  }

  /// Login with Google
  /// Includes automatic retry for transient network errors
  Future<bool> loginWithGoogle({
    required String idToken,
    String? userType,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    // Retry logic for transient errors after Google auth popup
    // The first request often fails due to network state recovery after popup closes
    const maxRetries = 3;
    ApiException? lastError;

    for (var attempt = 0; attempt < maxRetries; attempt++) {
      // Small delay before first attempt to let network recover after popup
      if (attempt == 0) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      try {
        final response = await _authService.loginWithGoogle(
          idToken: idToken,
          userType: userType,
        );

        _ref.read(currentUserProvider.notifier).state = response.user;
        _ref.read(activeContextProvider.notifier).setContext(null);
        _ref.invalidate(membershipsProvider);
        state = AuthState(
          status: AuthStatus.authenticated,
          user: response.user,
          isNewUser: response.isNewUser,
        );

        _initPushNotifications();
        return true;
      } on ApiException catch (e) {
        lastError = e;
        // Only retry on retryable errors (network, server errors)
        if (e.isRetryable && attempt < maxRetries - 1) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
          continue;
        }
        break;
      } catch (e) {
        // Retry on unknown errors too (might be transient)
        if (attempt < maxRetries - 1) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
          continue;
        }
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: 'Erro ao fazer login com Google.',
        );
        return false;
      }
    }

    state = AuthState(
      status: AuthStatus.error,
      errorMessage: lastError?.userMessage ?? 'Erro ao fazer login com Google.',
    );
    return false;
  }

  /// Login with Apple
  /// Includes automatic retry for transient network errors
  Future<bool> loginWithApple({
    required String idToken,
    String? userName,
    String? userType,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    // Retry logic for transient errors after Apple auth popup
    const maxRetries = 3;
    ApiException? lastError;

    for (var attempt = 0; attempt < maxRetries; attempt++) {
      // Small delay before first attempt to let network recover after popup
      if (attempt == 0) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      try {
        final response = await _authService.loginWithApple(
          idToken: idToken,
          userName: userName,
          userType: userType,
        );

        _ref.read(currentUserProvider.notifier).state = response.user;
        _ref.read(activeContextProvider.notifier).setContext(null);
        _ref.invalidate(membershipsProvider);
        state = AuthState(
          status: AuthStatus.authenticated,
          user: response.user,
          isNewUser: response.isNewUser,
        );

        _initPushNotifications();
        return true;
      } on ApiException catch (e) {
        lastError = e;
        // Only retry on retryable errors (network, server errors)
        if (e.isRetryable && attempt < maxRetries - 1) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
          continue;
        }
        break;
      } catch (e) {
        // Retry on unknown errors too (might be transient)
        if (attempt < maxRetries - 1) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
          continue;
        }
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: 'Erro ao fazer login com Apple.',
        );
        return false;
      }
    }

    state = AuthState(
      status: AuthStatus.error,
      errorMessage: lastError?.userMessage ?? 'Erro ao fazer login com Apple.',
    );
    return false;
  }

  /// Logout user
  Future<void> logout() async {
    await _authService.logout();
    _ref.read(currentUserProvider.notifier).state = null;
    _ref.read(activeContextProvider.notifier).setContext(null);
    _ref.invalidate(membershipsProvider);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Clear error state
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(
        status: AuthStatus.initial,
        errorMessage: null,
      );
    }
  }
}

/// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});

/// Helper provider to check if user is logged in
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

/// Helper provider to get current user
final userProvider = Provider<UserResponse?>((ref) {
  return ref.watch(currentUserProvider);
});
