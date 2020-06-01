import 'package:flutter_apns/apns.dart';
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
  final connector = createPushConnector();

  @override
  void initState() {
    super.initState();

    connector.configure(
      onLaunch: (data) => onPush('onLaunch', data),
      onResume: (data) => onPush('onResume', data),
      onMessage: (data) => onPush('onMessage', data),
      onBackgroundMessage: (data) => onPush('onBackgroundMessage', data),
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
        body: AnimatedBuilder(
          animation: storage,
          builder: (contexxt, _) {
            return Text(storage.content);
          },
        ),
      ),
    );
  }
}

Future<dynamic> onPush(String name, Map<String, dynamic> data) {
  storage.append('$name: $data');
  return Future.value();
}
