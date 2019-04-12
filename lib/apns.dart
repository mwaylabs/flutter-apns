import 'dart:io';

import 'package:flutter_apns/apns_connector.dart';
import 'package:flutter_apns/connector.dart';
import 'package:flutter_apns/firebase_connector.dart';

/// Creates either APNS or Firebase connector to manage the push notification registration.
PushConnector createPushConnector() {
  if (Platform.isAndroid) {
    return FirebasePushConnector();
  } else {
    return ApnsPushConnector();
  }
}
