import 'package:shared_preferences/shared_preferences.dart';

/// Token storage service using SharedPreferences
/// Handles saving, retrieving, and clearing authentication tokens
class TokenStorage {
  static const String _accessTokenKey = 'myfit_access_token';
  static const String _refreshTokenKey = 'myfit_refresh_token';
  static const String _userIdKey = 'myfit_user_id';
  static const String _tokenExpiryKey = 'myfit_token_expiry';

  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance
  /// Call this early in app startup (e.g., in main())
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance (initializes if needed)
  static Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ==================== Access Token ====================

  /// Save access token
  static Future<void> saveAccessToken(String token) async {
    final prefs = await _preferences;
    await prefs.setString(_accessTokenKey, token);
  }

  /// Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await _preferences;
    return prefs.getString(_accessTokenKey);
  }

  /// Check if access token exists
  static Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== Refresh Token ====================

  /// Save refresh token
  static Future<void> saveRefreshToken(String token) async {
    final prefs = await _preferences;
    await prefs.setString(_refreshTokenKey, token);
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await _preferences;
    return prefs.getString(_refreshTokenKey);
  }

  /// Check if refresh token exists
  static Future<bool> hasRefreshToken() async {
    final token = await getRefreshToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== User ID ====================

  /// Save user ID
  static Future<void> saveUserId(String userId) async {
    final prefs = await _preferences;
    await prefs.setString(_userIdKey, userId);
  }

  /// Get user ID
  static Future<String?> getUserId() async {
    final prefs = await _preferences;
    return prefs.getString(_userIdKey);
  }

  // ==================== Token Expiry ====================

  /// Save token expiry timestamp
  static Future<void> saveTokenExpiry(DateTime expiry) async {
    final prefs = await _preferences;
    await prefs.setInt(_tokenExpiryKey, expiry.millisecondsSinceEpoch);
  }

  /// Get token expiry timestamp
  static Future<DateTime?> getTokenExpiry() async {
    final prefs = await _preferences;
    final timestamp = prefs.getInt(_tokenExpiryKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Check if token is expired
  static Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    // Consider expired if less than 1 minute remaining
    return DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 1)));
  }

  // ==================== Bulk Operations ====================

  /// Save all tokens at once
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userId,
    DateTime? expiry,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
      if (userId != null) saveUserId(userId),
      if (expiry != null) saveTokenExpiry(expiry),
    ]);
  }

  /// Clear all tokens (logout)
  static Future<void> clearTokens() async {
    final prefs = await _preferences;
    await Future.wait([
      prefs.remove(_accessTokenKey),
      prefs.remove(_refreshTokenKey),
      prefs.remove(_userIdKey),
      prefs.remove(_tokenExpiryKey),
    ]);
  }

  /// Check if user is authenticated (has valid tokens)
  static Future<bool> isAuthenticated() async {
    final hasAccess = await hasAccessToken();
    final hasRefresh = await hasRefreshToken();
    return hasAccess && hasRefresh;
  }

  /// Get all auth data as a map (useful for debugging)
  static Future<Map<String, dynamic>> getAuthData() async {
    final prefs = await _preferences;
    return {
      'accessToken': prefs.getString(_accessTokenKey),
      'refreshToken': prefs.getString(_refreshTokenKey),
      'userId': prefs.getString(_userIdKey),
      'tokenExpiry': prefs.getInt(_tokenExpiryKey),
    };
  }
}
