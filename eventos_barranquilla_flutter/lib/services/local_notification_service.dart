import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'fcm_default_channel',
    'FCM Notifications',
    description: 'Notifications from Firebase Cloud Messaging',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> showFromMessage(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? 'Nueva notificacion';
    final body = notification?.body ?? '';

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  static const String _channelId = 'fcm_default_channel';
  static const String _channelName = 'FCM Notifications';
  static const String _channelDescription =
      'Notifications from Firebase Cloud Messaging';
}
