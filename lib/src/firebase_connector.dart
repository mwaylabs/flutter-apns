import 'package:flutter_apns/src/connector.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebasePushConnector extends PushConnector {
  final firebase = FirebaseMessaging();

  @override
  final isDisabledByUser = ValueNotifier(false);

  @override
  void configure({onMessage, onLaunch, onResume, onBackgroundMessage}) {
    firebase.configure(
      onMessage: onMessage,
      onLaunch: onLaunch,
      onResume: onResume,
      onBackgroundMessage: onBackgroundMessage,
    );

    firebase.onTokenRefresh.listen((value) {
      token.value = value;
    });
  }

  @override
  final token = ValueNotifier(null);

  @override
  void requestNotificationPermissions() {
    firebase.requestNotificationPermissions();
  }

  @override
  String get providerType => 'GCM';

  @override
  Future<void> unregister() async {
    await firebase.setAutoInitEnabled(false);
    await firebase.deleteInstanceID();

    token.value = null;
  }
}
