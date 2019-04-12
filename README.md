# apns

Plugin to implement APNS push notifications on iOS and Firebase on Android. 

## Why this plugin was made?

Currently, the only available push notification plugin is `firebase_messaging`. This means that, even on iOS, you will need to setup firebase and communicate with Google to send push notification. This plugin solves the problem by providing native APNS implementation while leaving configured Firebase for Android.

## Usage
1. Configure firebase on Android according to instructions: https://pub.dartlang.org/packages/firebase_messaging.
2. On iOS, make sure you have correctly configured your app to support push notifications, and that you have generated certificate/token for sending pushes.
3. On iOS, disable firebase method swizzling: https://firebase.google.com/docs/cloud-messaging/ios/client.
4. Add `flutter_apns` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).
5. Using `createPushConnector()` method, configure push service according to your needs. `PushConnector` closely resembles `FirebaseMessaging`, so Firebase samples may be useful during implementation.
```dart
import 'package:flutter_apns/apns.dart';

final connector = createPushConnector();
connector.configure(
    onLaunch: _onLaunch,
    onResume: _onResume,
    onMessage: _onMessage,
);
connector.requestNotificationPermissions()
```
6. Build on device and test your solution using Firebase Console and NWPusher app.
