import 'package:flutter/foundation.dart';

typedef MessageHandler = Future<void> Function(Map<String, dynamic>);

abstract class PushConnector {
  ValueNotifier<bool> get isDisabledByUser;
  ValueNotifier<String> get token;
  String get providerType;

  /// Run this at app start to connect methods correctly.
  void configure(
      {MessageHandler onMessage,
      MessageHandler onLaunch,
      MessageHandler onResume});

  void requestNotificationPermissions();

  void dispose() {}
}
