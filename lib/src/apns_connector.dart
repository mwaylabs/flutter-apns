import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_apns/src/connector.dart';
import 'package:flutter/services.dart' hide MessageHandler;
export 'package:flutter_apns/src/connector.dart';

typedef WillPresentHandler = Future<bool> Function(Map<String, dynamic>);

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
    MessageHandler onBackgroundMessage,
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
      case 'willPresent':
        final payload = call.arguments.cast<String, dynamic>();
        return shouldPresent?.call(payload) ?? Future.value(false);

      default:
        throw UnsupportedError('Unrecognized JSON message');
    }
  }

  /// Handler that returns true/false to decide if push alert should be displayed when in foreground.
  /// Returning true will delay onMessage callback until user actually clicks on it
  WillPresentHandler shouldPresent;

  @override
  final isDisabledByUser = ValueNotifier(null);

  @override
  final token = ValueNotifier<String>(null);

  @override
  String get providerType => "APNS";

  @override
  void dispose() {
    _iosSettingsStreamController.close();
    super.dispose();
  }

  /// https://developer.apple.com/documentation/usernotifications/declaring_your_actionable_notification_types
  Future<void> setNotificationCategories(
      List<UNNotificationCategory> categories) {
    return _channel.invokeMethod(
      'setNotificationCategories',
      categories.map((e) => e.toJson()).toList(),
    );
  }

  @override
  Future<void> unregister() async {
    await _channel.invokeMethod('unregister');
    token.value = null;
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

/// https://developer.apple.com/documentation/usernotifications/unnotificationcategory
class UNNotificationCategory {
  final String identifier;
  final List<UNNotificationAction> actions;
  final List<String> intentIdentifiers;
  final List<UNNotificationCategoryOptions> options;

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'actions': actions.map((e) => e.toJson()).toList(),
      'intentIdentifiers': intentIdentifiers,
      'options': _optionsToJson(options),
    };
  }

  UNNotificationCategory({
    @required this.identifier,
    @required this.actions,
    @required this.intentIdentifiers,
    @required this.options,
  });
}

/// https://developer.apple.com/documentation/usernotifications/UNNotificationAction
class UNNotificationAction {
  final String identifier;
  final String title;
  final List<UNNotificationActionOptions> options;

  static const defaultIdentifier =
      'com.apple.UNNotificationDefaultActionIdentifier';

  /// Returns action identifier associated with this push.
  /// May be null, UNNotificationAction.defaultIdentifier, or value declared in setNotificationCategories
  static String getIdentifier(Map<String, dynamic> payload) {
    return payload['aps']['actionIdentifier'];
  }

  UNNotificationAction({
    @required this.identifier,
    @required this.title,
    @required this.options,
  });

  dynamic toJson() {
    return {
      'identifier': identifier,
      'title': title,
      'options': _optionsToJson(options),
    };
  }
}

/// https://developer.apple.com/documentation/usernotifications/unnotificationactionoptions
enum UNNotificationActionOptions {
  authenticationRequired,
  destructive,
  foreground,
}

/// https://developer.apple.com/documentation/usernotifications/unnotificationcategoryoptions
enum UNNotificationCategoryOptions {
  customDismissAction,
  allowInCarPlay,
  hiddenPreviewsShowTitle,
  hiddenPreviewsShowSubtitle,
  allowAnnouncement,
}

List<String> _optionsToJson(List values) {
  return values.map((e) => e.toString()).toList();
}
