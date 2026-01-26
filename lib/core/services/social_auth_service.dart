import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Service for handling social authentication (Google, Apple)
class SocialAuthService {
  SocialAuthService._();

  static final SocialAuthService instance = SocialAuthService._();

  // iOS Client ID for Google Sign-In
  static const _googleClientIdIOS =
      '222322190794-17k4dgir29v5n12td5ne1bjtv8r1e98r.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // On iOS, we need to specify the clientId
    clientId: !kIsWeb && Platform.isIOS ? _googleClientIdIOS : null,
  );

  /// Sign in with Google and return the ID token
  Future<String?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      return auth.idToken;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return null;
    }
  }

  /// Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  /// Sign in with Apple and return the ID token and user name (if first login)
  Future<AppleSignInResult?> signInWithApple() async {
    try {
      // Generate nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) return null;

      // Get user name (only available on first sign in)
      String? userName;
      if (credential.givenName != null || credential.familyName != null) {
        userName = [credential.givenName, credential.familyName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
      }

      return AppleSignInResult(
        idToken: idToken,
        userName: userName?.isNotEmpty == true ? userName : null,
      );
    } catch (e) {
      debugPrint('Apple sign in error: $e');
      return null;
    }
  }

  /// Generate a random nonce for Apple Sign In
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// SHA256 hash of a string
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

/// Result from Apple Sign In
class AppleSignInResult {
  final String idToken;
  final String? userName;

  AppleSignInResult({
    required this.idToken,
    this.userName,
  });
}
