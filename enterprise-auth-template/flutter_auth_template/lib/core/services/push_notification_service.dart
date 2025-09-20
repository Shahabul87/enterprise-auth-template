import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';
import 'deep_link_service.dart';

// Push Notification Service Provider
final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  return PushNotificationService(ref);
});

class PushNotificationService {
  final Ref _ref;
  late FirebaseMessaging _firebaseMessaging;
  late FlutterLocalNotificationsPlugin _localNotifications;

  // Stream controller for notification events
  final _notificationController =
      StreamController<NotificationData>.broadcast();
  Stream<NotificationData> get notificationStream =>
      _notificationController.stream;

  // Subscription for FCM token refresh
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;

  PushNotificationService(this._ref);

  /// Initialize push notification service
  Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      _firebaseMessaging = FirebaseMessaging.instance;

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permissions
      await _requestPermissions();

      // Configure FCM
      await _configureFCM();

      // Get initial FCM token
      await _getFCMToken();

      // Set up token refresh listener
      _setupTokenRefreshListener();

      // Handle initial notification if app was launched from notification
      await _handleInitialNotification();

      debugPrint('Push notification service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize push notifications: $e');
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    const securityChannel = AndroidNotificationChannel(
      'security_channel',
      'Security Alerts',
      description: 'Important security notifications',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    const generalChannel = AndroidNotificationChannel(
      'general_channel',
      'General Notifications',
      description: 'General app notifications',
      importance: Importance.defaultImportance,
      enableVibration: true,
      playSound: true,
    );

    const authChannel = AndroidNotificationChannel(
      'auth_channel',
      'Authentication',
      description: 'Authentication related notifications',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(securityChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(generalChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(authChannel);
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Request Firebase messaging permissions
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    debugPrint('FCM permission status: ${settings.authorizationStatus}');

    // Request system notification permissions
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      debugPrint('Android notification permission: $status');
    }
  }

  /// Configure Firebase Cloud Messaging
  Future<void> _configureFCM() async {
    // Set foreground notification presentation options for iOS
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  /// Get FCM token and store it
  Future<String?> _getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _storeFCMToken(token);
        debugPrint('FCM Token: $token');

        // TODO: Send token to your backend
        // await _sendTokenToBackend(token);
      }
      return token;
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }

  /// Store FCM token securely
  Future<void> _storeFCMToken(String token) async {
    try {
      final secureStorage = _ref.read(secureStorageServiceProvider);
      await secureStorage.store('fcm_token', token);
    } catch (e) {
      debugPrint('Failed to store FCM token: $e');
    }
  }

  /// Set up token refresh listener
  void _setupTokenRefreshListener() {
    _tokenRefreshSubscription = _firebaseMessaging.onTokenRefresh.listen((
      token,
    ) async {
      await _storeFCMToken(token);
      debugPrint('FCM Token refreshed: $token');

      // TODO: Send updated token to your backend
      // await _updateTokenOnBackend(token);
    });
  }

  /// Handle initial notification if app was launched from notification
  Future<void> _handleInitialNotification() async {
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App launched from notification: ${initialMessage.data}');
      _processNotificationData(initialMessage);
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.data}');

    // Show local notification for foreground messages
    _showLocalNotification(message);

    // Process notification data
    _processNotificationData(message);
  }

