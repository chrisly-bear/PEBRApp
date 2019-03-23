import 'package:flutter/material.dart';
import 'package:pebrapp/components/SizedButton.dart';
import 'package:pebrapp/utils/Utils.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 224, 224, 224),
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
        SizedButton('Set PIN'),
        SizedButton('Start Backup', onPressed: uploadDatabaseToFirebaseStorage,),
        Text("last backup: never")
      ],
    );
  }
}
