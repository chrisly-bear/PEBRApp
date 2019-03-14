import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:pebrapp/screens/SettingsScreen.dart';
import 'package:pebrapp/screens/NewPatientScreen.dart';
import 'package:pebrapp/screens/PatientScreen.dart';
import 'package:pebrapp/components/PageHeader.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/Patient.dart';

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => new MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final _appBarHeight = 115.0;
  var _patients = List<Patient>();

  @override
  void initState() {
    _updateListView();
    super.initState();
  }

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

  void _pushNewPatientScreen() async {
    await Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return NewPatientScreen();
        },
      ),
    );

    // reload patients from database
    _updateListView();
  }

  void _updateListView() async {
    final patientList = await DatabaseProvider().retrievePatients();
    setState(() {
      _patients = patientList;
    });
  }

  void _pushPatientScreen(patientId) {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return PatientScreen(patientId);
        },
      ),
    );
  }

  _buildPatientTable(BuildContext context) {
    if (_patients.isEmpty) {
      return Center(child: Text("No patients recorded yet. Add new patient by clicking the + icon."));
    }
    return ListView(
      children: _buildPatientCards(context),
    );
  }

  _buildPatientCards(BuildContext context) {
    final _paddingVertical = 10.0;
    final _paddingHorizontal = 10.0;

    print("_buildPatientCards called. Number of patients in DB: ${_patients.length}");

    var _patientCards = <Widget>[
      // container acting as margin for the app bar
      Container(
        height: _appBarHeight - 10,
        color: Colors.transparent,
      )
    ];
    final numberOfPatients = _patients.length;
    for (var i = 0; i < numberOfPatients; i++) {
      final Patient curPatient = _patients[i];
      final patientART = curPatient.artNumber;
      var viralLoadEACText = '—';
      if (curPatient.vlSuppressed != null && curPatient.vlSuppressed) {
        viralLoadEACText = 'SUPPR';
      } else if (curPatient.vlSuppressed != null && !curPatient.vlSuppressed) {
        viralLoadEACText = 'UNSUPPR';
      }
      _patientCards.add(Card(
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
            onTap: () {_pushPatientScreen(patientART);},
            // Generally, material cards use onSurface with 12% opacity for the pressed state.
            splashColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
            // Generally, material cards do not have a highlight overlay.
            highlightColor: Colors.transparent,
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Row(
                  children: <Widget>[
                    _formatText(patientART),
                    _formatText('02.02.2019'),
                    _formatText('VHW'),
                    Icon(Icons.home),
                    _formatText(viralLoadEACText),
                    _formatText('Today'),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ))),
      ));
    }
    return _patientCards;
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
