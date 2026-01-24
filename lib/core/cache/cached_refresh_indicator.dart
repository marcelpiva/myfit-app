import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme/app_colors.dart';
import '../utils/haptic_utils.dart';
import 'cache_config.dart';
import 'cache_metadata.dart';
import 'cached_state_notifier.dart';

/// A RefreshIndicator that works with CachedStateNotifier.
///
/// Provides haptic feedback and proper integration with cached providers.
///
/// Example:
/// ```dart
/// CachedRefreshIndicator(
///   provider: studentDashboardProvider,
///   child: ListView(...),
/// )
/// ```
class CachedRefreshIndicator<N extends CachedStateNotifier<S>,
    S extends CachedState<dynamic>> extends ConsumerWidget {
  final StateNotifierProvider<N, S> provider;
  final Widget child;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;
  final double strokeWidth;

  const CachedRefreshIndicator({
    super.key,
    required this.provider,
    required this.child,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
    this.strokeWidth = 2.5,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        HapticUtils.mediumImpact();
        await ref.read(provider.notifier).refresh();
      },
      color: color ?? AppColors.primary,
      backgroundColor:
          backgroundColor ?? (isDark ? AppColors.cardDark : AppColors.card),
      displacement: displacement,
      strokeWidth: strokeWidth,
      child: child,
    );
  }
}

/// Shows a subtle banner when data is stale and being refreshed in background.
///
/// Use this to indicate to users that fresh data is being loaded while
/// they can still interact with cached data.
class StaleDataBanner extends StatelessWidget {
  final CacheMetadata cache;
  final CacheConfig config;
  final Widget child;
  final String? message;

  const StaleDataBanner({
    super.key,
    required this.cache,
    required this.config,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isStale = cache.isStale(config);
    final isRefreshing = cache.isRefreshing;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Show banner only when refreshing stale data in background
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: (isStale && isRefreshing) ? 28 : 0,
          child: (isStale && isRefreshing)
              ? Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  color: isDark
                      ? AppColors.warning.withAlpha(30)
                      : AppColors.warning.withAlpha(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        message ?? 'Atualizando...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Expanded(child: child),
      ],
    );
  }
}

/// Extension to simplify adding refresh capability to existing widgets.
extension CachedRefreshExtension on Widget {
  /// Wraps this widget with a CachedRefreshIndicator.
  Widget withCachedRefresh<N extends CachedStateNotifier<S>,
      S extends CachedState<dynamic>>(
    StateNotifierProvider<N, S> provider,
  ) {
    return CachedRefreshIndicator<N, S>(
      provider: provider,
      child: this,
    );
  }
}

/// A loading indicator that considers cache state.
///
/// Shows loading only when there's no cached data.
/// When refreshing with cached data, shows a subtle indicator instead.
class CachedLoadingIndicator extends StatelessWidget {
  final bool isLoading;
  final bool hasData;
  final bool isRefreshing;
  final Widget? loadingWidget;
  final Widget child;

  const CachedLoadingIndicator({
    super.key,
    required this.isLoading,
    required this.hasData,
    required this.isRefreshing,
    required this.child,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Show full loading only if loading without cached data
    if (isLoading && !hasData) {
      return loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    // Otherwise show content (with optional refresh indicator handled separately)
    return child;
  }
}
