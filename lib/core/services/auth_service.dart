import 'package:dio/dio.dart';

import '../error/api_exceptions.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../storage/token_storage.dart';
import '../../features/auth/data/models/auth_models.dart';

/// Authentication service
/// Handles all auth-related API calls
class AuthService {
  final ApiClient _client;

  AuthService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  /// Login with email and password
  /// Returns AuthResponse with user data and tokens
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.authLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data);

        // Save tokens
        await TokenStorage.saveTokens(
          accessToken: authResponse.tokens.accessToken,
          refreshToken: authResponse.tokens.refreshToken,
          userId: authResponse.user.id,
        );

        return authResponse;
      }

      throw const ServerException('Erro ao fazer login');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao fazer login', e);
    }
  }

  /// Register a new user
  /// Returns AuthResponse with user data and tokens
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    String userType = 'student',
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.authRegister,
        data: {
          'email': email,
          'password': password,
          'name': name,
          'user_type': userType,
        },
      );

      if (response.statusCode == 201 && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data);

        // Save tokens
        await TokenStorage.saveTokens(
          accessToken: authResponse.tokens.accessToken,
          refreshToken: authResponse.tokens.refreshToken,
          userId: authResponse.user.id,
        );

        return authResponse;
      }

      throw const ServerException('Erro ao criar conta');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao criar conta', e);
    }
  }

  /// Send email verification code
  Future<bool> sendVerificationCode({required String email}) async {
    try {
      final response = await _client.post(
        ApiEndpoints.authSendVerification,
        data: {'email': email},
      );
      return response.statusCode == 200;
    } on DioException {
      return false;
    }
  }

  /// Verify email with code
  Future<bool> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.authVerifyCode,
        data: {'email': email, 'code': code},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data['verified'] == true;
      }
      return false;
    } on DioException {
      return false;
    }
  }

  /// Login with Google
  Future<AuthResponse> loginWithGoogle({required String idToken}) async {
    try {
      final response = await _client.post(
        ApiEndpoints.authGoogle,
        data: {'id_token': idToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data);

        await TokenStorage.saveTokens(
          accessToken: authResponse.tokens.accessToken,
          refreshToken: authResponse.tokens.refreshToken,
          userId: authResponse.user.id,
        );

        return authResponse;
      }

      throw const ServerException('Erro ao fazer login com Google');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao fazer login com Google', e);
    }
  }

  /// Login with Apple
  Future<AuthResponse> loginWithApple({
    required String idToken,
    String? userName,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.authApple,
        data: {
          'id_token': idToken,
          if (userName != null) 'user_name': userName,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data);

        await TokenStorage.saveTokens(
          accessToken: authResponse.tokens.accessToken,
          refreshToken: authResponse.tokens.refreshToken,
          userId: authResponse.user.id,
        );

        return authResponse;
      }

      throw const ServerException('Erro ao fazer login com Apple');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao fazer login com Apple', e);
    }
  }

  /// Refresh access token using refresh token
  /// Returns new TokenResponse
  Future<TokenResponse> refreshToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) {
      throw const AuthenticationException('Refresh token não encontrado');
    }

    try {
      final response = await _client.post(
        ApiEndpoints.authRefresh,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final tokenResponse = TokenResponse.fromJson(response.data);

        // Save new tokens
        await TokenStorage.saveTokens(
          accessToken: tokenResponse.accessToken,
          refreshToken: tokenResponse.refreshToken,
        );

        return tokenResponse;
      }

      throw const AuthenticationException('Erro ao renovar sessão');
    } on DioException catch (e) {
      // Clear tokens on refresh failure
      await TokenStorage.clearTokens();
      throw e.error is ApiException
          ? e.error as ApiException
          : const AuthenticationException('Sessão expirada');
    }
  }

  /// Logout user
  /// Clears local tokens and invalidates on server
  Future<void> logout() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      await _client.post(
        ApiEndpoints.authLogout,
        data: {'refresh_token': refreshToken},
      );
    } catch (_) {
      // Ignore logout errors - we'll clear tokens anyway
    } finally {
      await TokenStorage.clearTokens();
    }
  }

  /// Get current authenticated user
  /// Returns UserResponse or null if not authenticated
  Future<UserResponse?> getCurrentUser() async {
    final hasToken = await TokenStorage.hasAccessToken();
    if (!hasToken) return null;

    try {
      final response = await _client.get(ApiEndpoints.authMe);

      if (response.statusCode == 200 && response.data != null) {
        return UserResponse.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      if (e.error is AuthenticationException) {
        await TokenStorage.clearTokens();
      }
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return TokenStorage.isAuthenticated();
  }
}
