import 'package:flutter_apns/src/connector.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebasePushConnector extends PushConnector {
  late final firebase = FirebaseMessaging.instance;

  @override
  final isDisabledByUser = ValueNotifier(false);

  bool didInitialize = false;

  @override
  void configure({
    MessageHandler? onMessage,
    MessageHandler? onLaunch,
    MessageHandler? onResume,
    MessageHandler? onBackgroundMessage,
  }) async {
    if (!didInitialize) {
      await Firebase.initializeApp();
      didInitialize = true;
    }

    firebase.onTokenRefresh.listen((value) {
      token.value = value;
    });

    FirebaseMessaging.onMessage.listen(onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(onResume);

    if (onBackgroundMessage != null) {
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    }

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      onLaunch?.call(initial);
    }

    token.value = await firebase.getToken();
  }

  @override
  final token = ValueNotifier(null);

  @override
  void requestNotificationPermissions() async {
    if (!didInitialize) {
      await Firebase.initializeApp();
      didInitialize = true;
    }

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
