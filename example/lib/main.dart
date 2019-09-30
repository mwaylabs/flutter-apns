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
      onLaunch: onPush,
      onResume: onPush,
      onMessage: onPush,
      onBackgroundMessage: onBackgroundPush,
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

Future<dynamic> onPush(Map<String, dynamic> data) {
  storage.append('onPush: $data');
  return Future.value();
}

Future<dynamic> onBackgroundPush(Map<String, dynamic> data) async {
  storage.append('onBackgroundPush: $data');
  return Future.value();
}
