import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/l10n/generated/app_localizations.dart';
import '../config/routes/app_router.dart';
import '../config/theme/app_theme.dart';
import '../core/providers/context_provider.dart';
import '../features/home/presentation/providers/student_home_provider.dart';
import '../features/trainer_workout/presentation/providers/trainer_students_provider.dart';
import '../features/workout/presentation/providers/workout_provider.dart';

/// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Locale provider
final localeProvider = StateProvider<Locale>((ref) => const Locale('pt', 'BR'));

/// Main App Widget
class MyFitApp extends ConsumerStatefulWidget {
  const MyFitApp({super.key});

  @override
  ConsumerState<MyFitApp> createState() => _MyFitAppState();
}

class _MyFitAppState extends ConsumerState<MyFitApp> with WidgetsBindingObserver {
  DateTime? _lastPausedAt;

  /// Minimum time in background before refreshing data (30 seconds)
  static const _refreshThreshold = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _lastPausedAt = DateTime.now();
        break;
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _onAppResumed() {
    // Only refresh if app was in background for more than threshold
    if (_lastPausedAt != null) {
      final timeSincePause = DateTime.now().difference(_lastPausedAt!);
      if (timeSincePause >= _refreshThreshold) {
        _refreshAllData();
      }
    }
    _lastPausedAt = null;
  }

  void _refreshAllData() {
    final activeContext = ref.read(activeContextProvider);
    if (activeContext == null) return;

    final orgId = activeContext.organization.id;

    // Refresh student data
    if (activeContext.isStudent) {
      ref.invalidate(studentDashboardProvider);
      ref.invalidate(studentPendingPlansProvider);
      ref.invalidate(plansNotifierProvider);
    }

    // Refresh trainer data
    if (activeContext.isTrainer) {
      ref.invalidate(trainerStudentsNotifierProvider(orgId));
      ref.invalidate(pendingInvitesNotifierProvider(orgId));
    }

    // Refresh common data
    ref.invalidate(membershipsProvider);
    ref.invalidate(pendingInvitesForUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'MyFit',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // Routing
      routerConfig: router,

      // Localization
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
