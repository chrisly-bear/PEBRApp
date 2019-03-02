import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

import 'package:pebrapp/screens/SettingsScreen.dart';
import 'package:pebrapp/screens/NewPatientScreen.dart';
import 'package:pebrapp/screens/PatientScreen.dart';
import 'package:pebrapp/components/PageHeader.dart';

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => new MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final _appBarHeight = 115.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 224, 224, 224),
        floatingActionButton: FloatingActionButton(
          onPressed: _pushNewPatientScreen,
          child: Icon(Icons.add),
        ),
        body: Stack(
          children: <Widget>[
            _buildPatientTable(context),
            Container(
              height: _appBarHeight,
              child: ClipRect(
                child: BackdropFilter(
                  filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: _customHeightAppBar(),
                ),
              ),
            ),
          ],
        ));
  }

  _customHeightAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      // This is a hack so we can increase the height of the AppBar
//      bottom: PreferredSize(
//        child: Container(),
//        preferredSize: Size.fromHeight(35),
//      ),
      flexibleSpace: PageHeader(title: 'Patients', subtitle: 'Overview'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: _pushSettingsScreen,
        )
      ],
    );
  }

  void _pushSettingsScreen() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return SettingsScreen();
        },
      ),
    );
  }

  void _pushNewPatientScreen() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return NewPatientScreen();
        },
      ),
    );
  }

  void _pushPatientScreen() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return PatientScreen();
        },
      ),
    );
  }

  _buildPatientTable(BuildContext context) {
    return ListView(
      children: _buildPatientCards(context),
    );
  }

  _buildPatientCards(BuildContext context) {
    final _paddingVertical = 10.0;
    final _paddingHorizontal = 10.0;

    var _patients = <Widget>[
      // container acting as margin for the app bar
      Container(
        height: _appBarHeight - 10,
        color: Colors.transparent,
      )
    ];
    final numberOfPatients = 20;
    final random = Random();
    for (var i = 0; i < numberOfPatients; i++) {
      final randomPatientId = random.nextInt(100000).toString().padLeft(5, '0');
      _patients.add(Card(
        margin: i == numberOfPatients - 1
            ? EdgeInsets.only(
                top: _paddingVertical,
                bottom: _paddingVertical,
                left: _paddingHorizontal,
                right: _paddingHorizontal)
            : EdgeInsets.only(
                top: _paddingVertical,
                bottom: 0,
                left: _paddingHorizontal,
                right: _paddingHorizontal),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            onTap: _pushPatientScreen,
            // Generally, material cards use onSurface with 12% opacity for the pressed state.
            splashColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
            // Generally, material cards do not have a highlight overlay.
            highlightColor: Colors.transparent,
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Row(
                  children: <Widget>[
                    _formatText('B/01/$randomPatientId'),
                    _formatText('02.02.2019'),
                    _formatText('VHW'),
                    Icon(Icons.home),
                    _formatText('Unsuppr'),
                    _formatText('Today'),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ))),
      ));
    }
    return _patients;
  }

  _formatText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
      ),
    );
  }
}
