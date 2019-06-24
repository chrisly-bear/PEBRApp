import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pebrapp/components/ViralLoadBadge.dart';
import 'package:pebrapp/components/animations/GrowTransition.dart';
import 'package:pebrapp/config/PEBRAConfig.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/ARTRefillOption.dart';
import 'package:pebrapp/database/beans/SupportPreferencesSelection.dart';
import 'package:pebrapp/database/models/UserData.dart';
import 'package:pebrapp/exceptions/DocumentNotFoundException.dart';
import 'package:pebrapp/exceptions/NoLoginDataException.dart';
import 'package:pebrapp/exceptions/SWITCHLoginFailedException.dart';
import 'package:pebrapp/screens/DebugScreen.dart';
import 'package:pebrapp/screens/NewPatientScreen.dart';
import 'dart:ui';

import 'package:pebrapp/screens/SettingsScreen.dart';
import 'package:pebrapp/screens/IconExplanationsScreen.dart';
import 'package:pebrapp/screens/PatientScreen.dart';
import 'package:pebrapp/components/TransparentHeaderPage.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/Utils.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  // TODO: remove _context field and pass context via args if necessary
  BuildContext _context;
  bool _isLoading = true;
  List<Patient> _patients = [];
  Stream<AppState> _appStateStream;
  bool _loginLockCheckRunning = false;
  bool _backupRunning = false;

  static const int _ANIMATION_TIME = 800; // in milliseconds
  static const double _cardHeight = 100.0;
  final Animatable<double> _cardHeightTween = Tween<double>(begin: 0, end: _cardHeight).chain(
      CurveTween(curve: Curves.ease)
  );
  Map<String, AnimationController> animationControllers = {};

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
            // make sure the animation has run
            animationControllers[newPatient.artNumber].forward();
          } else {
            // add if not exists (new patient was added)
            if (newPatient.isEligible && newPatient.consentGiven) {
              this._patients.add(newPatient);
              // add animation controller for this patient card
              final controller = AnimationController(duration: const Duration(milliseconds: _ANIMATION_TIME), vsync: this);
              animationControllers[newPatient.artNumber] = controller;
              // start animation
              controller.forward();
            }
          }
        });
      }
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
    if (patient.latestARTRefill?.nextRefillDate == null) { actionsRequired++; }
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
    switch (state) {
      case AppLifecycleState.resumed:
        print('>>>>> $state');
        _onAppResume();
        break;
      case AppLifecycleState.paused:
        print('>>>>> $state');
        if (!_loginLockCheckRunning) {
          // if the app is already locked do not update the last active date!
          // otherwise, we can work around the lock by force closing the app and
          // restarting it within the time limit
          storeAppLastActiveInSharedPrefs();
        }
        break;
      default:
        print('>>>>> UNHANDLED: $state');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('~~~ MainScreenState.build ~~~');
    _context = context;
    return Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        floatingActionButton: FloatingActionButton(
          key: Key('addPatient'), // key can be used to find the button in integration testing
          onPressed: _pushNewPatientScreen,
          child: Icon(Icons.add),
          backgroundColor: FLOATING_ACTION_BUTTON,
        ),
        body: TransparentHeaderPage(
          title: 'Patients',
          subtitle: 'Overview',
          child: Center(child: _bodyToDisplayBasedOnState()),
          actions: <Widget>[
            kReleaseMode ? SizedBox() : IconButton(icon: Icon(Icons.bug_report), onPressed: () {
              _fadeInScreen(DebugScreen());
            }),
            IconButton(
              icon: Icon(Icons.info),
              onPressed: _pushIconExplanationsScreen,
            ),
            IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                    // reset animation
                    animationControllers.values.forEach((AnimationController c) => c.reset());
                    // reload patients from SQLite database
                    PatientBloc.instance.sinkAllPatientsFromDatabase();
                  },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: _pushSettingsScreen,
            ),
          ],
        ),
    );
  }

  /// Runs checks whether user is logged in / whether the app should be locked,
  /// and whether a backup should be run simultaneously.
  ///
  /// Gets called when the application comes to the foreground or is run for the
  /// first time.
  Future<void> _onAppResume() async {
    _checkLoggedInAndLockStatus();
    _runBackupIfDue();
  }

  /// Checks whether the user is logged in (if not shows the login screen) and
  /// whether the app should be locked (if so it shows the PIN code screen).
  Future<void> _checkLoggedInAndLockStatus() async {
    // if _checkLoggedInAndLockStatus has already been called we do nothing
    if (_loginLockCheckRunning) {
      return;
    }
    // enable concurrency lock
    _loginLockCheckRunning = true;

    // make user log in if he/she isn't already
    UserData loginData = await DatabaseProvider().retrieveLatestUserData();
    if (loginData == null) {
      await _pushSettingsScreen();
      _loginLockCheckRunning = false;
      return;
    }

    // lock the app if it has been inactive for a certain time
    DateTime lastActive = await appLastActive;
    if (lastActive == null) {
      await lockApp(_context);
    } else {
      DateTime now = DateTime.now();
      Duration difference = now.difference(lastActive);
      print('Seconds since app last active: ${difference.inSeconds}');
      if (difference.inSeconds >= SECONDS_UNTIL_APP_LOCK) {
        await lockApp(_context);
      }
    }
    _loginLockCheckRunning = false;
  }

  /// Checks if a backup is due and if so, starts a backup.
  Future<void> _runBackupIfDue() async {

    // if backup is running, do not start another backup
    if (_backupRunning) {
      return;
    }
    _backupRunning = true;

    // if user is not logged in, do not run a backup
    UserData loginData = await DatabaseProvider().retrieveLatestUserData();
    if (loginData == null) {
      _backupRunning = false;
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
        _backupRunning = false;
        return; // don't run a backup, we have already backed up today
      }
    }

    String resultMessage = 'Backup Successful';
    String title;
    bool error = false;
    VoidCallback onNotificationButtonPress;
    try {
      await DatabaseProvider().createAdditionalBackupOnSWITCH(loginData);
    } catch (e, s) {
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
          resultMessage = 'No existing backup found for user \'${loginData.username}\'';
          break;
        case SocketException:
          resultMessage = 'Make sure you are connected to the internet.';
          break;
        default:
          resultMessage = 'An unknown error occured. Contact the development team.';
          print('${e.runtimeType}: $e');
          print(s);
          onNotificationButtonPress = () {
            showErrorInPopup(e, s, _context);
          };
      }
      // show additional warning if backup wasn't successful for a long time
      if (daysSinceLastBackup >= SHOW_WARNING_AFTER_X_DAYS) {
        showFlushbar("Last backup was $daysSinceLastBackup days ago.\nPlease perform a manual backup from the settings screen.", title: "Warning", error: true);
      }
    }
    showFlushbar(resultMessage, title: title, error: error, onButtonPress: onNotificationButtonPress);
    _backupRunning = false;
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

  /// Pushes [newScreen] to the top of the navigation stack using a fade in
  /// transition.
  Future<T> _fadeInScreen<T extends Object>(Widget newScreen, {String routeName}) {
    return Navigator.of(_context).push(
      PageRouteBuilder<T>(
        settings: RouteSettings(name: routeName),
        opaque: false,
        transitionsBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2, Widget widget) {
          return FadeTransition(
            opacity: anim1,
            child: widget, // child is the value returned by pageBuilder
          );
        },
        pageBuilder: (BuildContext context, _, __) {
          return newScreen;
        },
      ),
    );
  }

  Future<void> _pushSettingsScreen() async {
    await _fadeInScreen(SettingsScreen(), routeName: '/settings');
  }

  Future<void> _pushIconExplanationsScreen() async {
    await _fadeInScreen(IconExplanationsScreen(), routeName: '/icon-explanations');
  }

  Future<void> _pushNewPatientScreen() async {
    await _fadeInScreen(NewPatientScreen(), routeName: '/new-patient');
  }

  Future<void> _pushPatientScreen(Patient patient) async {
    await Navigator.of(_context).push(
      new MaterialPageRoute<void>(
        settings: RouteSettings(name: '/patient'),
        builder: (BuildContext context) {
          return PatientScreen(patient);
        },
      ),
    );
  }

  Widget _bodyLoading() {
    final double size = 80.0;
    return Container(
      padding: EdgeInsets.all(20.0),
      height: size,
      width: size,
      child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(SPINNER_MAIN_SCREEN)
      ),
    );
  }

  Widget _bodyNoData() {
    return Padding(
      padding: EdgeInsets.all(25.0),
      child: Center(
        child: Text(
          "No patients recorded yet.\nAdd new patient by pressing the + icon.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Column _bodyPatientTable() {
    return Column(
      children: _buildPatientCards(),
    );
  }

  List<Widget> _buildPatientCards() {
    const _cardMarginVertical = 8.0;
    const _cardMarginHorizontal = 10.0;
    const _rowPaddingVertical = 20.0;
    const _rowPaddingHorizontal = 15.0;
    const _colorBarWidth = 15.0;

    const double _artNumberWidth = 110.0;
    const double _nextRefillWidth = 110.0;
    const double _refillByWidth = 100.0;
    const double _supportWidth = 260.0;
    const double _viralLoadWidth = 55.0;
    const double _nextAssessmentWidth = 95.0;

    Text _formatHeaderRowText(String text) {
      return Text(
        text.toUpperCase(),
        style: TextStyle(
          color: MAIN_SCREEN_HEADER_TEXT,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    Text _formatPatientRowText(String text, {bool isActivated: true, bool highlight: false}) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 18,
          color: isActivated ? TEXT_ACTIVE : TEXT_INACTIVE,
          fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
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
      Color iconColor = isActivated ? ICON_ACTIVE : ICON_INACTIVE;
      final Container spacer = Container(width: 3);
      if (sps == null) {
        return _formatPatientRowText('—', isActivated: isActivated);
      }
      if (sps.NURSE_CLINIC_selected) {
        icons.add(_getPaddedIcon('assets/icons/nurse_clinic.png', color: iconColor));
        icons.add(spacer);
      }
      if (sps.SATURDAY_CLINIC_CLUB_selected) {
        icons.add(_getPaddedIcon('assets/icons/saturday_clinic_club.png', color: iconColor));
        icons.add(spacer);
      }
      if (sps.COMMUNITY_YOUTH_CLUB_selected) {
        icons.add(_getPaddedIcon('assets/icons/youth_club.png', color: iconColor));
        icons.add(spacer);
      }
      if (sps.PHONE_CALL_PE_selected) {
//        icons.add(Icon(Icons.phone));
        icons.add(_getPaddedIcon('assets/icons/phonecall_pe.png', color: iconColor));
        icons.add(spacer);
      }
      if (sps.HOME_VISIT_PE_selected) {
//        icons.add(Icon(Icons.home));
        icons.add(_getPaddedIcon('assets/icons/homevisit_pe.png', color: iconColor));
        icons.add(spacer);
      }
      if (sps.SCHOOL_VISIT_PE_selected) {
//        icons.add(Icon(Icons.school));
        icons.add(_getPaddedIcon('assets/icons/schooltalk_pe.png', color: iconColor));
        icons.add(spacer);
      }
      if (sps.PITSO_VISIT_PE_selected) {
        icons.add(_getPaddedIcon('assets/icons/pitso.png', color: iconColor));
        icons.add(spacer);
      }
      if (sps.areAllDeselected) {
        icons.add(_getPaddedIcon('assets/icons/no_support.png', color: iconColor));
        icons.add(spacer);
      } else if (sps.areAllWithTodoDeselected) {
        return _formatPatientRowText('—', isActivated: isActivated);
      }
      if (icons.length > 0 && icons.last == spacer) {
        // remove last spacer as there are no more icons that follow it
        icons.removeLast();
      }
      return Row(children: icons);
    }

    final Widget _headerRow = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _cardMarginHorizontal + _rowPaddingHorizontal),
        child: Row(
          children: <Widget>[
            SizedBox(width: _colorBarWidth),
            Container(
              width: _artNumberWidth,
              child: _formatHeaderRowText('ART NR.'),
            ),
            Container(
              width: _nextRefillWidth,
              child: _formatHeaderRowText('NEXT REFILL'),
            ),
            Container(
              width: _refillByWidth,
              child: _formatHeaderRowText('REFILL BY'),
            ),
            Container(
              width: _supportWidth,
              child: _formatHeaderRowText('SUPPORT'),
            ),
            Container(
              width: _viralLoadWidth,
              child: _formatHeaderRowText('VIRAL LOAD'),
            ),
            Container(
              width: _nextAssessmentWidth,
              child: _formatHeaderRowText('NEXT ASSESSMENT'),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );

    List<Widget> _patientCards = <Widget>[
      _headerRow,
    ];
    _sortPatients(_patients);
    final numberOfPatients = _patients.length;
    for (var i = 0; i < numberOfPatients; i++) {
      final Patient curPatient = _patients[i];
      final patientART = curPatient.artNumber;

      Widget _getViralLoadIndicator({bool isActivated: true}) {
        Widget viralLoadIcon = Padding(padding: EdgeInsets.only(left: 8.0), child: _formatPatientRowText('—', isActivated: isActivated));
        Widget viralLoadBadge = _formatPatientRowText('—', isActivated: isActivated);
        Color iconColor = isActivated ? null : ICON_INACTIVE;
        if (curPatient.mostRecentViralLoad?.isSuppressed != null && curPatient.mostRecentViralLoad.isSuppressed) {
          viralLoadIcon = _getPaddedIcon('assets/icons/viralload_suppressed.png', color: iconColor);
          viralLoadBadge = ViralLoadBadge(curPatient.mostRecentViralLoad, smallSize: true); // TODO: show greyed out version if isActivated is false
        } else if (curPatient.mostRecentViralLoad?.isSuppressed != null && !curPatient.mostRecentViralLoad.isSuppressed) {
          viralLoadIcon = _getPaddedIcon('assets/icons/viralload_unsuppressed.png', color: iconColor);
          viralLoadBadge = ViralLoadBadge(curPatient.mostRecentViralLoad, smallSize: true); // TODO: show greyed out version if isActivated is false
        } else if (curPatient.mostRecentViralLoad != null && curPatient.mostRecentViralLoad.isLowerThanDetectable) {
          viralLoadIcon = ViralLoadBadge(curPatient.mostRecentViralLoad, smallSize: true); // TODO: show greyed out version if isActivated is false
          viralLoadBadge = ViralLoadBadge(curPatient.mostRecentViralLoad, smallSize: true); // TODO: show greyed out version if isActivated is false
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
      ARTRefillOption aro = curPatient.latestPreferenceAssessment?.lastRefillOption;
      if (aro != null) {
        refillByText = aro.descriptionShort;
      }

      String nextAssessmentText = '—';
      DateTime lastAssessmentDate = curPatient.latestPreferenceAssessment?.createdDate;
      if (lastAssessmentDate != null) {
        DateTime nextAssessmentDate = calculateNextAssessment(lastAssessmentDate, isSuppressed(curPatient));
        nextAssessmentText = formatDate(nextAssessmentDate);
      }

      bool nextRefillTextHighlighted = false;
      bool nextAssessmentTextHighlighted = false;
      if (nextARTRefillDate == null && lastAssessmentDate != null) {
        nextAssessmentTextHighlighted = true;
      } else if (nextARTRefillDate != null && lastAssessmentDate == null) {
        nextRefillTextHighlighted = true;
      } else if (nextARTRefillDate != null && lastAssessmentDate != null) {
        DateTime nextAssessmentDate = calculateNextAssessment(lastAssessmentDate, isSuppressed(curPatient));
        if (nextAssessmentDate.isBefore(nextARTRefillDate)) {
          nextAssessmentTextHighlighted = true;
        } else if (nextARTRefillDate.isBefore(nextAssessmentDate)) {
          nextRefillTextHighlighted = true;
        } else {
          // both on the same day
          nextAssessmentTextHighlighted = true;
          nextRefillTextHighlighted = true;
        }
      }

      final _curCardMargin = EdgeInsets.symmetric(
          vertical: _cardMarginVertical,
          horizontal: _cardMarginHorizontal);

      Widget patientCard = Card(
        color: curPatient.isActivated ? CARD_ACTIVE : CARD_INACTIVE,
        elevation: 5.0,
        margin: _curCardMargin,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            _pushPatientScreen(curPatient);
          },
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // color bar
                Container(width: _colorBarWidth, color: _calculateCardColor(curPatient)),
                // patient info
                Container(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: _rowPaddingVertical,
                      horizontal: _rowPaddingHorizontal,
                    ),
                    child: Row(
                      children: <Widget>[
                        // ART Nr.
                        Container(
                          width: _artNumberWidth,
                          child: _formatPatientRowText(patientART, isActivated: curPatient.isActivated),
                        ),
                        // Next Refill
                        Container(
                          width: _nextRefillWidth,
                          child: _formatPatientRowText(nextRefillText, isActivated: curPatient.isActivated, highlight: nextRefillTextHighlighted),
                        ),
                        // Refill By
                        Container(
                          width: _refillByWidth,
                          child: _formatPatientRowText(refillByText, isActivated: curPatient.isActivated),
                        ),
                        // Support
                        Container(
                          width: _supportWidth,
                          child: _buildSupportIcons(curPatient?.latestPreferenceAssessment?.supportPreferences, isActivated: curPatient.isActivated),
                        ),
                        // Viral Load
                        Container(
                          width: _viralLoadWidth,
                          child: Container(alignment: Alignment.centerLeft, child: _getViralLoadIndicator(isActivated: curPatient.isActivated)),
                        ),
                        // Next Assessment
                        Container(
                          width: _nextAssessmentWidth,
                          child: _formatPatientRowText(nextAssessmentText, isActivated: curPatient.isActivated, highlight: nextAssessmentTextHighlighted),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // in debug mode:
      // make patient activate/deactivate on right swipe,
      // delete patient on left swipe
      if (!kReleaseMode) {
        patientCard = Dismissible(
          direction: DismissDirection.horizontal,
          key: Key(curPatient.artNumber),
          confirmDismiss: (DismissDirection direction) async {
            final AnimationController controller = animationControllers[curPatient.artNumber];
            final originalAnimationDuration = controller.duration;
            final Duration _quickAnimationDuration = Duration(milliseconds: (_ANIMATION_TIME / 2).round());
            controller.duration = _quickAnimationDuration;
            if (direction == DismissDirection.startToEnd) {
              // *****************************
              // activate / deactivate patient
              // *****************************
              curPatient.isActivated = !curPatient.isActivated;
              DatabaseProvider().insertPatient(curPatient);
              await controller.animateBack(0.0, duration: _quickAnimationDuration, curve: Curves.ease); // fold patient card up
              setState(() {}); // re-render the patient card (grey it out / un-grey it and sort it at the right position in the table)
              // TODO: the next line will throw an error because setState rebuilt the screen in the previous line, which means the controller got disposed (everything still works as expected though)
              await controller.forward(); // unfold patient card
              controller.duration = originalAnimationDuration; // reset animation duration
              return Future<bool>.value(false);
            } else if (direction == DismissDirection.endToStart) {
              // **************
              // delete patient
              // **************
              DatabaseProvider().deletePatient(curPatient);
              _patients.removeWhere((Patient p) => p.artNumber == curPatient.artNumber);
              await controller.animateBack(0.0, duration: _quickAnimationDuration, curve: Curves.ease); // fold patient card up
              controller.duration = originalAnimationDuration; // reset animation duration
              return Future<bool>.value(true);
            }
          },
          background: Container(
            margin: _curCardMargin,
            padding: EdgeInsets.symmetric(horizontal: _cardMarginHorizontal),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [MAIN_SCREEN_SLIDE_TO_ACTIVATE, MAIN_SCREEN_SLIDE_TO_DELETE])),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  curPatient.isActivated ? 'DEACTIVATE' : 'ACTIVATE',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: MAIN_SCREEN_SLIDE_TO_ACTIVATE_TEXT,
                  ),
                ),
                Text(
                  'DELETE',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: MAIN_SCREEN_SLIDE_TO_ACTIVATE_TEXT,
                  ),
                ),
              ],
            ),
          ),
          child: patientCard,
        );
      }
      // in release mode:
      // wrap in Dismissible, so that patient can be
      // re-activated using a right-swipe (only if patient is deactivated)
      else if (!curPatient.isActivated) {
        patientCard = Dismissible(
          direction: DismissDirection.startToEnd,
          key: Key(curPatient.artNumber),
          confirmDismiss: (DismissDirection direction) async {
            // ****************
            // activate patient
            // ****************
            final AnimationController controller = animationControllers[curPatient.artNumber];
            final originalAnimationDuration = controller.duration;
            final Duration _quickAnimationDuration = Duration(milliseconds: (_ANIMATION_TIME / 2).round());
            controller.duration = _quickAnimationDuration;
            curPatient.isActivated = !curPatient.isActivated;
            DatabaseProvider().insertPatient(curPatient);
            await controller.animateBack(0.0, duration: _quickAnimationDuration, curve: Curves.ease); // fold patient card up
            setState(() {}); // re-render the patient card (un-grey it and sort it at the right position in the table)
            // TODO: the next line will throw an error because setState rebuilt the screen in the previous line, which means the controller got disposed (everything still works as expected though)
            await controller.forward(); // unfold patient card
            controller.duration = originalAnimationDuration; // reset animation duration
            return Future<bool>.value(false); // do not remove patient card from list
          },
          background: Container(
            margin: _curCardMargin,
            padding: EdgeInsets.symmetric(horizontal: _cardMarginHorizontal),
            color: MAIN_SCREEN_SLIDE_TO_ACTIVATE,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  curPatient.isActivated ? 'DEACTIVATE' : 'ACTIVATE',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: MAIN_SCREEN_SLIDE_TO_ACTIVATE_TEXT,
                  ),
                ),
              ],
            ),
          ),
          child: patientCard,
        );
      }

      // wrap in stack to display action required label
      final int numOfActionsRequired = curPatient.requiredActions.length;
      if (curPatient.isActivated && numOfActionsRequired > 0) {

        final double badgeSize = 30.0;
        final List<Widget> badges = [];
        for (int i = 0; i < numOfActionsRequired; i++) {
          badges.add(
            Hero(
              tag: "RequiredAction_${curPatient.artNumber}_$i",
              child: Padding(
                padding: EdgeInsets.only(right: 3.0),
                child: Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: i == 0 ? Colors.black45 : Colors.transparent,
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${i+1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Roboto',
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        patientCard = Stack(
          alignment: Alignment.topRight,
          children: <Widget>[
            patientCard,
            ...badges,
          ],
        );
      }

      // animate patient card when loading
      patientCard = GrowTransition(
          animation: _cardHeightTween.animate(animationControllers[curPatient.artNumber]),
          child: patientCard
      );

      _patientCards.add(patientCard);
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
      return URGENCY_HIGH;
    }
    if (daysUntilNextAction <= 2) {
      return URGENCY_MEDIUM;
    }
    if (daysUntilNextAction <= 7) {
      return URGENCY_LOW;
    }
    return Colors.transparent;
  }

  /// Returns the date of the next action for the given patient.
  ///
  /// Returns `null` if both `latestARTRefill.nextRefillDate` and
  /// `latestPreferenceAssessment` are null.
  DateTime _getDateOfNextAction(Patient patient) {
    DateTime nextARTRefillDate = patient.latestARTRefill?.nextRefillDate;
    DateTime nextPreferenceAssessmentDate = calculateNextAssessment(patient.latestPreferenceAssessment?.createdDate, isSuppressed(patient));
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
