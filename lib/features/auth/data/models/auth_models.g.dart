// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TokenResponse _$TokenResponseFromJson(Map<String, dynamic> json) =>
    _TokenResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
    );

Map<String, dynamic> _$TokenResponseToJson(_TokenResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'token_type': instance.tokenType,
    };

_UserResponse _$UserResponseFromJson(Map<String, dynamic> json) =>
    _UserResponse(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      birthDate: json['birth_date'] as String?,
      gender: json['gender'] as String?,
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      bio: json['bio'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      userType: json['user_type'] as String? ?? 'student',
      authProvider: json['auth_provider'] as String? ?? 'email',
      cref: json['cref'] as String?,
      crefVerified: json['cref_verified'] as bool? ?? false,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
    );

Map<String, dynamic> _$UserResponseToJson(_UserResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'phone': instance.phone,
      'avatar_url': instance.avatarUrl,
      'birth_date': instance.birthDate,
      'gender': instance.gender,
      'height_cm': instance.heightCm,
      'bio': instance.bio,
      'is_active': instance.isActive,
      'is_verified': instance.isVerified,
      'user_type': instance.userType,
      'auth_provider': instance.authProvider,
      'cref': instance.cref,
      'cref_verified': instance.crefVerified,
      'onboarding_completed': instance.onboardingCompleted,
    };

_AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) =>
    _AuthResponse(
      user: UserResponse.fromJson(json['user'] as Map<String, dynamic>),
      tokens: TokenResponse.fromJson(json['tokens'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseToJson(_AuthResponse instance) =>
    <String, dynamic>{'user': instance.user, 'tokens': instance.tokens};

_LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    _LoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(_LoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

_RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    _RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      userType: json['user_type'] as String? ?? 'student',
    );

Map<String, dynamic> _$RegisterRequestToJson(_RegisterRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'name': instance.name,
      'user_type': instance.userType,
    };

_SendVerificationCodeRequest _$SendVerificationCodeRequestFromJson(
  Map<String, dynamic> json,
) => _SendVerificationCodeRequest(email: json['email'] as String);

Map<String, dynamic> _$SendVerificationCodeRequestToJson(
  _SendVerificationCodeRequest instance,
) => <String, dynamic>{'email': instance.email};

_VerifyCodeRequest _$VerifyCodeRequestFromJson(Map<String, dynamic> json) =>
    _VerifyCodeRequest(
      email: json['email'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$VerifyCodeRequestToJson(_VerifyCodeRequest instance) =>
    <String, dynamic>{'email': instance.email, 'code': instance.code};

_VerifyCodeResponse _$VerifyCodeResponseFromJson(Map<String, dynamic> json) =>
    _VerifyCodeResponse(
      verified: json['verified'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$VerifyCodeResponseToJson(_VerifyCodeResponse instance) =>
    <String, dynamic>{
      'verified': instance.verified,
      'message': instance.message,
    };

_GoogleLoginRequest _$GoogleLoginRequestFromJson(Map<String, dynamic> json) =>
    _GoogleLoginRequest(idToken: json['id_token'] as String);

Map<String, dynamic> _$GoogleLoginRequestToJson(_GoogleLoginRequest instance) =>
    <String, dynamic>{'id_token': instance.idToken};

_AppleLoginRequest _$AppleLoginRequestFromJson(Map<String, dynamic> json) =>
    _AppleLoginRequest(
      idToken: json['id_token'] as String,
      userName: json['user_name'] as String?,
    );

Map<String, dynamic> _$AppleLoginRequestToJson(_AppleLoginRequest instance) =>
    <String, dynamic>{
      'id_token': instance.idToken,
      'user_name': instance.userName,
    };

_SocialAuthResponse _$SocialAuthResponseFromJson(Map<String, dynamic> json) =>
    _SocialAuthResponse(
      user: UserResponse.fromJson(json['user'] as Map<String, dynamic>),
      tokens: TokenResponse.fromJson(json['tokens'] as Map<String, dynamic>),
      isNewUser: json['is_new_user'] as bool,
    );

Map<String, dynamic> _$SocialAuthResponseToJson(_SocialAuthResponse instance) =>
    <String, dynamic>{
      'user': instance.user,
      'tokens': instance.tokens,
      'is_new_user': instance.isNewUser,
    };

_RefreshRequest _$RefreshRequestFromJson(Map<String, dynamic> json) =>
    _RefreshRequest(refreshToken: json['refresh_token'] as String);

Map<String, dynamic> _$RefreshRequestToJson(_RefreshRequest instance) =>
    <String, dynamic>{'refresh_token': instance.refreshToken};
