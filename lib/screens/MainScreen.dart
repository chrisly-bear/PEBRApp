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
    final _cardPaddingVertical = 10.0;
    final _cardPaddingHorizontal = 10.0;
    final _rowPaddingVertical = 20.0;
    final _rowPaddingHorizontal = 15.0;

    print("_buildPatientCards called. Number of patients in DB: ${_patients.length}");

    _formatHeaderRowText(String text) {
      return Text(
        text.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
      );
    }

    _formatPatientRowText(String text) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 18,
        ),
      );
    }

    var _patientCards = <Widget>[
      // container acting as margin for the app bar
      Container(
        height: _appBarHeight - 10,
        color: Colors.transparent,
      ),
      Container(
          padding: EdgeInsets.symmetric(
              vertical: _cardPaddingVertical,
              horizontal: _cardPaddingHorizontal),
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _rowPaddingHorizontal),
              child: Row(
                children: <Widget>[
                  Expanded(child: _formatHeaderRowText('ART NR.')),
                  Expanded(child: _formatHeaderRowText('NEXT REFILL')),
                  Expanded(child: _formatHeaderRowText('REFILL BY')),
                  Expanded(flex: 2, child: _formatHeaderRowText('SUPPORT')),
                  Expanded(child: _formatHeaderRowText('VIRAL LOAD (EAC)')),
                  Expanded(child: _formatHeaderRowText('NEXT ASSESSMENT')),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ))),
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
        elevation: 5.0,
        margin: i == numberOfPatients - 1 // last element also has padding at the bottom
            ? EdgeInsets.symmetric(
                vertical: _cardPaddingVertical,
                horizontal: _cardPaddingHorizontal)
            : EdgeInsets.only(
                top: _cardPaddingVertical,
                bottom: 0,
                left: _cardPaddingHorizontal,
                right: _cardPaddingHorizontal),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            onTap: () {
              _pushPatientScreen(patientART);
            },
            // Generally, material cards use onSurface with 12% opacity for the pressed state.
            splashColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
            // Generally, material cards do not have a highlight overlay.
            highlightColor: Colors.transparent,
            child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: _rowPaddingVertical,
                    horizontal: _rowPaddingHorizontal),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _formatPatientRowText(patientART)),
                    Expanded(child: _formatPatientRowText('02.02.2019')),
                    Expanded(child: _formatPatientRowText('VHW')),
                    Expanded(
                      flex: 2,
                        child: Row(
                            children: [
//                              Icon(Icons.home),

                              // *** custom icons
                              ClipRect(
                                  clipBehavior: Clip.antiAlias,
                                  child: SizedOverflowBox(
                                      size: Size(24.0, 24.0),
                                      child: Image(
                                        height: 30.0,
                                        image: AssetImage(
                                            'assets/icons/homevisit_pe.png'),
                                      ))),
                              Container(width: 5),
                              ClipRect(
                                  clipBehavior: Clip.antiAlias,
                                  child: SizedOverflowBox(
                                      size: Size(24.0, 24.0),
                                      child: Image(
                                        height: 30.0,
                                        image: AssetImage(
                                            'assets/icons/nurse_clinic.png'),
                                      ))),
                              Container(width: 5),
                              ClipRect(
                                  clipBehavior: Clip.antiAlias,
                                  child: SizedOverflowBox(
                                      size: Size(24.0, 24.0),
                                      child: Image(
                                        height: 30.0,
                                        image: AssetImage(
                                            'assets/icons/phonecall_pe.png'),
                                      ))),
                              Container(width: 5),
                              ClipRect(
                                  clipBehavior: Clip.antiAlias,
                                  child: SizedOverflowBox(
                                      size: Size(24.0, 24.0),
                                      child: Image(
                                        height: 30.0,
                                        image: AssetImage(
                                            'assets/icons/saturday_clinic_club.png'),
                                      ))),
                              Container(width: 5),
                              ClipRect(
                                  clipBehavior: Clip.antiAlias,
                                  child: SizedOverflowBox(
                                      size: Size(24.0, 24.0),
                                      child: Image(
                                        height: 30.0,
                                        image: AssetImage(
                                            'assets/icons/schooltalk_pe.png'),
                                      ))),
                              Container(width: 5),
                              ClipRect(
                                  clipBehavior: Clip.antiAlias,
                                  child: SizedOverflowBox(
                                      size: Size(24.0, 24.0),
                                      child: Image(
                                        height: 30.0,
                                        image: AssetImage(
                                            'assets/icons/youth_club.png'),
                                      ))),
                              Container(width: 5),
                              ClipRect(
                                  clipBehavior: Clip.antiAlias,
                                  child: SizedOverflowBox(
                                      size: Size(24.0, 24.0),
                                      child: Image(
                                        height: 30.0,
                                        image: AssetImage(
                                            'assets/icons/no_support.png'),
                                      ))),
//                      ImageIcon(
//                        AssetImage('assets/icons/viralload_suppressed.png'),
//                        color: Colors.green,
//                      ),
                        ]
                        )
                    ),
                    Expanded(
                        child: Row(children: [
//                      _formatPatientRowText(viralLoadEACText),
//                      Icon(Icons.phone),

                      // *** custom icons
                      ClipRect(
                          clipBehavior: Clip.antiAlias,
                          child: SizedOverflowBox(
                              size: Size(24.0, 24.0),
                              child: Image(
                                height: 30.0,
                                image: AssetImage(
                                    'assets/icons/viralload_suppressed.png'),
                              ))),
                      Container(width: 5),
                      ClipRect(
                          clipBehavior: Clip.antiAlias,
                          child: SizedOverflowBox(
                              size: Size(24.0, 24.0),
                              child: Image(
                                height: 30.0,
                                image: AssetImage(
                                    'assets/icons/nurse_clinic.png'),
                              ))),
                    ])),
                    Expanded(child: _formatPatientRowText('Today')),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ))),
      ));
    }
    return _patientCards;
  }

}
