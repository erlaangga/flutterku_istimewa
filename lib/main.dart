import 'package:flutter/material.dart';
import 'package:flutterku_istimewa/api.dart';
import 'package:flutterku_istimewa/home.dart';
import 'package:flutterku_istimewa/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (sessionId == '') {
      return MaterialApp(
        title: 'InstaDerma',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginPage(title: 'Login'),
      );
    }
    return MaterialApp(
      title: 'InstaDerma',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'News Feed'),
    );
  }
}
