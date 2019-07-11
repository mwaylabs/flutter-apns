import 'dart:async';

import 'package:flutter_apns/connector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' hide MessageHandler;
export 'package:flutter_apns/connector.dart';

class ApnsPushConnector extends PushConnector {
  final MethodChannel _channel = const MethodChannel('flutter_apns');
  MessageHandler _onMessage;
  MessageHandler _onLaunch;
  MessageHandler _onResume;

  @override
  void requestNotificationPermissions(
      [IosNotificationSettings iosSettings = const IosNotificationSettings()]) {
    _channel.invokeMethod(
        'requestNotificationPermissions', iosSettings.toMap());
  }

  final StreamController<IosNotificationSettings> _iosSettingsStreamController =
      StreamController<IosNotificationSettings>.broadcast();

  Stream<IosNotificationSettings> get onIosSettingsRegistered {
    return _iosSettingsStreamController.stream;
  }

  /// Sets up [MessageHandler] for incoming messages.
  @override
  void configure({
    MessageHandler onMessage,
    MessageHandler onLaunch,
    MessageHandler onResume,
  }) {
    _onMessage = onMessage;
    _onLaunch = onLaunch;
    _onResume = onResume;
    _channel.setMethodCallHandler(_handleMethod);
    _channel.invokeMethod('configure');
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onToken':
        token.value = call.arguments;
        return null;
      case 'onIosSettingsRegistered':
        final obj = IosNotificationSettings._fromMap(
            call.arguments.cast<String, bool>());
        isDisabledByUser.value = obj?.alert == false;
        return null;
      case 'onMessage':
        return _onMessage(call.arguments.cast<String, dynamic>());
      case 'onLaunch':
        return _onLaunch(call.arguments.cast<String, dynamic>());
      case 'onResume':
        return _onResume(call.arguments.cast<String, dynamic>());
      default:
        throw UnsupportedError('Unrecognized JSON message');
    }
  }

  @override
  final isDisabledByUser = ValueNotifier(false);

  @override
  final token = ValueNotifier<String>(null);

  @override
  String get providerType => "APNS";

  @override
  void dispose() {
    _iosSettingsStreamController.close();
    super.dispose();
  }
}

class IosNotificationSettings {
  const IosNotificationSettings({
    this.sound = true,
    this.alert = true,
    this.badge = true,
  });

  IosNotificationSettings._fromMap(Map<String, bool> settings)
      : sound = settings['sound'],
        alert = settings['alert'],
        badge = settings['badge'];

  final bool sound;
  final bool alert;
  final bool badge;

  Map<String, dynamic> toMap() {
    return <String, bool>{'sound': sound, 'alert': alert, 'badge': badge};
  }

  @override
  String toString() => 'PushNotificationSettings ${toMap()}';
}
