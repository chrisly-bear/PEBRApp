import 'package:flutter/material.dart';
import 'package:pebrapp/screens/MainScreen.dart';
import 'package:pebrapp/screens/SettingsScreen.dart';

void main() => runApp(PEBRApp());

class PEBRApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => MainScreen(),
          '/settings': (context) => SettingsScreen(),
        },
        title: 'PEBRApp',
        theme: ThemeData.light(),
    );
  }
}
