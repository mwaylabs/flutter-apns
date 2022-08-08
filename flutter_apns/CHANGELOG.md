### 1.6.0
* (#97) updated dependencies
* enhanced example app
### 1.5.4
* explicitly mentioned supported platforms in pubspec.yaml
### 1.5.3
* update firebase dependencies
* Add readme: how to run example app in iOS
### 1.5.1
* (#58) fix unable to build android (update firebase dependencies)
### 1.5.0-dev.1
* (#51) Update firebase push connector to support the firebase_messaging 9.0.0. API
* (#43) Fix onLaunch not working with closed app
* (#41) Add authorization status for iOS
* (#48) Upgrade to null safety
* (#48) separate flutter_apns and flutter_apns_only

### 1.4.1
* (#31) fix duplicated onLaunch onResume
* (#37) add possibility to disable firebase core

### 1.4.0
* (#32) add unregister method
* (#24) add support for foreground alerts
* (#15) add support for actions

### 1.3.1
* documentation & project structure cleanup

### 1.3.0
* upgraded firebase to 7.0.0

### 1.2.0
* upgraded firebase to 6.0.16
  IMPORTANT! New version requires setting UNUserNotificationCenterDelegate. Check the readme.

### 1.1.0
* merged https://github.com/mwaylabs/flutter-apns/pull/11 - make sure that you are handling isDisabledByUser == null
* upgraded firebase to 6.0.9

### 1.0.5
* fixed https://github.com/mwaylabs/flutter-apns/issues/9

### 1.0.4
* fixed iOS 13 bug with decoding token from NSData

### 1.0.3
* added background messaging support oon Android
* added workaround for flutter 1.7

### 1.0.2
* fixed compilation error when using dynamic frameworks
* upgraded dependencies

## 1.0.1
* fixed compilation error with newer flutter version
* implemented method swizzling which will prevent firebase plugin from registering

## 1.0.0
* First release.
