import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';

class NotificationServices {
  final _firebaseMessaging = FirebaseMessaging.instance;
  String? deviceToken;
  final box = GetStorage();

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    deviceToken = await _firebaseMessaging.getToken();
    box.write(BoxConstants.deviceToken, deviceToken);
    print('Token:$deviceToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Notification Title: ${message.notification?.title}");
  print("Notification Body: ${message.notification?.body}");
  print("Notification Data: ${message.data}");
}
