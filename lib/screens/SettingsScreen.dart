import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Center(child: SettingsBody()));
  }
}

class SettingsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 150,
          child: RaisedButton(
            onPressed: () {},
            child: Text('Set PIN'),
          ),
        ),
        SizedBox(
          width: 150,
          child: RaisedButton(
            onPressed: () {},
            child: Text('Start Backup'),
          ),
        ),
      ],
    );
  }
}
