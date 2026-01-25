import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../observability/observability_service.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background message: ${message.messageId}');
}

/// Service for handling push notifications
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  bool _initialized = false;

  /// Get the current FCM token
  String? get fcmToken => _fcmToken;

  /// Initialize Firebase and push notifications
  Future<void> init() async {
    if (_initialized) return;

    debugPrint('🔔 [PUSH] Iniciando PushNotificationService...');

    try {
      // Initialize Firebase if not already initialized
      if (Firebase.apps.isEmpty) {
        debugPrint('🔔 [PUSH] Inicializando Firebase...');
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint('🔔 [PUSH] Firebase inicializado com sucesso');
      } else {
        debugPrint('🔔 [PUSH] Firebase já estava inicializado');
      }

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request permission
      debugPrint('🔔 [PUSH] Solicitando permissão de notificação...');
      await _requestPermission();

      // Initialize local notifications
      debugPrint('🔔 [PUSH] Inicializando notificações locais...');
      await _initLocalNotifications();

      // Get FCM token
      debugPrint('🔔 [PUSH] Obtendo FCM token...');
      await _getToken();

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_onTokenRefresh);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check for initial message (app opened from terminated state)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _initialized = true;
      debugPrint('🔔 [PUSH] ✅ PushNotificationService inicializado com sucesso!');

      // Log to GlitchTip
      ObservabilityService.captureMessage(
        'Push notifications initialized',
        severity: EventSeverity.info,
        extras: {'platform': Platform.isIOS ? 'iOS' : 'Android'},
      );
    } catch (e, stackTrace) {
      debugPrint('🔔 [PUSH] ❌ Erro ao inicializar: $e');
      debugPrint('🔔 [PUSH] StackTrace: $stackTrace');
      ObservabilityService.captureException(e, message: 'Failed to init push notifications');
    }
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('🔔 [PUSH] Permissão de notificação: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('🔔 [PUSH] ✅ Permissão concedida');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('🔔 [PUSH] ❌ Permissão NEGADA - Usuário precisa habilitar nas configurações');
    } else {
      debugPrint('🔔 [PUSH] ⚠️ Permissão: ${settings.authorizationStatus}');
    }
  }

  /// Initialize local notifications for foreground display
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'myfit_notifications',
        'MyFit Notifications',
        description: 'Notificações do MyFit',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Get FCM token and send to backend
  Future<void> _getToken() async {
    try {
      _fcmToken = await _messaging.getToken();

      if (_fcmToken != null) {
        debugPrint('🔔 [PUSH] ✅ FCM Token obtido: ${_fcmToken!.substring(0, 30)}...');
        await _sendTokenToBackend(_fcmToken!);
      } else {
        debugPrint('🔔 [PUSH] ❌ FCM Token é NULL - Verifique configuração do Firebase');
      }
    } catch (e, stackTrace) {
      debugPrint('🔔 [PUSH] ❌ Erro ao obter FCM token: $e');
      debugPrint('🔔 [PUSH] StackTrace: $stackTrace');
    }
  }

  /// Handle token refresh
  void _onTokenRefresh(String token) {
    debugPrint('FCM Token refreshed: $token');
    _fcmToken = token;
    _sendTokenToBackend(token);
  }

  /// Send FCM token to backend with retry logic
  Future<void> _sendTokenToBackend(String token, {int retryCount = 0}) async {
    debugPrint('🔔 [PUSH] Enviando FCM token para backend... (tentativa ${retryCount + 1})');
    debugPrint('🔔 [PUSH] Endpoint: ${ApiEndpoints.registerDevice}');
    debugPrint('🔔 [PUSH] Platform: ${Platform.isIOS ? 'ios' : 'android'}');
    debugPrint('🔔 [PUSH] Token length: ${token.length}');

    try {
      final client = ApiClient.instance;
      final response = await client.post(
        ApiEndpoints.registerDevice,
        data: {
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('🔔 [PUSH] ✅ FCM token enviado para backend com sucesso!');
        debugPrint('🔔 [PUSH] Response status: ${response.statusCode}');

        // Log success to GlitchTip
        ObservabilityService.captureMessage(
          'FCM token registered',
          severity: EventSeverity.info,
          extras: {
            'platform': Platform.isIOS ? 'iOS' : 'Android',
            'token_prefix': token.substring(0, 20),
          },
        );
      } else {
        debugPrint('🔔 [PUSH] ⚠️ Resposta inesperada: ${response.statusCode}');
        debugPrint('🔔 [PUSH] Response data: ${response.data}');
        // Retry on unexpected status
        if (retryCount < 3) {
          await Future.delayed(Duration(seconds: 2 * (retryCount + 1)));
          await _sendTokenToBackend(token, retryCount: retryCount + 1);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('🔔 [PUSH] ❌ Erro ao enviar FCM token para backend: $e');
      debugPrint('🔔 [PUSH] StackTrace: $stackTrace');

      // Retry up to 3 times with exponential backoff
      if (retryCount < 3) {
        final delay = Duration(seconds: 2 * (retryCount + 1));
        debugPrint('🔔 [PUSH] Tentando novamente em ${delay.inSeconds}s...');
        await Future.delayed(delay);
        await _sendTokenToBackend(token, retryCount: retryCount + 1);
      } else {
        debugPrint('🔔 [PUSH] ❌ Falha após ${retryCount + 1} tentativas');
        ObservabilityService.captureException(
          e,
          message: 'Failed to register FCM token after retries',
        );
      }
    }
  }

  /// Force re-registration of FCM token (call after login)
  Future<void> registerToken() async {
    debugPrint('🔔 [PUSH] registerToken() chamado');

    if (_fcmToken != null) {
      debugPrint('🔔 [PUSH] Re-registrando token existente...');
      await _sendTokenToBackend(_fcmToken!);
    } else {
      debugPrint('🔔 [PUSH] Token não disponível, obtendo novo token...');
      await _getToken();
    }
  }

  /// Handle foreground messages - show local notification
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.messageId}');

    // Log to GlitchTip
    ObservabilityService.addBreadcrumb(
      category: 'push_notification',
      message: 'Received foreground notification',
      data: {
        'title': message.notification?.title,
        'type': message.data['type'],
      },
    );

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'myfit_notifications',
            'MyFit Notifications',
            channelDescription: 'Notificações do MyFit',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Handle notification tap from local notifications
  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _navigateBasedOnData(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Handle notification tap from FCM
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    _navigateBasedOnData(message.data);
  }

  /// Navigate based on notification data
  void _navigateBasedOnData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    debugPrint('Navigate: type=$type, id=$id');

    // TODO: Implement navigation based on notification type
    // This will be handled by the app's navigation system
    // For example:
    // - type: 'feedback' -> navigate to trainer feedbacks page
    // - type: 'plan' -> navigate to plan detail
    // - type: 'chat' -> navigate to chat conversation
  }

  /// Subscribe to a topic (e.g., user-specific notifications)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }
}
