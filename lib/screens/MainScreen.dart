import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pebrapp/components/ViralLoadBadge.dart';
import 'package:pebrapp/config/PEBRAConfig.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/exceptions/DocumentNotFoundException.dart';
import 'package:pebrapp/exceptions/NoLoginDataException.dart';
import 'package:pebrapp/exceptions/SWITCHLoginFailedException.dart';
import 'package:pebrapp/screens/DebugScreen.dart';
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

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
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
    // listen to changes in the app lifecycle
    WidgetsBinding.instance.addObserver(this);
    _onAppResume();
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
      print('*** MainScreen received data: ${streamEvent.runtimeType} ***');
      if (streamEvent is AppStateLoading) {
        setState(() {
          this._isLoading = true;
        });
      }
      if (streamEvent is AppStateNoData) {
        setState(() {
          this._patients = [];
          this._isLoading = false;
        });
      }
      if (streamEvent is AppStatePatientData) {
        final newPatient = streamEvent.patient;
        print('*** MainScreen received AppStatePatientData: ${newPatient.artNumber} ***');
        setState(() {
          this._isLoading = false;
          int indexOfExisting = this._patients.indexWhere((p) => p.artNumber == newPatient.artNumber);
          if (indexOfExisting > -1) {
            // replace if patient exists (patient was edited)
            this._patients[indexOfExisting] = newPatient;
          } else {
            // add if not exists (new patient was added)
            this._patients.add(newPatient);
          }
        });
      }
      if (streamEvent is AppStatePreferenceAssessmentData) {
        setState(() {
          final newPreferenceAssessment = streamEvent.preferenceAssessment;
          Patient changedPatient = this._patients.singleWhere((p) => p.artNumber == newPreferenceAssessment.patientART);
          changedPatient.latestPreferenceAssessment = newPreferenceAssessment;
        });
      }
      if (streamEvent is AppStateARTRefillData) {
        setState(() {
          final newARTRefill = streamEvent.artRefill;
          Patient changedPatient = this._patients.singleWhere((p) => p.artNumber == newARTRefill.patientART);
          changedPatient.latestARTRefill = newARTRefill;
        });
      }

      setState(() {
        _sortPatients(_patients);
      });
    });

    PatientBloc.instance.sinkAllPatientsFromDatabase();
  }

  /// Sorts patients in the following way:
  ///
  /// - activated patients before deactivated patients
  /// - patients with missing ART refill or preference assessment before
  ///   patients with ART refill or preference assessment
  /// - patients with next action (ART refill / preference assessment) closer in
  ///   the future before patients with next action farther in the future
  void _sortPatients(List<Patient> patients) {
    patients.sort((Patient a, Patient b) {
      if (a.isActivated && !b.isActivated) { return -1; }
      if (!a.isActivated && b.isActivated) { return 1; } // do we need this rule or is it implied by the previous rule?
      final int actionsRequiredForA = _initialActionsRequiredFor(a);
      final int actionsRequiredForB = _initialActionsRequiredFor(b);
      if (actionsRequiredForA > actionsRequiredForB) { return -1; }
      if (actionsRequiredForA < actionsRequiredForB) { return 1; } // do we need this rule or is it implied by the previous rule?
      if (actionsRequiredForA == actionsRequiredForB) {
        final DateTime dateOfNextActionA = _getDateOfNextAction(a);
        final DateTime dateOfNextActionB = _getDateOfNextAction(b);
        if (dateOfNextActionA == null && dateOfNextActionB == null) {
          // both have no ART refill or preference assessment, let's sort by created date
          return a.createdDate.isBefore(b.createdDate) ? 1 : -1;
        }
        // sort the patient with the sooner next action date before the other
        return dateOfNextActionA.isBefore(dateOfNextActionB) ? -1 : 1;
      }
      return 0;
    });
  }

  /// Returns 0 if an ART refill and a preference assessment has been done.
  /// Returns 1 if either ART refill or preference assessment has not been done yet.
  /// Returns 2 if both ART refill and preference assessment have not been done yet.
  ///
  /// Assumes that the fields `latestARTRefill` and `latestPreferenceAssessment`
  /// have been initialized before calling this method.
  int _initialActionsRequiredFor(Patient patient) {
    int actionsRequired = 0;
    if (patient.latestARTRefill == null) { actionsRequired++; }
    if (patient.latestPreferenceAssessment == null) { actionsRequired++; }
    return actionsRequired;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onAppResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 224, 224, 224),
        floatingActionButton: FloatingActionButton(
          key: Key('addPatient'), // key can be used to find the button in integration testing
          onPressed: _pushNewPatientScreen,
          child: Icon(Icons.add),
        ),
        body: Stack(
          children: <Widget>[
            _bodyToDisplayBasedOnState(),
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

  // Gets called when the application comes to the foreground.
  Future<void> _onAppResume() async {

    // make user log in if he/she isn't already
    LoginData loginData = await loginDataFromSharedPrefs;
    if (loginData == null) {
      _pushSettingsScreen();
      return;
    }

    // check if backup is due
    int daysSinceLastBackup = -1; // -1 means one day from today, i.e. tomorrow
    final DateTime lastBackup = await latestBackupFromSharedPrefs;
    if (lastBackup != null) {
      daysSinceLastBackup = differenceInDays(lastBackup, DateTime.now());
      print('days since last backup: $daysSinceLastBackup');
      if (daysSinceLastBackup < AUTO_BACKUP_EVERY_X_DAYS && daysSinceLastBackup >= 0) {
        print("backup not due yet (only due after $AUTO_BACKUP_EVERY_X_DAYS days)");
        return; // don't run a backup, we have already backed up today
      }
    }

    String resultMessage = 'Backup Successful';
    String title;
    bool error = false;
    try {
      await DatabaseProvider().createAdditionalBackupOnSWITCH(loginData);
    } catch (e) {
      error = true;
      title = 'Backup Failed';
      switch (e.runtimeType) {
        case NoLoginDataException:
          // this case should never occur since we force the user to login when
          // resuming the app
          resultMessage = 'Not logged in. Please log in first.';
          break;
        case SWITCHLoginFailedException:
          resultMessage = 'Login to SWITCH failed. Contact the development team.';
          break;
        case DocumentNotFoundException:
          resultMessage = 'No existing backup found for user \'${loginData.firstName} ${loginData.lastName} (${loginData.healthCenter})\'';
          break;
        case SocketException:
          resultMessage = 'Make sure you are connected to the internet.';
          break;
        default:
          resultMessage = '$e';
      }
      // show additional warning if backup wasn't successful for a long time
      if (daysSinceLastBackup >= SHOW_WARNING_AFTER_X_DAYS) {
        showFlushBar(_context, "Last backup was $daysSinceLastBackup days ago.\nPlease perform a manual backup from the settings screen.", title: "Warning", error: true);
      }
    }
    showFlushBar(_context, resultMessage, title: title, error: error);

  }

  Widget _bodyToDisplayBasedOnState() {
    if (_isLoading) {
      return _bodyLoading();
    } else if (_patients.isEmpty) {
      return _bodyNoData();
    } else {
      return _bodyPatientTable();
    }
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
          icon: Icon(Icons.bug_report),
          onPressed: _pushDebugScreen,
        ),
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

  void _pushDebugScreen() {
    Navigator.of(_context).push(
      PageRouteBuilder<void>(
        opaque: false,
        transitionsBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2, Widget widget) {
          return FadeTransition(
            opacity: anim1,
            child: widget,
          );
        },
        pageBuilder: (BuildContext context, _, __) {
          return DebugScreen();
        },
      ),
    );
  }

  void _pushSettingsScreen() {
    Navigator.of(_context).push(
      new PageRouteBuilder<void>(
        opaque: false,
        transitionsBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2, Widget widget) {
          return FadeTransition(
            opacity: anim1,
            child: widget, // child is the value returned by pageBuilder
          );
        },
        pageBuilder: (BuildContext context, _, __) {
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
        settings: RouteSettings(name: '/patient'),
        builder: (BuildContext context) {
          return PatientScreen(patient);
        },
      ),
    );
  }

  _bodyLoading() {
    return Center(
      child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
      ),
    );
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
    const _cardMarginVertical = 5.0;
    const _cardMarginHorizontal = 10.0;
    const _rowPaddingVertical = 20.0;
    const _rowPaddingHorizontal = 15.0;
    const _cardHeight = 100.0;
    const _colorBarWidth = 15.0;

    _formatHeaderRowText(String text) {
      return Text(
        text.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
      );
    }

    _formatPatientRowText(String text, {bool isActivated: true}) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 18,
          color: isActivated ? Colors.black : Colors.grey,
        ),
      );
    }

    ClipRect _getPaddedIcon(String assetLocation, {Color color}) {
      return ClipRect(
          clipBehavior: Clip.antiAlias,
          child: SizedOverflowBox(
              size: Size(32.0, 30.0),
              child: Image(
                height: 30.0,
                color: color,
                image: AssetImage(
                    assetLocation),
              )));
    }

    Widget _buildSupportIcons(SupportPreferencesSelection sps, {bool isActivated: true}) {
      List<Widget> icons = List<Widget>();
      Color iconColor = isActivated ? Colors.black : Colors.grey;
      final Container spacer = Container(width: 3);
      if (sps == null) {
        return _formatPatientRowText('—', isActivated: isActivated);
      }
      if (sps.homeVisitPESelected) {
//        icons.add(Icon(Icons.home));
        icons.add(_getPaddedIcon('assets/icons/homevisit_pe_black.png', color: iconColor));
        icons.add(spacer);
      }
      if (sps.nurseAtClinicSelected) {
        icons.add(_getPaddedIcon('assets/icons/nurse_clinic_fett.png', color: iconColor));
        icons.add(spacer);
      }
      if (sps.saturdayClinicClubSelected) {
        icons.add(_getPaddedIcon('assets/icons/saturday_clinic_club_black.png', color: iconColor));
        icons.add(spacer);
      }
      if (sps.schoolTalkPESelected) {
//        icons.add(Icon(Icons.school));
        icons.add(_getPaddedIcon('assets/icons/schooltalk_pe_black.png', color: iconColor));
        icons.add(spacer);
      }
      if (sps.communityYouthClubSelected) {
        icons.add(_getPaddedIcon('assets/icons/youth_club_black.png', color: iconColor));
        icons.add(spacer);
      }
      if (sps.phoneCallPESelected) {
//        icons.add(Icon(Icons.phone));
        icons.add(_getPaddedIcon('assets/icons/phonecall_pe_black.png', color: iconColor));
        icons.add(spacer);
      }
      if (sps.areAllDeselected) {
        icons.add(_getPaddedIcon('assets/icons/no_support_fett.png', color: iconColor));
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
              vertical: _cardMarginVertical,
              horizontal: _cardMarginHorizontal),
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _rowPaddingHorizontal),
              child: Row(
                children: <Widget>[
                  SizedBox(width: _colorBarWidth),
                  Expanded(child: _formatHeaderRowText('ART NR.')),
                  Expanded(child: _formatHeaderRowText('NEXT REFILL')),
                  Expanded(child: _formatHeaderRowText('REFILL BY')),
                  Expanded(flex: 2, child: _formatHeaderRowText('SUPPORT')),
                  Expanded(child: _formatHeaderRowText('VIRAL LOAD')),
                  Expanded(child: _formatHeaderRowText('NEXT ASSESSMENT')),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ))),
    ];
    final numberOfPatients = _patients.length;
    for (var i = 0; i < numberOfPatients; i++) {
      final Patient curPatient = _patients[i];
      final patientART = curPatient.artNumber;

      Widget _getViralLoadIndicator({bool isActivated: true}) {
        Widget viralLoadIcon = _formatPatientRowText('—', isActivated: isActivated);
        ViralLoadBadge viralLoadBadge = ViralLoadBadge(ViralLoad.NA, smallSize: true);
        Color iconColor = isActivated ? Colors.black : Colors.grey;
        if (curPatient.vlSuppressed != null && curPatient.vlSuppressed) {
          viralLoadIcon = _getPaddedIcon('assets/icons/viralload_suppressed.png', color: iconColor);
          viralLoadBadge = ViralLoadBadge(ViralLoad.SUPPRESSED, smallSize: true); // TODO: show greyed out version if isActivated is false
        } else
        if (curPatient.vlSuppressed != null && !curPatient.vlSuppressed) {
          viralLoadIcon = _getPaddedIcon('assets/icons/viralload_unsuppressed.png', color: iconColor);
          viralLoadBadge = ViralLoadBadge(ViralLoad.UNSUPPRESSED, smallSize: true); // TODO: show greyed out version if isActivated is false
        }
        return viralLoadIcon;
//        return viralLoadBadge;
      }

      String nextRefillText = '—';
      DateTime nextARTRefillDate = curPatient.latestARTRefill?.nextRefillDate;
      if (nextARTRefillDate != null) {
        nextRefillText = formatDate(nextARTRefillDate);
      }

      String refillByText = '—';
      ARTRefillOption aro = curPatient.latestPreferenceAssessment?.artRefillOption1;
      if (aro != null) {
        refillByText = artRefillOptionToString(aro);
      }

      String nextAssessmentText = '—';
      DateTime lastAssessmentDate = curPatient.latestPreferenceAssessment?.createdDate;
      if (lastAssessmentDate != null) {
        DateTime nextAssessmentDate = calculateNextAssessment(lastAssessmentDate);
        nextAssessmentText = formatDate(nextAssessmentDate);
      }

      final _curCardMargin = EdgeInsets.symmetric(
          vertical: _cardMarginVertical,
          horizontal: _cardMarginHorizontal);

      // TODO: for final release, the patients should not be deletable. Either
      // remove the Dismissible widget (return Card directly) or map the
      // Dismissible's onDismissed callback to another function (e.g.
      // deactivating a patient)
      _patientCards.add(Dismissible(
          key: Key(curPatient.artNumber),
          confirmDismiss: (DismissDirection direction) {
            if (direction == DismissDirection.startToEnd) {
              // deactivate gesture, do not dismiss but deactivate patient
              curPatient.isActivated = !curPatient.isActivated;
              PatientBloc.instance.sinkPatientData(curPatient);
              return Future<bool>.value(false);
            }
            return Future<bool>.value(true);
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              print('removing patient with ART number ${curPatient.artNumber}');
              DatabaseProvider().deletePatient(curPatient).then((int rowsAffected) {
                showFlushBar(context, 'Removed patient ${curPatient.artNumber} ($rowsAffected rows deleted in DB)');
                _patients.removeWhere((p) => p.artNumber == curPatient.artNumber);
              });
            }
          },
          background: Container(
            margin: _curCardMargin,
            padding: EdgeInsets.symmetric(horizontal: _cardMarginHorizontal),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.black, Colors.red],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
              Text(
                curPatient.isActivated ? 'DEACTIVATE' : 'ACTIVATE',
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
          child: SizedBox(
            height: _cardHeight,
            child: Card(
            color: curPatient.isActivated ? Colors.white : Colors.grey[300],
        elevation: 5.0,
        margin: _curCardMargin,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            onTap: () {
              _pushPatientScreen(curPatient);
            },
            child: Row(
              children: [
              // color bar
              Container(width: _colorBarWidth, color: _calculateCardColor(curPatient)),
              // patient info
              Expanded(child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: _rowPaddingVertical,
                    horizontal: _rowPaddingHorizontal),
                child: Row(
                  children: <Widget>[
                    // ART Nr.
                    Expanded(child: _formatPatientRowText(patientART, isActivated: curPatient.isActivated)),
                    // Next Refill
                    Expanded(child: _formatPatientRowText(nextRefillText, isActivated: curPatient.isActivated)),
                    // Refill By
                    Expanded(child: _formatPatientRowText(refillByText, isActivated: curPatient.isActivated)),
                    // Support
                    Expanded(
                      flex: 2,
                        child: _buildSupportIcons(curPatient?.latestPreferenceAssessment?.supportPreferences, isActivated: curPatient.isActivated),
                    ),
                    // Viral Load
                    Expanded(
                        child: _getViralLoadIndicator(isActivated: curPatient.isActivated),
                    ),
                    // Next Assessment
                    Expanded(child: _formatPatientRowText(nextAssessmentText, isActivated: curPatient.isActivated)),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ))),
                ])))),
      ));
    }
    return _patientCards;
  }

  /// Returns red, orange, yellow based on urgency of next action (next ART refill or next preference assessment).
  /// Returns transparent color, if there is no urgency (next action lays more than a week in the future) or if
  /// the patient is not activated.
  /// 
  /// Assumes that the [patient.latestARTRefill] and [patient.latestPreferenceAssessment] fields are initialized.
  Color _calculateCardColor(Patient patient) {
    if (!patient.isActivated) {
      return Colors.transparent;
    }

    final DateTime dateOfNextAction = _getDateOfNextAction(patient);

    if (dateOfNextAction == null) {
      return Colors.transparent;
    }

    final int daysUntilNextAction = differenceInDays(DateTime.now(), dateOfNextAction);
    if (daysUntilNextAction <= 0) {
      return Colors.red;
    }
    if (daysUntilNextAction <= 2) {
      return Colors.orange;
    }
    if (daysUntilNextAction <= 7) {
      return Colors.yellow;
    }
    return Colors.transparent;
  }

  /// Returns the date of the next action for the given patient.
  ///
  /// Returns `null` if both `latestARTRefill.nextRefillDate` and
  /// `latestPreferenceAssessment` are null.
  DateTime _getDateOfNextAction(Patient patient) {
    DateTime nextARTRefillDate = patient.latestARTRefill?.nextRefillDate;
    DateTime nextPreferenceAssessmentDate = calculateNextAssessment(patient.latestPreferenceAssessment?.createdDate);
    return _getLesserDate(nextARTRefillDate, nextPreferenceAssessmentDate);
  }

  /// Returns the older of the two dates.
  /// 
  /// Returns `null` if both dates are `null`.
  DateTime _getLesserDate(DateTime date1, DateTime date2) {
    if (date1 == null && date2 == null) {
      return null;
    }
    if (date1 == null) {
      return date2;
    } else if (date2 == null) {
      return date1;
    } else {
      return date1.isBefore(date2) ? date1 : date2;
    }
  }

}
