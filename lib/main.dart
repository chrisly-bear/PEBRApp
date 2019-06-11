import 'package:flutter/material.dart';
import 'package:pebrapp/screens/LockScreen.dart';
import 'package:pebrapp/screens/MainScreen.dart';
import 'package:pebrapp/screens/SettingsScreen.dart';
import 'package:pebrapp/screens/IconExplanationsScreen.dart';

void main() => runApp(PEBRApp());

class PEBRApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        initialRoute: '/',
        routes: {
          // these can be used for calls such as
          // Navigator.pushNamed(context, '/settings')
          '/': (context) => MainScreen(),
          '/settings': (context) => SettingsScreen(),
          '/icons': (context) => IconExplanationsScreen(),
          '/lock': (context) => LockScreen(),
        },
        title: 'PEBRApp',
        theme: ThemeData.light(),
    );
  }
}
