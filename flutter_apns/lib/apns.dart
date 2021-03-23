import 'dart:io';

import 'package:flutter_apns/src/apns_connector.dart';
import 'package:flutter_apns/src/connector.dart';
import 'package:flutter_apns/src/firebase_connector.dart';

export 'package:flutter_apns/src/connector.dart';
export 'package:flutter_apns/src/apns_connector.dart';
export 'package:flutter_apns/src/firebase_connector.dart';

/// Creates either APNS or Firebase connector to manage the push notification registration.
PushConnector createPushConnector() {
  if (Platform.isIOS) {
    return ApnsPushConnector();
  } else {
    return FirebasePushConnector();
  }
}
