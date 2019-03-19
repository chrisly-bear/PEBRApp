import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pebrapp/components/ViralLoadIndicator.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'dart:ui';

import 'package:pebrapp/screens/SettingsScreen.dart';
import 'package:pebrapp/screens/NewOrEditPatientScreen.dart';
import 'package:pebrapp/screens/PatientScreen.dart';
import 'package:pebrapp/components/PageHeader.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/Utils.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _appBarHeight = 115.0;
  // TODO: remove _context field and pass context via args if necessary
  BuildContext _context;
  bool _isLoading = true;
  List<Patient> _patients = [];
  Stream<AppState> _appStateStream;

  @override
  void initState() {
    super.initState();
    print('~~~ MainScreenState.initState ~~~');
    _appStateStream = PatientBloc.instance.appState;

    /*
     * Normally, one uses StreamBuilder with the BLoC pattern. But StreamBuilder
     * always receives the last event from the stream when the build method is
     * called. If the last event was a AppStatePatientData (i.e. a new patient
     * was added or an existing one edited) then this patient gets added to the
     * list on every build. And because the Navigator also causes builds of pages
     * that are not visible (such as this MainScreen page), we add the same
     * patient every time we push/pop a Screen onto/from the Navigator stack.
     *
     * StreamBuilder issue and solution:
     * https://github.com/flutter/flutter/issues/22713#issuecomment-438562916
     *
     * Navigator build calls issue:
     * https://github.com/flutter/flutter/issues/11655#issuecomment-348287396
     */
    _appStateStream.listen( (streamEvent) {
      print('*** stream.listen received data: ${streamEvent.runtimeType} ***');
      if (streamEvent is AppStateLoading) {
        setState(() {
          this._isLoading = true;
        });
      }
      if (streamEvent is AppStatePatientData) {
        print('*** stream.listen received AppStatePatientData: ${streamEvent.patient.artNumber} ***');
        setState(() {
          this._isLoading = false;
          // TODO: replace existing patient with the same ART number to avoid duplicates (happens when a patient was edited)
          this._patients.add(streamEvent.patient);
        });
      }
      if (streamEvent is AppStatePreferenceAssessmentData) {
        setState(() {
          // TODO: implement changes to a patient's PreferenceAssessment
        });
      }
    });

//    _appStateStream.skip(1);
    PatientBloc.instance.sinkAllPatientsFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 224, 224, 224),
        floatingActionButton: FloatingActionButton(
          onPressed: _pushNewPatientScreen,
          child: Icon(Icons.add),
        ),
        body: Stack(
          children: <Widget>[
            _isLoading ? _bodyLoading() : _bodyPatientTable(),
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
          icon: Icon(Icons.refresh),
          onPressed: PatientBloc.instance.sinkAllPatientsFromDatabase
        ),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: _pushSettingsScreen,
        ),
      ],
    );
  }

  void _pushSettingsScreen() {
    Navigator.of(_context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return SettingsScreen();
        },
      ),
    );
  }

  void _pushNewPatientScreen() {
    Navigator.of(_context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return NewOrEditPatientScreen();
        },
      ),
    );
  }

  void _pushPatientScreen(Patient patient) {
    Navigator.of(_context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return PatientScreen(patient);
        },
      ),
    );
  }

  _bodyLoading() {
    return Center(child: Text("LOADING..."));
  }

  _bodyNoData() {
    return Center(child: Text("No patients recorded yet. Add new patient by clicking the + icon."));
  }

  _bodyPatientTable() {
    return ListView(
      children: _buildPatientCards(),
    );
  }

  _buildPatientCards() {
    final _cardPaddingVertical = 10.0;
    final _cardPaddingHorizontal = 10.0;
    final _rowPaddingVertical = 20.0;
    final _rowPaddingHorizontal = 15.0;

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

    _getSupportIcon(String assetLocation) {
      return ClipRect(
          clipBehavior: Clip.antiAlias,
          child: SizedOverflowBox(
              size: Size(24.0, 24.0),
              child: Image(
                height: 30.0,
                image: AssetImage(
                    assetLocation),
              )));
    }

    Widget _buildSupportIcons(SupportPreferencesSelection sps) {
      List<Widget> icons = List<Widget>();
      final Container spacer = Container(width: 5);
      if (sps == null) {
        return _formatPatientRowText('—');
      }
      if (sps.homeVisitPESelected) {
//        icons.add(Icon(Icons.home));
        icons.add(_getSupportIcon('assets/icons/homevisit_pe.png'));
        icons.add(spacer);
      }
      if (sps.nurseAtClinicSelected) {
        icons.add(_getSupportIcon('assets/icons/nurse_clinic.png'));
        icons.add(spacer);
      }
      if (sps.saturdayClinicClubSelected) {
        icons.add(_getSupportIcon('assets/icons/saturday_clinic_club.png'));
        icons.add(spacer);
      }
      if (sps.schoolTalkPESelected) {
//        icons.add(Icon(Icons.school));
        icons.add(_getSupportIcon('assets/icons/schooltalk_pe.png'));
        icons.add(spacer);
      }
      if (sps.communityYouthClubSelected) {
        icons.add(_getSupportIcon('assets/icons/youth_club.png'));
        icons.add(spacer);
      }
      if (sps.phoneCallPESelected) {
//        icons.add(Icon(Icons.phone));
        icons.add(_getSupportIcon('assets/icons/phonecall_pe.png'));
        icons.add(spacer);
      }
      if (sps.areAllDeselected) {
        icons.add(_getSupportIcon('assets/icons/no_support.png'));
        icons.add(spacer);
      }
      if (icons.last == spacer) {
        // remove last spacer as there are no more icons that follow it
        icons.removeLast();
      }
      return Row(children: icons);
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

      ViralLoadIndicator viralLoadIndicator = ViralLoadIndicator(ViralLoad.NA, smallSize: true);
      var viralLoadEACText = '—';
      if (curPatient.vlSuppressed != null && curPatient.vlSuppressed) {
        viralLoadEACText = 'SUPPR';
        viralLoadIndicator = ViralLoadIndicator(ViralLoad.SUPPRESSED, smallSize: true);
      } else if (curPatient.vlSuppressed != null && !curPatient.vlSuppressed) {
        viralLoadEACText = 'UNSUPPR';
        viralLoadIndicator = ViralLoadIndicator(ViralLoad.UNSUPPRESSED, smallSize: true);
      }

      String refillByText = '—';
      ARTRefillOption aro = curPatient.latestPreferenceAssessment?.artRefillOption1;
      if (aro != null) {
        refillByText = artRefillOptionToString(aro);
      }

      final _curCardMargin = i == numberOfPatients - 1 // last element also has padding at the bottom
          ? EdgeInsets.symmetric(
          vertical: _cardPaddingVertical,
          horizontal: _cardPaddingHorizontal)
          : EdgeInsets.only(
          top: _cardPaddingVertical,
          bottom: 0,
          left: _cardPaddingHorizontal,
          right: _cardPaddingHorizontal);

      _patientCards.add(Dismissible(
          key: Key(curPatient.artNumber),
          onDismissed: (direction) {
            print('removing patient with ART number ${curPatient.artNumber}');
            DatabaseProvider().deletePatient(curPatient).then((int rowsAffected) {
              showFlushBar(context, 'Removed patient ${curPatient.artNumber} ($rowsAffected rows deleted in DB)');
              _patients.removeWhere((p) => p.artNumber == curPatient.artNumber);
            });
          },
          background: Container(
            margin: _curCardMargin,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            color: Colors.red,
//            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
              Text(
                "DELETE",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "DELETE",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ]
            ),
          ),
          child: Card(
        elevation: 5.0,
        margin: _curCardMargin,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            onTap: () {
              _pushPatientScreen(curPatient);
            },
            // Generally, material cards use onSurface with 12% opacity for the pressed state.
            splashColor:
                Colors.yellow,
//                Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
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
                    Expanded(child: _formatPatientRowText(refillByText)),
                    Expanded(
                      flex: 2,
                        child: _buildSupportIcons(curPatient?.latestPreferenceAssessment?.supportPreferences),
                    ),
                    Expanded(
                        child: Row(children: [
//                      _formatPatientRowText(viralLoadEACText),
//                      Icon(Icons.phone),
                          viralLoadIndicator,

                      // *** custom icons
//                      _getSupportIcon('assets/icons/viralload_suppressed.png'),
//                      Container(width: 5),
                      _getSupportIcon('assets/icons/nurse_clinic.png'),
                    ])),
                    Expanded(child: _formatPatientRowText('Today')),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ))),
      )));
    }
    return _patientCards;
  }

}
