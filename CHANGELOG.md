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