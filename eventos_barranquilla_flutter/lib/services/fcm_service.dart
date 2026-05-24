import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

class FcmService {
  Future<String?> obtenerFcmToken() async {
    return requestAndGetToken();
  }

  Stream<String> onTokenRefresh() {
    return FirebaseMessaging.instance.onTokenRefresh;
  }

  Future<String?> requestAndGetToken() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Debug message to confirm permissions were granted.
      // ignore: avoid_print
      print('Permiso concedido por el usuario');
      final token = await messaging.getToken();
      // ignore: avoid_print
      print('FCM Token del dispositivo: $token');
      return token;
    }

    // ignore: avoid_print
    print('El usuario rechazo o no configuro los permisos de notificacion');
    return null;
  }
}
