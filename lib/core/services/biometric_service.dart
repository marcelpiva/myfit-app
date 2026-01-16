import 'dart:convert';

import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for biometric authentication (Face ID / Touch ID)
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  static const _emailKey = 'biometric_email';
  static const _passwordKey = 'biometric_password';
  static const _enabledKey = 'biometric_enabled';

  /// Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Check if biometrics are enrolled on device
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Check if biometric auth is available (supported + enrolled)
  Future<bool> isBiometricAvailable() async {
    final supported = await isDeviceSupported();
    final canCheck = await canCheckBiometrics();
    return supported && canCheck;
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Check if biometric login is enabled in app
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({
    String reason = 'Autentique para continuar',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  /// Save credentials after successful login
  /// Note: Using base64 encoding for now. In production, use proper encryption.
  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    // Simple obfuscation (not truly secure - for demo purposes)
    // In production, use flutter_secure_storage or platform-specific keychain
    final encodedEmail = base64Encode(utf8.encode(email));
    final encodedPassword = base64Encode(utf8.encode(password));

    await prefs.setString(_emailKey, encodedEmail);
    await prefs.setString(_passwordKey, encodedPassword);
    await prefs.setBool(_enabledKey, true);
  }

  /// Get saved credentials
  Future<({String? email, String? password})> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    final encodedEmail = prefs.getString(_emailKey);
    final encodedPassword = prefs.getString(_passwordKey);

    if (encodedEmail == null || encodedPassword == null) {
      return (email: null, password: null);
    }

    try {
      final email = utf8.decode(base64Decode(encodedEmail));
      final password = utf8.decode(base64Decode(encodedPassword));
      return (email: email, password: password);
    } catch (e) {
      return (email: null, password: null);
    }
  }

  /// Clear credentials (disable biometric login)
  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
    await prefs.setBool(_enabledKey, false);
  }

  /// Get biometric type label for UI
  String getBiometricLabel(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Touch ID';
    } else if (types.contains(BiometricType.strong)) {
      return 'Biometria';
    }
    return 'Biometria';
  }
}
