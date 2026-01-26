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
    @JsonKey(name: 'birth_date') String? birthDate,
    String? gender,
    @JsonKey(name: 'height_cm') double? heightCm,
    String? bio,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'user_type') @Default('student') String userType,
    @JsonKey(name: 'auth_provider') @Default('email') String authProvider,
    String? cref,
    @JsonKey(name: 'cref_verified') @Default(false) bool crefVerified,
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
    @JsonKey(name: 'user_type') @Default('student') String userType,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}

/// Send verification code request
@freezed
sealed class SendVerificationCodeRequest with _$SendVerificationCodeRequest {
  const SendVerificationCodeRequest._();

  const factory SendVerificationCodeRequest({
    required String email,
  }) = _SendVerificationCodeRequest;

  factory SendVerificationCodeRequest.fromJson(Map<String, dynamic> json) =>
      _$SendVerificationCodeRequestFromJson(json);
}

/// Verify code request
@freezed
sealed class VerifyCodeRequest with _$VerifyCodeRequest {
  const VerifyCodeRequest._();

  const factory VerifyCodeRequest({
    required String email,
    required String code,
  }) = _VerifyCodeRequest;

  factory VerifyCodeRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyCodeRequestFromJson(json);
}

/// Verify code response
@freezed
sealed class VerifyCodeResponse with _$VerifyCodeResponse {
  const VerifyCodeResponse._();

  const factory VerifyCodeResponse({
    required bool verified,
    required String message,
  }) = _VerifyCodeResponse;

  factory VerifyCodeResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyCodeResponseFromJson(json);
}

/// Google login request
@freezed
sealed class GoogleLoginRequest with _$GoogleLoginRequest {
  const GoogleLoginRequest._();

  const factory GoogleLoginRequest({
    @JsonKey(name: 'id_token') required String idToken,
  }) = _GoogleLoginRequest;

  factory GoogleLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$GoogleLoginRequestFromJson(json);
}

/// Apple login request
@freezed
sealed class AppleLoginRequest with _$AppleLoginRequest {
  const AppleLoginRequest._();

  const factory AppleLoginRequest({
    @JsonKey(name: 'id_token') required String idToken,
    @JsonKey(name: 'user_name') String? userName,
  }) = _AppleLoginRequest;

  factory AppleLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$AppleLoginRequestFromJson(json);
}

/// Social auth response
@freezed
sealed class SocialAuthResponse with _$SocialAuthResponse {
  const SocialAuthResponse._();

  const factory SocialAuthResponse({
    required UserResponse user,
    required TokenResponse tokens,
    @JsonKey(name: 'is_new_user') required bool isNewUser,
  }) = _SocialAuthResponse;

  factory SocialAuthResponse.fromJson(Map<String, dynamic> json) =>
      _$SocialAuthResponseFromJson(json);
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
