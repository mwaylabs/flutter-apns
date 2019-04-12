import 'package:flutter_apns/apns.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

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
    );
    connector.requestNotificationPermissions();
  }

  Future<void> onPush(Map<String, dynamic> data) {
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
      ),
    );
  }
}