  /// Handle notification tap when app is in background
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.data}');
    _processNotificationData(message);
  }

  /// Handle local notification tap
  void _onLocalNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        final notificationData = NotificationData.fromMap(data);
        _navigateBasedOnNotification(notificationData);
      } catch (e) {
        debugPrint('Failed to parse notification payload: $e');
      }
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final notificationData = NotificationData.fromRemoteMessage(message);
    final channelId = _getChannelId(notificationData.type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: _getImportance(notificationData.type),
      priority: Priority.high,
      showWhen: true,
      icon: '@drawable/ic_notification',
      color: notificationData.type == NotificationType.security
          ? const Color(0xFFDC2626)
          : const Color(0xFF3B82F6),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(notificationData.toMap()),
    );
  }

  /// Process notification data and emit event
  void _processNotificationData(RemoteMessage message) {
    final notificationData = NotificationData.fromRemoteMessage(message);
    _notificationController.add(notificationData);

    // Navigate based on notification type
    _navigateBasedOnNotification(notificationData);
  }

  /// Navigate to appropriate screen based on notification
  void _navigateBasedOnNotification(NotificationData data) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    switch (data.type) {
      case NotificationType.security:
        context.push('/settings/security');
        break;
      case NotificationType.auth:
        if (data.action == 'login_required') {
          context.go('/login');
        } else if (data.action == '2fa_verify') {
          context.push('/auth/2fa-verify');
        }
        break;
      case NotificationType.general:
        if (data.screen != null) {
          context.push(data.screen!);
        }
        break;
      case NotificationType.message:
        context.push('/notifications');
        break;
    }
  }

  /// Get notification channel ID based on type
  String _getChannelId(NotificationType type) {
    switch (type) {
      case NotificationType.security:
        return 'security_channel';
      case NotificationType.auth:
        return 'auth_channel';
      case NotificationType.general:
      case NotificationType.message:
        return 'general_channel';
    }
  }

  /// Get channel name
  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'security_channel':
        return 'Security Alerts';
      case 'auth_channel':
        return 'Authentication';
      case 'general_channel':
        return 'General Notifications';
      default:
        return 'Notifications';
    }
  }

  /// Get channel description
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'security_channel':
        return 'Important security notifications';
      case 'auth_channel':
        return 'Authentication related notifications';
      case 'general_channel':
        return 'General app notifications';
      default:
        return 'App notifications';
    }
  }

  /// Get importance level based on notification type
  Importance _getImportance(NotificationType type) {
    switch (type) {
      case NotificationType.security:
      case NotificationType.auth:
        return Importance.high;
      case NotificationType.general:
      case NotificationType.message:
        return Importance.defaultImportance;
    }
  }

  /// Send local notification
  Future<void> sendLocalNotification({
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.general,
  }) async {
    final channelId = _getChannelId(type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: _getImportance(type),
      priority: Priority.high,
      showWhen: true,
      icon: '@drawable/ic_notification',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Failed to subscribe to topic $topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Failed to unsubscribe from topic $topic: $e');
    }
  }

  /// Get stored FCM token
  Future<String?> getStoredToken() async {
    try {
      final secureStorage = _ref.read(secureStorageServiceProvider);
      return await secureStorage.get('fcm_token');
    } catch (e) {
      debugPrint('Failed to get stored FCM token: $e');
      return null;
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Clear specific notification
  Future<void> clearNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Dispose resources
  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _foregroundSubscription?.cancel();
    _notificationController.close();
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');

  // You can process the message here if needed
  // For example, store it locally or update app state
}

/// Notification data model
class NotificationData {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String? action;
  final String? screen;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  NotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.action,
    this.screen,
    required this.data,
    required this.timestamp,
  });

  factory NotificationData.fromRemoteMessage(RemoteMessage message) {
    final data = message.data;

    return NotificationData(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? 'You have a new notification',
      type: _parseNotificationType(data['type'] ?? 'general'),
      action: data['action'],
      screen: data['screen'],
      data: data,
      timestamp: DateTime.now(),
    );
  }

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: _parseNotificationType(map['type'] ?? 'general'),
      action: map['action'],
      screen: map['screen'],
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'action': action,
      'screen': screen,
      'data': data,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'security':
        return NotificationType.security;
      case 'auth':
        return NotificationType.auth;
      case 'message':
        return NotificationType.message;
      default:
        return NotificationType.general;
    }
  }
}

enum NotificationType { security, auth, general, message }

/// Notification permission handler
class NotificationPermissionHandler {
  static Future<bool> checkPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status.isGranted;
    } else if (Platform.isIOS) {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }
    return false;
  }

  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }
    return false;
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}

/// Push notification manager widget
class PushNotificationManager extends ConsumerStatefulWidget {
  final Widget child;

  const PushNotificationManager({super.key, required this.child});

  @override
  ConsumerState<PushNotificationManager> createState() =>
      _PushNotificationManagerState();
}

class _PushNotificationManagerState
    extends ConsumerState<PushNotificationManager> {
  late StreamSubscription<NotificationData> _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _initializePushNotifications();
  }

  Future<void> _initializePushNotifications() async {
    final pushService = ref.read(pushNotificationServiceProvider);
    await pushService.initialize();

    // Listen to notification events
    _notificationSubscription = pushService.notificationStream.listen(
      _handleNotification,
    );
  }

  void _handleNotification(NotificationData notification) {
    // Handle notification events globally
    debugPrint('Received notification: ${notification.title}');

    // You can add global notification handling logic here
    // For example, update notification count in app bar
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
