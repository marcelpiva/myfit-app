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

    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request permission
      await _requestPermission();

      // Initialize local notifications
      await _initLocalNotifications();

      // Get FCM token
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
      debugPrint('PushNotificationService initialized');

      // Log to GlitchTip
      ObservabilityService.captureMessage(
        'Push notifications initialized',
        severity: EventSeverity.info,
        extras: {'platform': Platform.isIOS ? 'iOS' : 'Android'},
      );
    } catch (e) {
      debugPrint('PushNotificationService init error: $e');
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

    debugPrint('Notification permission: ${settings.authorizationStatus}');
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
      debugPrint('FCM Token: $_fcmToken');

      if (_fcmToken != null) {
        await _sendTokenToBackend(_fcmToken!);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  /// Handle token refresh
  void _onTokenRefresh(String token) {
    debugPrint('FCM Token refreshed: $token');
    _fcmToken = token;
    _sendTokenToBackend(token);
  }

  /// Send FCM token to backend
  Future<void> _sendTokenToBackend(String token) async {
    try {
      final client = ApiClient.instance;
      await client.post(
        ApiEndpoints.registerDevice,
        data: {
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
        },
      );
      debugPrint('FCM token sent to backend');

      // Log success to GlitchTip
      ObservabilityService.captureMessage(
        'FCM token registered',
        severity: EventSeverity.info,
        extras: {
          'platform': Platform.isIOS ? 'iOS' : 'Android',
          'token_prefix': token.substring(0, 20),
        },
      );
    } catch (e) {
      debugPrint('Error sending FCM token to backend: $e');
      ObservabilityService.captureException(
        e,
        message: 'Failed to register FCM token',
      );
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
