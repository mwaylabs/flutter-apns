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

  @override
  void initState() {
    super.initState();

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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Text('Token:'),
            ValueListenableBuilder(
              valueListenable: connector.token,
              builder: (context, data, __) {
                return SelectableText('$data');
              },
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: storage,
                builder: (context, _) {
                  return Text(storage.content);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<dynamic> onPush(String name, Map<String, dynamic> data) {
  storage.append('$name: $data');
  return Future.value();
}

Future<dynamic> _onBackgroundMessage(Map<String, dynamic> data) =>
    onPush('onBackgroundMessage', data);
