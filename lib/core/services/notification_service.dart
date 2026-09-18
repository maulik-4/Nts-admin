import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Top-level background message handler required by Firebase Messaging.
/// Must be annotated with `@pragma('vm:entry-point')` to prevent tree-shaking in release builds.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint(
    '[NOTIFICATION] Background message received: ${message.messageId} | ${message.notification?.title}',
  );
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  FirebaseMessaging? _messagingInstance;
  FirebaseMessaging get _messaging =>
      _messagingInstance ??= FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'vidhanta_notifications';
  static const String channelName = 'Vidhanta Notifications';
  static const String channelDescription =
      'Notifications for case updates, hearings, tasks, and system alerts.';

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

  bool _isInitialized = false;
  bool _firebaseAvailable = false;
  String? _cachedToken;
  void Function(Map<String, dynamic> data)? _onNotificationTapCallback;

  bool get isInitialized => _isInitialized;
  bool get isFirebaseAvailable => _firebaseAvailable;
  String? get cachedToken => _cachedToken;

  /// Initialize Firebase, FCM, and Local Notifications in a resilient, production-ready manner.
  Future<void> initialize({
    void Function(Map<String, dynamic> data)? onNotificationTap,
  }) async {
    if (_isInitialized) return;
    _onNotificationTapCallback = onNotificationTap;

    // 1. Initialize Firebase Core safely
    try {
      await Firebase.initializeApp();
      _firebaseAvailable = true;
      debugPrint('[NOTIFICATION] Firebase Core initialized successfully.');
    } catch (e) {
      debugPrint(
        '[NOTIFICATION] Firebase Core initialization omitted or unavailable: $e',
      );
      _firebaseAvailable = false;
    }

    // 2. Initialize Local Notifications Plugin
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open',
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            try {
              final decoded = jsonDecode(payload) as Map<String, dynamic>;
              _handleNotificationPayload(decoded);
            } catch (_) {
              _handleNotificationPayload({'payload': payload});
            }
          }
        },
      );

      // Create Android Notification Channel
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(_androidChannel);
      }
      debugPrint(
        '[NOTIFICATION] Flutter Local Notifications initialized successfully.',
      );
    } catch (e) {
      debugPrint('[NOTIFICATION] Local Notifications initialization error: $e');
    }

    // 3. Configure FCM if Firebase is active
    if (_firebaseAvailable) {
      try {
        await _setupFirebaseMessaging();
      } catch (e) {
        debugPrint('[NOTIFICATION] Firebase Messaging configuration error: $e');
      }
    }

    _isInitialized = true;
  }

  /// Sets up permissions, listeners, and token fetching for Firebase Cloud Messaging.
  Future<void> _setupFirebaseMessaging() async {
    // Request notification permissions (iOS and Android 13+)
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint(
        '[NOTIFICATION] FCM Permission status: ${settings.authorizationStatus}',
      );

      final androidImpl = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImpl != null) {
        await androidImpl.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('[NOTIFICATION] Permission request warning: $e');
    }

    // Set background messaging handler
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint('[NOTIFICATION] onBackgroundMessage registration error: $e');
    }

    // Handle foreground FCM notifications by showing high-priority local notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        '[NOTIFICATION] Foreground message: ${message.notification?.title} | ${message.notification?.body}',
      );
      showNotificationFromRemoteMessage(message);
    });

    // Handle user tapping on a notification from background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[NOTIFICATION] App opened via notification: ${message.data}');
      _handleNotificationPayload(message.data);
    });

    // Check if app was launched by tapping a notification from terminated state
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
          '[NOTIFICATION] Initial message opened: ${initialMessage.data}',
        );
        _handleNotificationPayload(initialMessage.data);
      }
    } catch (e) {
      debugPrint('[NOTIFICATION] getInitialMessage error: $e');
    }

    // Fetch and cache initial FCM token
    await getDeviceToken();

    // Listen for FCM token refresh events
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('[NOTIFICATION] FCM Token refreshed: $newToken');
      _cachedToken = newToken;
    });
  }

  /// Fetches the FCM device token, caching it for subsequent calls.
  Future<String?> getDeviceToken() async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      return _cachedToken;
    }
    if (!_firebaseAvailable) {
      return null;
    }
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        _cachedToken = token;
        debugPrint('[NOTIFICATION] Acquired FCM Device Token: $token');
      }
      return token;
    } catch (e) {
      debugPrint('[NOTIFICATION] Failed to retrieve FCM device token: $e');
      return null;
    }
  }

  /// Show a local heads-up notification from an incoming RemoteMessage.
  Future<void> showNotificationFromRemoteMessage(RemoteMessage message) async {
    final notification = message.notification;
    final title =
        notification?.title ?? message.data['title'] ?? 'New Notification';
    final body =
        notification?.body ??
        message.data['message'] ??
        message.data['body'] ??
        '';

    final id = message.messageId.hashCode;

    await showNotification(
      id: id,
      title: title,
      body: body,
      payload: message.data,
    );
  }

  /// Display a local notification with high importance and vibration.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _localNotifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload != null ? jsonEncode(payload) : null,
      );
    } catch (e) {
      debugPrint('[NOTIFICATION] Failed to present local notification: $e');
    }
  }

  /// Subscribe to a Firebase Cloud Messaging topic (e.g. firm announcements).
  Future<void> subscribeToTopic(String topic) async {
    if (!_firebaseAvailable) return;
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('[NOTIFICATION] Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('[NOTIFICATION] Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from a Firebase Cloud Messaging topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!_firebaseAvailable) return;
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('[NOTIFICATION] Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('[NOTIFICATION] Error unsubscribing from topic $topic: $e');
    }
  }

  void _handleNotificationPayload(Map<String, dynamic> data) {
    if (_onNotificationTapCallback != null) {
      _onNotificationTapCallback!(data);
    }
  }
}
