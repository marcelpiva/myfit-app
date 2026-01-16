import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

/// Token response from login/register/refresh
@freezed
sealed class TokenResponse with _$TokenResponse {
  const TokenResponse._();

  const factory TokenResponse({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'token_type') @Default('bearer') String tokenType,
  }) = _TokenResponse;

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);
}

/// User data from auth response
@freezed
sealed class UserResponse with _$UserResponse {
  const UserResponse._();

  const factory UserResponse({
    required String id,
    required String email,
    required String name,
    String? phone,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
  }) = _UserResponse;

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);
}

/// Full auth response with user and tokens
@freezed
sealed class AuthResponse with _$AuthResponse {
  const AuthResponse._();

  const factory AuthResponse({
    required UserResponse user,
    required TokenResponse tokens,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

/// Login request data
@freezed
sealed class LoginRequest with _$LoginRequest {
  const LoginRequest._();

  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

/// Register request data
@freezed
sealed class RegisterRequest with _$RegisterRequest {
  const RegisterRequest._();

  const factory RegisterRequest({
    required String email,
    required String password,
    required String name,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}

/// Refresh token request data
@freezed
sealed class RefreshRequest with _$RefreshRequest {
  const RefreshRequest._();

  const factory RefreshRequest({
    @JsonKey(name: 'refresh_token') required String refreshToken,
  }) = _RefreshRequest;

  factory RefreshRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshRequestFromJson(json);
}
