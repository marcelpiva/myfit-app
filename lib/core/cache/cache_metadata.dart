import 'cache_config.dart';

/// Tracks cache freshness and status
class CacheMetadata {
  /// When data was last fetched (attempt)
  final DateTime? lastFetchedAt;

  /// When data was last successfully loaded
  final DateTime? lastSuccessAt;

  /// Whether a background refresh is in progress
  final bool isRefreshing;

  /// Number of consecutive fetch failures
  final int failureCount;

  const CacheMetadata({
    this.lastFetchedAt,
    this.lastSuccessAt,
    this.isRefreshing = false,
    this.failureCount = 0,
  });

  /// Check if cache is stale based on config
  bool isStale(CacheConfig config) {
    if (lastSuccessAt == null) return true;
    return DateTime.now().difference(lastSuccessAt!) > config.ttl;
  }

  /// Check if we can attempt a refresh (rate limiting)
  bool canRefresh(CacheConfig config) {
    if (lastFetchedAt == null) return true;
    return DateTime.now().difference(lastFetchedAt!) > config.minRefreshInterval;
  }

  /// Check if data has never been successfully loaded
  bool get isEmpty => lastSuccessAt == null;

  /// Check if data was loaded recently (within last minute)
  bool get isFresh {
    if (lastSuccessAt == null) return false;
    return DateTime.now().difference(lastSuccessAt!) < const Duration(minutes: 1);
  }

  /// Time since last successful fetch
  Duration? get timeSinceLastSuccess {
    if (lastSuccessAt == null) return null;
    return DateTime.now().difference(lastSuccessAt!);
  }

  CacheMetadata copyWith({
    DateTime? lastFetchedAt,
    DateTime? lastSuccessAt,
    bool? isRefreshing,
    int? failureCount,
  }) {
    return CacheMetadata(
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failureCount: failureCount ?? this.failureCount,
    );
  }

  @override
  String toString() {
    return 'CacheMetadata(lastSuccess: $lastSuccessAt, isRefreshing: $isRefreshing, failures: $failureCount)';
  }
}

/// Base interface for cached state
abstract class CachedState<T> {
  T? get data;
  bool get isLoading;
  String? get error;
  CacheMetadata get cache;

  /// Whether we have valid data (even if stale)
  bool get hasData => data != null;

  /// Whether data is stale and should be refreshed
  bool isStale(CacheConfig config) => cache.isStale(config);

  /// Whether we're doing a background refresh (stale-while-revalidate)
  bool get isBackgroundRefresh => cache.isRefreshing && hasData;
}
