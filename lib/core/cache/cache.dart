/// Global cache infrastructure for MyFit app.
///
/// Provides:
/// - [CacheConfig] - TTL and behavior configuration per data type
/// - [CacheMetadata] - Tracks cache freshness and status
/// - [CacheEvent] - Event-based cache invalidation
/// - [CachedStateNotifier] - Base class for cached providers
/// - [CachedRefreshIndicator] - Pull-to-refresh widget
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
///   };
/// }
/// ```
library cache;

export 'cache_config.dart';
export 'cache_events.dart';
export 'cache_metadata.dart';
export 'cached_refresh_indicator.dart';
export 'cached_state_notifier.dart';
