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
      connector.shouldPresent = (x) => Future.value(true);
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
                builder: (context, data, __) {
                  return SelectableText('$data');
                },
              ),
              FlatButton(
                child: Text('Register'),
                onPressed: _register,
              ),
              FlatButton(
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

Future<dynamic> onPush(String name, Map<String, dynamic> payload) {
  storage.append('$name: $payload');

  final action = UNNotificationAction.getIdentifier(payload);

  if (action == 'MEETING_INVITATION') {
    // do something
  }

  return Future.value(true);
}

Future<dynamic> _onBackgroundMessage(Map<String, dynamic> data) =>
    onPush('onBackgroundMessage', data);
