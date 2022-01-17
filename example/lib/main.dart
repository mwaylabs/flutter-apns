import 'package:flutter_apns/flutter_apns.dart';
import 'package:flutter/material.dart';

import 'storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await storage.setup();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PushConnector connector = createPushConnector();

  Future<void> _register() async {
    final connector = this.connector;
    connector.configure(
      onLaunch: (data) => onPush('onLaunch', data),
      onResume: (data) => onPush('onResume', data),
      onMessage: (data) => onPush('onMessage', data),
      onBackgroundMessage: _onBackgroundMessage,
    );
    connector.token.addListener(() {
      print('Token ${connector.token.value}');
    });
    connector.requestNotificationPermissions();

    if (connector is ApnsPushConnector) {
      connector.shouldPresent = (x) async {
        final remote = RemoteMessage.fromMap(x.payload);
        return remote.category == 'MEETING_INVITATION';
      };
      connector.setNotificationCategories([
        UNNotificationCategory(
          identifier: 'MEETING_INVITATION',
          actions: [
            UNNotificationAction(
              identifier: 'ACCEPT_ACTION',
              title: 'Accept',
              options: UNNotificationActionOptions.values,
            ),
            UNNotificationAction(
              identifier: 'DECLINE_ACTION',
              title: 'Decline',
              options: [],
            ),
          ],
          intentIdentifiers: [],
          options: UNNotificationCategoryOptions.values,
        ),
      ]);
    }
  }

  @override
  void initState() {
    storage.append('restart');
    _register();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Token:'),
              ValueListenableBuilder(
                valueListenable: connector.token,
                builder: (context, dynamic data, __) {
                  return SelectableText('$data');
                },
              ),
              TextButton(
                child: Text('Register'),
                onPressed: _register,
              ),
              TextButton(
                child: Text('Unregister'),
                onPressed: connector.unregister,
              ),
              AnimatedBuilder(
                animation: storage,
                builder: (context, _) {
                  return Text(storage.content);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<dynamic> onPush(String name, RemoteMessage payload) {
  storage.append('$name: ${payload.notification?.title}');

  final action = UNNotificationAction.getIdentifier(payload.data);

  if (action != null && action != UNNotificationAction.defaultIdentifier) {
    storage.append('Action: $action');
  }

  return Future.value(true);
}

Future<dynamic> _onBackgroundMessage(RemoteMessage data) =>
    onPush('onBackgroundMessage', data);
