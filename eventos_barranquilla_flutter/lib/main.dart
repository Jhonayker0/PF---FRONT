import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app.dart';
import 'providers/auth_provider.dart';
import 'services/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Allow the app to run even when Firebase config is not present.
  }

  final localNotificationService = LocalNotificationService();
  await localNotificationService.initialize();

  FirebaseMessaging.onMessage.listen((message) async {
    await localNotificationService.showFromMessage(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    // Handle notification taps if needed.
  });

  await FirebaseMessaging.instance.getInitialMessage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const EventosBarranquillaApp(),
    ),
  );
}
