import 'package:flutter/material.dart';
import 'package:pebrapp/screens/MainScreen.dart';

void main() => runApp(PEBRApp());

class PEBRApp extends StatefulWidget {
  @override
  _PEBRAppState createState() => _PEBRAppState();
}

class _PEBRAppState extends State<PEBRApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    // listen to changes in the app lifecycle
    WidgetsBinding.instance.addObserver(this);
    _runBackupAndUploadCSVToSWITCH();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _runBackupAndUploadCSVToSWITCH();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'PEBRApp',
        theme: ThemeData.light(),
        home: MainScreen()
    );
  }

  Future<void> _runBackupAndUploadCSVToSWITCH() async {
    print("### Attempting backup... ###");
    // TODO: run backup if the last successful backup dates back more than a day
    await Future.delayed(Duration(seconds: 5));
    print("### Backup complete! ###");
  }
}
