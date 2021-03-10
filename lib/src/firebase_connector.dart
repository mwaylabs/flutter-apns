import 'package:flutter_apns/src/connector.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebasePushConnector extends PushConnector {
  final firebase = FirebaseMessaging.instance;

  @override
  final isDisabledByUser = ValueNotifier(false);

  @override
  void configure({onMessage, onLaunch, onResume, onBackgroundMessage}) {
    FirebaseMessaging.onMessage.listen((event) => onMessage(event?.data));
    FirebaseMessaging.onBackgroundMessage((event) => onBackgroundMessage(event?.data));

    firebase.onTokenRefresh.listen((value) {
      token.value = value;
    });
  }

  @override
  final token = ValueNotifier(null);

  @override
  void requestNotificationPermissions() {
    firebase.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  @override
  String get providerType => 'GCM';

  @override
  Future<void> unregister() async {
    await firebase.setAutoInitEnabled(false);
    await firebase.deleteToken();

    token.value = null;
  }
}
