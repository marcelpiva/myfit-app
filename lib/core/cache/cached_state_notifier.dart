import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cache_config.dart';
import 'cache_events.dart';
import 'cache_metadata.dart';

/// Abstract base class for cached state notifiers.
///
/// Provides automatic:
/// - Stale-while-revalidate behavior
/// - TTL-based cache expiration
/// - Rate limiting on refresh
/// - Event-based invalidation
/// - Auto-refresh (optional)
///
/// Example usage:
/// ```dart
/// class MyNotifier extends CachedStateNotifier<MyState> {
///   MyNotifier({required Ref ref}) : super(
///     const MyState(),
///     config: CacheConfigs.standard,
///     ref: ref,
///   );
///
///   @override
///   Future<void> fetchData() async {
///     final data = await api.getData();
///     onFetchSuccess(data);
///   }
///
///   @override
///   Set<CacheEventType> get invalidationEvents => {
///     CacheEventType.dataUpdated,
///     CacheEventType.appResumed,
///   };
/// }
/// ```
abstract class CachedStateNotifier<S extends CachedState<dynamic>>
    extends StateNotifier<S> {
  /// Cache configuration for this notifier
  final CacheConfig config;

  /// Riverpod ref for listening to events
  final Ref ref;

  Timer? _autoRefreshTimer;
  ProviderSubscription<CacheEvent?>? _eventSubscription;

  CachedStateNotifier(
    super.state, {
    required this.config,
    required this.ref,
  }) {
    _setupAutoRefresh();
    _subscribeToEvents();
    // Initial load
    loadData();
  }

  /// Subclasses implement this to fetch data from API.
  /// Should call [onFetchSuccess] with the fetched data on success.
  /// Exceptions are caught by [loadData].
  Future<void> fetchData();

  /// Subclasses implement this to update state with new data.
  S updateStateWithData(dynamic data, CacheMetadata newCache);

  /// Subclasses implement this to update state for loading.
  S updateStateForLoading(bool isLoading, CacheMetadata cache);

  /// Subclasses implement this to update state for error.
  S updateStateForError(String error, CacheMetadata cache);

  /// Set of event types this notifier should listen to for invalidation.
  /// Override to subscribe to specific events.
  Set<CacheEventType> get invalidationEvents => {};

  /// Load data with stale-while-revalidate support.
  ///
  /// If [forceRefresh] is true, ignores rate limiting and TTL.
  Future<void> loadData({bool forceRefresh = false}) async {
    final currentCache = state.cache;

    // Skip if already refreshing
    if (currentCache.isRefreshing) {
      debugPrint('${runtimeType}: Already refreshing, skipping');
      return;
    }

    // Check if refresh is needed
    final isStale = currentCache.isStale(config);
    final canRefresh = currentCache.canRefresh(config);

    if (!forceRefresh && !isStale && state.hasData) {
      debugPrint('${runtimeType}: Cache is fresh, skipping fetch');
      return;
    }

    if (!canRefresh && !forceRefresh) {
      debugPrint('${runtimeType}: Rate limited, skipping fetch');
      return;
    }

    // Determine if this is initial load or background refresh
    final isBackgroundRefresh = state.hasData && config.staleWhileRevalidate;

    // Update cache metadata
    final updatedCache = currentCache.copyWith(
      isRefreshing: true,
      lastFetchedAt: DateTime.now(),
    );

    // Only show loading indicator if no data yet
    if (!isBackgroundRefresh) {
      state = updateStateForLoading(true, updatedCache);
    } else {
      // Keep existing data, just mark as refreshing
      state = updateStateForLoading(false, updatedCache);
      debugPrint('${runtimeType}: Background refresh started');
    }

    try {
      await fetchData();
      // fetchData should call onFetchSuccess
    } catch (e) {
      _onFetchError(e.toString());
    }
  }

  /// Called by subclasses when fetch succeeds.
  /// Updates state with new data and resets cache metadata.
  @protected
  void onFetchSuccess(dynamic data) {
    final newCache = state.cache.copyWith(
      isRefreshing: false,
      lastSuccessAt: DateTime.now(),
      failureCount: 0,
    );
    state = updateStateWithData(data, newCache);
    debugPrint('${runtimeType}: Fetch success, cache updated');
  }

  /// Called when fetch fails.
  void _onFetchError(String error) {
    final newCache = state.cache.copyWith(
      isRefreshing: false,
      failureCount: state.cache.failureCount + 1,
    );

    // Only show error if we have no cached data
    if (!state.hasData) {
      state = updateStateForError(error, newCache);
      debugPrint('${runtimeType}: Fetch failed with no cached data: $error');
    } else {
      // Keep existing data, just update cache metadata
      state = updateStateForLoading(false, newCache);
      debugPrint('${runtimeType}: Background refresh failed, keeping stale data');
    }
  }

  /// Manual refresh (for pull-to-refresh).
  /// Ignores rate limiting.
  Future<void> refresh() => loadData(forceRefresh: true);

  /// Force invalidate and reload.
  /// Clears cache metadata and forces a fresh load.
  void invalidate() {
    debugPrint('${runtimeType}: Invalidating cache');
    state = updateStateForLoading(true, const CacheMetadata());
    loadData(forceRefresh: true);
  }

  void _setupAutoRefresh() {
    if (!config.autoRefresh) return;

    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(config.ttl, (_) {
      if (mounted) {
        debugPrint('${runtimeType}: Auto-refresh triggered');
        loadData();
      }
    });
  }

  void _subscribeToEvents() {
    if (invalidationEvents.isEmpty) return;

    _eventSubscription = ref.listen<CacheEvent?>(
      cacheEventProvider,
      (previous, next) {
        if (next != null && invalidationEvents.contains(next.type)) {
          debugPrint('${runtimeType}: Invalidating due to event ${next.type}');
          invalidate();
        }
      },
    );
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _eventSubscription?.close();
    super.dispose();
  }
}

/// Mixin to add cache support to existing StateNotifier without full migration.
/// Useful for gradual migration of existing providers.
mixin CacheMixin<S> on StateNotifier<S> {
  CacheMetadata _cacheMetadata = const CacheMetadata();

  CacheMetadata get cacheMetadata => _cacheMetadata;

  void updateCacheOnFetchStart() {
    _cacheMetadata = _cacheMetadata.copyWith(
      isRefreshing: true,
      lastFetchedAt: DateTime.now(),
    );
  }

  void updateCacheOnFetchSuccess() {
    _cacheMetadata = _cacheMetadata.copyWith(
      isRefreshing: false,
      lastSuccessAt: DateTime.now(),
      failureCount: 0,
    );
  }

  void updateCacheOnFetchError() {
    _cacheMetadata = _cacheMetadata.copyWith(
      isRefreshing: false,
      failureCount: _cacheMetadata.failureCount + 1,
    );
  }

  bool shouldRefresh(CacheConfig config, {bool forceRefresh = false}) {
    if (forceRefresh) return true;
    if (_cacheMetadata.isRefreshing) return false;
    if (!_cacheMetadata.canRefresh(config)) return false;
    return _cacheMetadata.isStale(config);
  }
}
