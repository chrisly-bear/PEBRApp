import 'package:flutter/material.dart';
import 'package:pebrapp/screens/MainScreen.dart';
import 'package:pebrapp/state/AppStateContainer.dart';

void main() => runApp(PEBRApp());

class PEBRApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'PEBRApp',
        theme: ThemeData.light(),
        home: AppStateContainer(
            child: MainScreen()
        )
    );
  }
}
