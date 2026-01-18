import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../core/services/auth_service.dart';
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

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserResponse? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
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

  AuthNotifier(this._authService, this._ref) : super(const AuthState());

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
      _ref.read(activeContextProvider.notifier).state = null;
      _ref.invalidate(membershipsProvider);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: response.user,
      );

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
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final response = await _authService.register(
        email: email,
        password: password,
        name: name,
      );

      _ref.read(currentUserProvider.notifier).state = response.user;
      _ref.read(activeContextProvider.notifier).state = null;
      _ref.invalidate(membershipsProvider);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: response.user,
      );

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

  /// Logout user
  Future<void> logout() async {
    await _authService.logout();
    _ref.read(currentUserProvider.notifier).state = null;
    _ref.read(activeContextProvider.notifier).state = null;
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
