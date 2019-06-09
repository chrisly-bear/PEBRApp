import 'package:flutter/material.dart';
import 'package:pebrapp/screens/MainScreen.dart';
import 'package:pebrapp/screens/SettingsScreen.dart';
import 'package:pebrapp/screens/IconExplanationsScreen.dart';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(PEBRApp());
}

class PEBRApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => MainScreen(),
          '/settings': (context) => SettingsScreen(),
          '/icons': (context) => IconExplanationsScreen(),
        },
        title: 'PEBRApp',
        theme: ThemeData.light(),
    );
  }
}
