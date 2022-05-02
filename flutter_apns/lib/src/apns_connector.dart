import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_apns_only/flutter_apns_only.dart';
export 'package:flutter_apns_only/flutter_apns_only.dart';

import 'connector.dart';

class ApnsPushConnector extends ApnsPushConnectorOnly implements PushConnector {
  @override
  Future<void> configure({onMessage, onLaunch, onResume, onBackgroundMessage, options}) {
    ApnsMessageHandler? mapHandler(MessageHandler? input) {
      if (input == null) {
        return null;
      }

      return (apnsMessage) => input(RemoteMessage.fromMap(apnsMessage.payload));
    }

    configureApns(
        onMessage: mapHandler(onMessage),
        onLaunch: mapHandler(onLaunch),
        onResume: mapHandler(onResume),
        onBackgroundMessage: mapHandler(onBackgroundMessage));

    return Future<void>.value();
  }
}
