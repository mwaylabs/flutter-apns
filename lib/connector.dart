import 'package:flutter/foundation.dart';

typedef Future<dynamic> MessageHandler(Map<String, dynamic> message);

abstract class PushConnector {
  ValueNotifier<bool> get isDisabledByUser;
  ValueNotifier<String> get token;
  String get providerType;

  /// Run this at app start to connect methods correctly.
  void configure({
    MessageHandler onMessage,
    MessageHandler onLaunch,
    MessageHandler onResume,
    MessageHandler onBackgroundMessage,
  });

  void requestNotificationPermissions();

  void dispose() {}
}
