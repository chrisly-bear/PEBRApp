import 'package:flutter/material.dart';
import 'package:pebrapp/screens/SettingsScreen.dart';
import 'package:pebrapp/screens/NewPatientScreen.dart';
import 'package:pebrapp/screens/PatientScreen.dart';
import 'dart:ui';

void main() => runApp(PEBRApp());

class PEBRApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'PEBRApp', theme: ThemeData.light(), home: PEBRAppHome());
  }
}

class PEBRAppHome extends StatefulWidget {
  @override
  PEBRAppHomeState createState() => new PEBRAppHomeState();
}

class PEBRAppHomeState extends State<PEBRAppHome> {
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
    for (var i = 0; i < numberOfPatients; i++) {
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
                    _formatText('B/01/00378'),
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

class PageHeader extends StatelessWidget {
  String _title, _subtitle;

  PageHeader({String title, String subtitle}) {
    this._title = title;
    this._subtitle = subtitle;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: _buildTitleAndSubtitle(_title, _subtitle)),
    );
  }

  _buildTitleAndSubtitle(String title, String subtitle) {
    if (title == null && subtitle == null) {
      return null;
    }

    if (title != null) {
      if (subtitle != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _formatTitle(title),
            _formatSubtitle(subtitle),
          ],
        );
      } else {
        return _formatTitle(title);
      }
    }
  }

  _formatTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  _formatSubtitle(String subtitle) {
    return Text(
      subtitle,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}
