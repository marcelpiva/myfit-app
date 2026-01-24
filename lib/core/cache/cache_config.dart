/// Configuration for cache behavior per data type
class CacheConfig {
  /// Time-to-live before data is considered stale
  final Duration ttl;

  /// Whether to show stale data while refreshing
  final bool staleWhileRevalidate;

  /// Whether to automatically refresh when TTL expires
  final bool autoRefresh;

  /// Minimum time between refresh attempts (rate limiting)
  final Duration minRefreshInterval;

  const CacheConfig({
    this.ttl = const Duration(minutes: 5),
    this.staleWhileRevalidate = true,
    this.autoRefresh = false,
    this.minRefreshInterval = const Duration(seconds: 30),
  });

  /// Frequent updates - 1 minute TTL, auto-refresh enabled
  /// Use for: dashboards, active sessions, notifications
  static const frequent = CacheConfig(
    ttl: Duration(minutes: 1),
    staleWhileRevalidate: true,
    autoRefresh: true,
    minRefreshInterval: Duration(seconds: 15),
  );

  /// Standard refresh rate - 5 minutes TTL
  /// Use for: student lists, workouts, plans, schedule
  static const standard = CacheConfig(
    ttl: Duration(minutes: 5),
    staleWhileRevalidate: true,
    autoRefresh: false,
    minRefreshInterval: Duration(seconds: 30),
  );

  /// Long-lived data - 30 minutes TTL
  /// Use for: memberships, achievements, leaderboard
  static const longlived = CacheConfig(
    ttl: Duration(minutes: 30),
    staleWhileRevalidate: true,
    autoRefresh: false,
    minRefreshInterval: Duration(minutes: 1),
  );

  /// Nearly static data - 24 hours TTL
  /// Use for: exercise catalog, organization details
  static const static_ = CacheConfig(
    ttl: Duration(hours: 24),
    staleWhileRevalidate: true,
    autoRefresh: false,
    minRefreshInterval: Duration(minutes: 5),
  );
}

/// Suggested TTL configurations per provider type
class CacheConfigs {
  CacheConfigs._();

  // Frequently changing data (1 min)
  static const dashboard = CacheConfig.frequent;
  static const activeSessions = CacheConfig.frequent;
  static const notifications = CacheConfig.frequent;
  static const pendingInvites = CacheConfig.frequent;

  // Standard refresh rate (5 min)
  static const students = CacheConfig.standard;
  static const workouts = CacheConfig.standard;
  static const plans = CacheConfig.standard;
  static const schedule = CacheConfig.standard;
  static const conversations = CacheConfig.standard;

  // Slow-changing data (30 min)
  static const memberships = CacheConfig.longlived;
  static const achievements = CacheConfig.longlived;
  static const leaderboard = CacheConfig.longlived;
  static const gamificationStats = CacheConfig.longlived;

  // Nearly static data (24 hours)
  static const exercises = CacheConfig.static_;
  static const organizations = CacheConfig.static_;
}
