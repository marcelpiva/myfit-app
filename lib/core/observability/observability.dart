/// Observability module for MyFit app.
///
/// Provides error tracking, performance monitoring, and user analytics
/// using GlitchTip (open-source, self-hosted, Sentry-compatible).
///
/// ## Setup
///
/// 1. Deploy GlitchTip (see docker-compose in the plan)
/// 2. Create a project in GlitchTip dashboard
/// 3. Get the DSN and set it as environment variable
///
/// ## Usage in main.dart
///
/// ```dart
/// import 'package:myfit_app/core/observability/observability.dart';
///
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   await ObservabilityService.init(
///     appRunner: () {
///       runApp(
///         ProviderScope(
///           observers: [const ObservabilityProviderObserver()],
///           child: const MyFitApp(),
///         ),
///       );
///     },
///   );
/// }
/// ```
///
/// ## User Context
///
/// After login:
/// ```dart
/// await ObservabilityService.setUserContext(
///   userId: user.id,
///   email: user.email,
///   role: 'student',
///   organizationId: org.id,
/// );
/// ```
///
/// On logout:
/// ```dart
/// await ObservabilityService.clearUserContext();
/// ```
///
/// ## Navigation
///
/// In your GoRouter configuration:
/// ```dart
/// GoRouter(
///   observers: [ObservabilityGoRouterObserver()],
///   // ...
/// )
/// ```
library;

export 'navigation_observer.dart';
export 'observability_config.dart';
export 'observability_service.dart';
export 'riverpod_observer.dart';
