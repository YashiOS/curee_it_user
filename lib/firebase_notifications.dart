import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    // Request permission for iOS (and Android 13+)
    NotificationSettings settings = await _fcm.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      // Get device token
      String? token = await _fcm.getToken(); 
      print("FCM Token: $token");

      // Foreground message handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received a message in the foreground!');
        print('Message data: ${message.data}');
        if (message.notification != null) {
          print('Notification title: ${message.notification!.title}');
        }
      });

      // Background & Terminated handlers
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('User tapped notification: ${message.notification?.title}'); 
      });

    } else {
      print('Permission declined');
    }
  }
}
