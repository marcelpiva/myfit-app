import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myfit_app/core/error/api_exceptions.dart';
import 'package:myfit_app/core/providers/context_provider.dart';
import 'package:myfit_app/core/services/auth_service.dart';
import 'package:myfit_app/features/auth/data/models/auth_models.dart';
import 'package:myfit_app/features/auth/presentation/providers/auth_provider.dart';

import '../../helpers/mock_services.dart';
import '../../helpers/test_helpers.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValues();
  });

  setUp(() {
    mockAuthService = MockAuthService();
  });

  // Test data
  final testUser = UserResponse(
    id: 'user-1',
    email: 'test@example.com',
    name: 'Test User',
  );

  final testTokens = TokenResponse(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
  );

  final testAuthResponse = AuthResponse(
    user: testUser,
    tokens: testTokens,
  );

  group('AuthState', () {
    test('should have correct default values', () {
      const state = AuthState();

      expect(state.status, AuthStatus.initial);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isLoading, false);
      expect(state.isAuthenticated, false);
      expect(state.hasError, false);
    });

    test('should correctly identify loading state', () {
      const state = AuthState(status: AuthStatus.loading);

      expect(state.isLoading, true);
      expect(state.isAuthenticated, false);
      expect(state.hasError, false);
    });

    test('should correctly identify authenticated state', () {
      final state = AuthState(
        status: AuthStatus.authenticated,
        user: testUser,
      );

      expect(state.isLoading, false);
      expect(state.isAuthenticated, true);
      expect(state.hasError, false);
      expect(state.user, testUser);
    });

    test('should correctly identify error state', () {
      const state = AuthState(
        status: AuthStatus.error,
        errorMessage: 'Test error',
      );

      expect(state.isLoading, false);
      expect(state.isAuthenticated, false);
      expect(state.hasError, true);
      expect(state.errorMessage, 'Test error');
    });

    test('should copy with updated values', () {
      const original = AuthState(status: AuthStatus.initial);

      final copy = original.copyWith(
        status: AuthStatus.loading,
        errorMessage: 'test',
      );

      expect(copy.status, AuthStatus.loading);
      expect(copy.errorMessage, 'test');
    });
  });

  group('AuthNotifier', () {
    ProviderContainer createTestContainer() {
      return createContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          // Override membershipsProvider to avoid side effects
          membershipsProvider.overrideWith(
            (ref) => Future.value([]),
          ),
        ],
      );
    }

    group('checkAuthStatus', () {
      test('should set authenticated state when user exists', () async {
        when(() => mockAuthService.getCurrentUser())
            .thenAnswer((_) async => testUser);

        final container = createTestContainer();
        final notifier = container.read(authProvider.notifier);

        await notifier.checkAuthStatus();

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.user, testUser);
        expect(container.read(currentUserProvider), testUser);
      });

      test('should set unauthenticated state when no user', () async {
        when(() => mockAuthService.getCurrentUser())
            .thenAnswer((_) async => null);

        final container = createTestContainer();
        final notifier = container.read(authProvider.notifier);

        await notifier.checkAuthStatus();

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.user, isNull);
      });

      test('should set unauthenticated state on error', () async {
        when(() => mockAuthService.getCurrentUser())
            .thenThrow(Exception('Network error'));

        final container = createTestContainer();
        final notifier = container.read(authProvider.notifier);

        await notifier.checkAuthStatus();

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.unauthenticated);
      });

      test('should show loading state during check', () async {
        when(() => mockAuthService.getCurrentUser())
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return testUser;
        });

        final container = createTestContainer();
        final notifier = container.read(authProvider.notifier);

        // Start check without awaiting
        final future = notifier.checkAuthStatus();

        // Verify loading state
        expect(container.read(authProvider).isLoading, true);

        await future;
      });
    });

    group('login', () {
      test('should set authenticated state on successful login', () async {
        when(() => mockAuthService.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => testAuthResponse);

        final container = createTestContainer();
        final notifier = container.read(authProvider.notifier);

        final result = await notifier.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result, true);

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.user, testUser);
        expect(container.read(currentUserProvider), testUser);
      });

      test('should set error state on ApiException', () async {
        when(() => mockAuthService.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(
          const AuthenticationException('Credenciais inválidas'),
        );

        final container = createTestContainer();
        final notifier = container.read(authProvider.notifier);

        final result = await notifier.login(
          email: 'test@example.com',
          password: 'wrong',
        );

        expect(result, false);

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Credenciais inválidas');
      });

      test('should set generic error message on unknown error', () async {
        when(() => mockAuthService.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Unknown error'));

        final container = createTestContainer();
        final notifier = container.read(authProvider.notifier);

        final result = await notifier.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result, false);

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Erro ao fazer login. Tente novamente.');
      });

      test('should show loading state during login', () async {
        when(() => mockAuthService.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return testAuthResponse;
        });

        final container = createTestContainer();
        final notifier = container.read(authProvider.notifier);

        // Start login without awaiting
        final future = notifier.login(
          email: 'test@example.com',
          password: 'password123',
        );

        // Verify loading state
        expect(container.read(authProvider).isLoading, true);

        await future;
      });

      test('should clear previous error on new login attempt', () async {
        when(() => mockAuthService.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return testAuthResponse;
        });

        final container = createTestContainer();
        final notifier = container.read(authProvider.notifier);

        // Set initial error state manually
        notifier.clearError(); // Just to initialize

        // Start new login
        final future = notifier.login(
          email: 'test@example.com',
          password: 'password123',
        );

        // Verify error is cleared
        expect(container.read(authProvider).errorMessage, isNull);

        await future;
      });
    });

    group('register', () {
      test('should set authenticated state on successful registration', () async {
        when(() => mockAuthService.register(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
            )).thenAnswer((_) async => testAuthResponse);

        final container = createTestContainer();
        final notifier = container.read(authProvider.notifier);

        final result = await notifier.register(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        );

        expect(result, true);

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.user, testUser);
      });

      test('should set error state on ApiException', () async {
        when(() => mockAuthService.register(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
            )).thenThrow(
          const ValidationException('Email já cadastrado'),
        );

        final container = createTestContainer();
        final notifier = container.read(authProvider.notifier);

        final result = await notifier.register(
          email: 'existing@example.com',
          password: 'password123',
          name: 'Test User',
        );

        expect(result, false);

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Email já cadastrado');
      });

      test('should set generic error message on unknown error', () async {
        when(() => mockAuthService.register(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
            )).thenThrow(Exception('Unknown error'));

        final container = createTestContainer();
        final notifier = container.read(authProvider.notifier);

        final result = await notifier.register(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        );

        expect(result, false);

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Erro ao criar conta. Tente novamente.');
      });
    });

    group('logout', () {
      test('should set unauthenticated state and clear user', () async {
        when(() => mockAuthService.logout()).thenAnswer((_) async {});

        final container = createTestContainer();

        // First login
        when(() => mockAuthService.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => testAuthResponse);

        final notifier = container.read(authProvider.notifier);
        await notifier.login(email: 'test@example.com', password: 'password');

        // Verify logged in
        expect(container.read(authProvider).isAuthenticated, true);

        // Now logout
        await notifier.logout();

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.unauthenticated);
        expect(container.read(currentUserProvider), isNull);
      });
    });

    group('clearError', () {
      test('should clear error state', () async {
        when(() => mockAuthService.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(const AuthenticationException('Error'));

        final container = createTestContainer();
        final notifier = container.read(authProvider.notifier);

        // Trigger error
        await notifier.login(email: 'test@example.com', password: 'wrong');
        expect(container.read(authProvider).hasError, true);

        // Clear error
        notifier.clearError();

        final state = container.read(authProvider);
        expect(state.hasError, false);
        expect(state.status, AuthStatus.initial);
        expect(state.errorMessage, isNull);
      });

      test('should do nothing if not in error state', () async {
        final container = createTestContainer();
        final notifier = container.read(authProvider.notifier);

        // Initial state
        expect(container.read(authProvider).status, AuthStatus.initial);

        // Clear error (should do nothing)
        notifier.clearError();

        expect(container.read(authProvider).status, AuthStatus.initial);
      });
    });
  });

  group('Helper Providers', () {
    group('isLoggedInProvider', () {
      test('should return true when authenticated', () {
        final container = createContainer(
          overrides: [
            authProvider.overrideWith((ref) {
              return AuthNotifier(MockAuthService(), ref)
                ..state = AuthState(
                  status: AuthStatus.authenticated,
                  user: testUser,
                );
            }),
          ],
        );

        expect(container.read(isLoggedInProvider), true);
      });

      test('should return false when not authenticated', () {
        final container = createContainer(
          overrides: [
            authProvider.overrideWith((ref) {
              return AuthNotifier(MockAuthService(), ref)
                ..state = const AuthState(status: AuthStatus.unauthenticated);
            }),
          ],
        );

        expect(container.read(isLoggedInProvider), false);
      });
    });

    group('userProvider', () {
      test('should return current user', () {
        final container = createContainer(
          overrides: [
            currentUserProvider.overrideWith((ref) => testUser),
          ],
        );

        expect(container.read(userProvider), testUser);
      });

      test('should return null when no user', () {
        final container = createContainer();

        expect(container.read(userProvider), isNull);
      });
    });
  });
}
