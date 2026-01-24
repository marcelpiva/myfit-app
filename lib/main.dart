import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'app/app.dart';
import 'core/config/environment.dart';
import 'core/observability/observability.dart';
import 'core/storage/token_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  EnvironmentConfig.init();

  // Initialize token storage
  await TokenStorage.init();

  // Configure timeago locales
  timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());

  // Set preferred orientations (not supported on web)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  // Initialize observability (GlitchTip) and run the app
  await ObservabilityService.init(
    appRunner: () => runApp(
      ProviderScope(
        observers: [const ObservabilityProviderObserver()],
        child: const MyFitApp(),
      ),
    ),
  );
}
