import 'package:flutter_apns/src/connector.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebasePushConnector extends PushConnector {
  final _firebase = FirebaseMessaging();

  @override
  final isDisabledByUser = ValueNotifier(false);

  @override
  void configure({onMessage, onLaunch, onResume, onBackgroundMessage}) {
    _firebase.configure(
      onMessage: onMessage,
      onLaunch: onLaunch,
      onResume: onResume,
      onBackgroundMessage: onBackgroundMessage,
    );

    _firebase.onTokenRefresh.listen((value) {
      token.value = value;
    });
  }

  @override
  final token = ValueNotifier(null);

  @override
  void requestNotificationPermissions() {
    _firebase.requestNotificationPermissions();
  }

  @override
  String get providerType => 'GCM';
}
