import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zipbuzz/utils/constants/database_constants.dart';

class NotificationServices {
  final _firebaseMessaging = FirebaseMessaging.instance;
  String? deviceToken;
  final box = GetStorage();

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'Event Chat Notifications',
    importance: Importance.defaultImportance,
    playSound: true,
    enableVibration: true,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    deviceToken = await _firebaseMessaging.getToken();
    box.write(BoxConstants.deviceToken, deviceToken);
    print('Token:$deviceToken');
    initPushNotifications();
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    // navigation
  }

  Future initLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawalble/ic_launcher_foreground');
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _localNotifications.initialize(
      settings,
      // onDidReceiveNotificationResponse: 
      // onDidReceiveBackgroundNotificationResponse:  
    );
  }

  Future initPushNotifications() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // once the app is opened from terminated state
    _firebaseMessaging.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: _androidChannel.importance,
            playSound: _androidChannel.playSound,
            enableVibration: _androidChannel.enableVibration,
            icon: '@drawalble/ic_launcher_foreground',
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Notification Title: ${message.notification?.title}");
  print("Notification Body: ${message.notification?.body}");
  print("Notification Data: ${message.data}");
}
