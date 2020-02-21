import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonFlat.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PEBRAppBottomSheet.dart';
import 'package:pebrapp/components/RequiredActionBadge.dart';
import 'package:pebrapp/components/ViralLoadBadge.dart';
import 'package:pebrapp/components/animations/GrowTransition.dart';
import 'package:pebrapp/config/PEBRAConfig.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/ARTRefillOption.dart';
import 'package:pebrapp/database/beans/SupportPreferencesSelection.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
import 'package:pebrapp/database/models/UserData.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
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
import 'package:pebrapp/utils/VisibleImpactUtils.dart';

class MainScreen extends StatefulWidget {
  bool _isScreenLogged = false;
  MainScreen(this._isScreenLogged);
  @override
  State<StatefulWidget> createState() => _MainScreenState(_isScreenLogged);
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  // TODO: remove _context field and pass context via args if necessary
  BuildContext _context;
  bool _isLoading = true;
  bool _patientScreenPushed = false;
  List<Patient> _patients = [];
  UserData _userData = UserData();
  bool _isLoadingUserData = true;
  StreamSubscription<AppState> _appStateStream;
  bool _loginLockCheckRunning = false;
  bool _backupRunning = false;
  bool _vlFetchRunning = false;
  bool _settingsActionRequired = false;

  static const int _ANIMATION_TIME = 800; // in milliseconds
  static const double _cardHeight = 100.0;
  final Animatable<double> _cardHeightTween = Tween<double>(begin: 0, end: _cardHeight).chain(
      CurveTween(curve: Curves.ease)
  );
  Map<String, AnimationController> animationControllers = {};
  Map<String, bool> shouldAnimateRequiredActionBadge = {};
  bool shouldAnimateSettingsActionRequired = true;

  // constructor 2
  _MainScreenState(this._loginLockCheckRunning);

  @override
  void initState() {
    super.initState();
    print('~~~ MainScreenState.initState ~~~');
    // listen to changes in the app lifecycle
    WidgetsBinding.instance.addObserver(this);
    DatabaseProvider().retrieveLatestUserData().then((UserData user) {
      if (user != null) {
        setState(() {
          this._userData = user;
          this._settingsActionRequired = user.phoneNumberUploadRequired;
          this._isLoadingUserData = false;
        });
      }
    });
    _onAppStart();

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
    _appStateStream = PatientBloc.instance.appState.listen( (streamEvent) {
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
      if (streamEvent is AppStateRequiredActionData) {
        print('*** MainScreen received AppStateRequiredActionData: ${streamEvent.action.patientART} ***');
        Patient affectedPatient = _patients.singleWhere((Patient p) => p.artNumber == streamEvent.action.patientART, orElse: () => null);
        if (affectedPatient != null && !_patientScreenPushed) {
          setState(() {
            if (streamEvent.isDone) {
              shouldAnimateRequiredActionBadge[affectedPatient.artNumber] = true;
              affectedPatient.requiredActions.removeWhere((RequiredAction a) => a.type == streamEvent.action.type);
            } else {
              if (affectedPatient.requiredActions.firstWhere((RequiredAction a) => a.type == streamEvent.action.type, orElse: () => null) == null) {
                shouldAnimateRequiredActionBadge[affectedPatient.artNumber] = true;
                affectedPatient.requiredActions.add(streamEvent.action);
              }
            }
          });
        }
      }
      if (streamEvent is AppStateSettingsRequiredActionData) {
        print('*** MainScreen received AppStateSettingsRequiredActionData: ${streamEvent.isDone} ***');
        this.shouldAnimateSettingsActionRequired = true;
        setState(() {
          this._settingsActionRequired = !streamEvent.isDone;
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
  /// - patients with earlier created date before patients with later created
  ///   date
  void _sortPatients(List<Patient> patients) {
    patients.sort((Patient a, Patient b) {
      if (a.isActivated && !b.isActivated) { return -1; }
      if (!a.isActivated && b.isActivated) { return 1; } // do we need this rule or is it implied by the previous rule?
      final DateTime dateOfNextActionA = _getDateOfNextAction(a);
      final DateTime dateOfNextActionB = _getDateOfNextAction(b);
      if (dateOfNextActionA == null && dateOfNextActionB != null) {
        return -1;
      }
      if (dateOfNextActionA != null && dateOfNextActionB == null) {
        return 1;
      }
      if (dateOfNextActionA != null && dateOfNextActionB != null && !dateOfNextActionA.isAtSameMomentAs(dateOfNextActionB)) {
        return dateOfNextActionA.isBefore(dateOfNextActionB) ? -1 : 1;
      }
      return a.createdDate.isBefore(b.createdDate) ? 1 : -1;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appStateStream.cancel();
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
        bottomSheet: PEBRAppBottomSheet(),
        backgroundColor: BACKGROUND_COLOR,
        floatingActionButton: FloatingActionButton(
          key: Key('addPatient'), // key can be used to find the button in integration testing
          onPressed: _pushNewPatientScreen,
          child: Icon(Icons.add),
          backgroundColor: FLOATING_ACTION_BUTTON,
        ),
        body: TransparentHeaderPage(
          title: 'Participants',
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
              icon: _settingsActionRequired
                  ? Stack(
                  alignment: AlignmentDirectional(2.2, 1.8),
                  children: [
                    Icon(Icons.settings),
                    RequiredActionBadge(
                      '1',
                      animate: shouldAnimateSettingsActionRequired,
                      badgeSize: 16.0,
                      boxShadow: [BoxShadow(
                        color: BACKGROUND_COLOR,
                        blurRadius: 0.0,
                        spreadRadius: 1.0,
                      )],
                      onAnimateComplete: () {
                        this.shouldAnimateSettingsActionRequired = false;
                      },
                    ),
                  ])
                  : Icon(Icons.settings),
              onPressed: _pushSettingsScreen,
            ),
          ],
        ),
    );
  }

  /// Runs checks whether user is logged in / whether the app should be locked,
  /// and whether a backup should be run simultaneously.
  ///
  /// Gets called when the application is started cold, i.e., when the app was
  /// not open in the background already.
  Future<void> _onAppStart() async {
    await _checkLoggedInAndLockStatus();
    await _runVLFetchIfDue();
    await _runBackupIfDue();
  }

  /// Runs checks whether user is logged in / whether the app should be locked,
  /// and whether a backup should be run simultaneously. It also rebuilds the
  /// screen to update any changes to required actions, i.e., to check if any
  /// ART refills, preference assessments, or endpoint surveys have become due.
  ///
  /// Gets called when the application was already open in the background and
  /// comes to the foreground again.
  Future<void> _onAppResume() async {
    await _checkLoggedInAndLockStatus();
    await _runVLFetchIfDue();
    await _recalculateRequiredActionsForAllPatients();
    await _runBackupIfDue();
  }

  /// Checks if an ART refill, preference assessment, or endpoint survey has
  /// become due by re-calculating the required actions field for each patient.
  /// It send an [PatientBloc.AppStatePatientData] event for each patient to
  /// inform all listeners of the new data.
  Future<void> _recalculateRequiredActionsForAllPatients() async {
    for (Patient p in _patients) {
      final Set<RequiredAction> previousActions = p.dueRequiredActionsAtInitialization;
      await p.initializeRequiredActionsField();
      final Set<RequiredAction> newActions = p.calculateDueRequiredActions();
      final bool shouldAnimate = previousActions.length != newActions.length;
      if (shouldAnimate) {
        shouldAnimateRequiredActionBadge[p.artNumber] = shouldAnimate;
        PatientBloc.instance.sinkNewPatientData(p, oldRequiredActions: previousActions);
      }
    }
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

    try {
      await DatabaseProvider().createAdditionalBackupOnServer(loginData);
      showFlushbar('Upload Successful');
    } catch (e, s) {
      print('Caught exception during automated backup: $e');
      print('Stacktrace: $s');
      // show warning if backup wasn't successful for a long time
      if (daysSinceLastBackup >= SHOW_BACKUP_WARNING_AFTER_X_DAYS) {
        showFlushbar("Last upload was $daysSinceLastBackup days ago.\nPlease perform a manual upload from the settings screen.", title: "Warning", error: true);
      }
    }
    _backupRunning = false;
  }

  /// Checks if a viral load fetch is due and if so, starts fetching viral loads
  /// from VisibleImpact.
  Future<void> _runVLFetchIfDue() async {

    // if fetch is running, do not start another fetch
    if (_vlFetchRunning) {
      return;
    }
    _vlFetchRunning = true;

    // if user is not logged in, do not run a fetch
    UserData loginData = await DatabaseProvider().retrieveLatestUserData();
    if (loginData == null) {
      _vlFetchRunning = false;
      return;
    }

    final List<Patient> allPatients = await DatabaseProvider().retrieveLatestPatients(retrieveNonEligibles: false, retrieveNonConsents: false);
    final List<Patient> patientsToUpdate = [];
    final Map<String, int> patientsNotUpdatedForTooLong = {};
    for (Patient patient in allPatients) {
      // check if fetch is due
      int daysSinceLastFetch = -1; // -1 means one day from today, i.e. tomorrow
      final DateTime lastFetch = await getLatestViralLoadFetchFromSharedPrefs(patient.artNumber);
      if (lastFetch != null) {
        daysSinceLastFetch = differenceInDays(lastFetch, DateTime.now());
        print('days since last vl fetch (${patient.artNumber}): $daysSinceLastFetch');
        if (daysSinceLastFetch < AUTO_VL_FETCH_EVERY_X_DAYS && daysSinceLastFetch >= 0) {
          print("fetch not due yet (only due after $AUTO_VL_FETCH_EVERY_X_DAYS days)");
        } else {
          patientsToUpdate.add(patient);
        }
        if (daysSinceLastFetch >= SHOW_VL_FETCH_WARNING_AFTER_X_DAYS) {
          patientsNotUpdatedForTooLong[patient.artNumber] = daysSinceLastFetch;
        }
      } else {
        patientsToUpdate.add(patient);
        patientsNotUpdatedForTooLong[patient.artNumber] = daysSinceLastFetch;
      }
    }

    if (patientsToUpdate.isEmpty) {
      _vlFetchRunning = false;
      return; // don't run a fetch, no patients require a fetch
    }

    List<ViralLoad> viralLoadsFromDB;
    int newEntries = 0;
    Map<String, int> updatedPatients = {};
    try {
      for (Patient patient in patientsToUpdate) {
        // TODO: move the try-catch block inside this for loop so that if the
        //  download fails for one patient the loop continues and viral loads
        //  for the remaining patients can still be downloaded
        viralLoadsFromDB = await downloadViralLoadsFromDatabase(patient);
        final DateTime fetchedDate = DateTime.now();
        for (ViralLoad vl in viralLoadsFromDB) {
          await DatabaseProvider().insertViralLoad(vl, createdDate: fetchedDate);
        }
        final Patient patientObj = _patients.firstWhere((Patient p) => p.artNumber == patient.artNumber, orElse: () => null);
        if (patientObj != null) {
          // update the patient objects from the main screen
          final int oldEntries = patientObj.viralLoads.length;
          patientObj.addViralLoads(viralLoadsFromDB);
          final int newEntriesForPatient = patientObj.viralLoads.length - oldEntries;
          newEntries += newEntriesForPatient;
          if (newEntriesForPatient > 0) {
            updatedPatients[patient.artNumber] = newEntriesForPatient;
          }
          await storeLatestViralLoadFetchInSharedPrefs(patient.artNumber);
          patientsNotUpdatedForTooLong.remove(patient); // update for this patient was successful, do not show it to be overdue
          final bool discrepancyFound = await checkForViralLoadDiscrepancies(patientObj);
        }
      }
      String message = 'No new viral loads found.';
      if (newEntries > 0) {
        message = '$newEntries new viral load result${newEntries > 1 ? 's' : ''} found for participants:\n${updatedPatients.map((String patientART, int newVLs) {
          return MapEntry(patientART, '\n$patientART ($newVLs)');
        }).values.join('')}';
      }
      showFlushbar(message, title: 'Viral Loads Fetched', duration: newEntries > 0 ? Duration(seconds: 10) : null);
    } catch (e, s) {
      print('Caught exception during automated viral load fetch: $e');
      print('Stacktrace: $s');
      // show warning if viral load fetch wasn't successful for a long time
      if (patientsNotUpdatedForTooLong.isNotEmpty) {
        final String vlFetchOverdueMessage = "The last viral load update for the following participant${patientsNotUpdatedForTooLong.length > 1 ? 's' : ''} dates back $SHOW_VL_FETCH_WARNING_AFTER_X_DAYS days or more:\n${patientsNotUpdatedForTooLong.map((String patientART, int lastFetch) {
          return MapEntry(patientART, '\n$patientART (${lastFetch < 0 ? 'never' : '$lastFetch days ago'})');
        }).values.join('')}\n\nYou can fetch the latest viral loads from ${patientsNotUpdatedForTooLong.length > 1 ? 'each' : 'the'} participant's detail page.";
        showFlushbar(vlFetchOverdueMessage, title: "Warning", error: true);
      }
    }
    setState(() {}); // set state to update the viral load icons
    _vlFetchRunning = false;
  }

  Widget _bodyToDisplayBasedOnState() {
    if (_isLoadingUserData) {
      return _bodyLoading();
    } else if (_isLoading) {
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
    _patientScreenPushed = true;
    await Navigator.of(_context, rootNavigator: true).push(
      new MaterialPageRoute<void>(
        settings: RouteSettings(name: '/patient'),
        builder: (BuildContext context) {
          return PatientScreen(patient);
        },
      ),
    );
    _patientScreenPushed = false;
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
          "No participants recorded yet.\nAdd new participant by pressing the + icon.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildEmptyBox() {
    return SizedBox.shrink();
  }

  Widget _bodyPatientTable() {
    final double _paddingHorizontal = 10.0;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(
        left: _paddingHorizontal,
        right: _paddingHorizontal,
        bottom: 10.0,
      ),
      child: Column(
        children: _buildPatientCards(),
      ),
    );
  }

  List<Widget> _buildPatientCards() {
    const _cardMarginVertical = 8.0;
    const _cardMarginHorizontal = 0.0;
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

    ClipRect _getPaddedSupportIcon(String assetLocation, {bool active: true}) {
      final Color iconColor = active ? ICON_ACTIVE : ICON_INACTIVE;
      return _getPaddedIcon(assetLocation, color: iconColor);
    }

    Widget _buildSupportIcons(PreferenceAssessment pa, {bool isActivated: true}) {
      if (pa == null) {
        return _formatPatientRowText('—', isActivated: isActivated);
      }
      final SupportPreferencesSelection sps = pa.supportPreferences;
      List<Widget> icons = List<Widget>();
      final Container spacer = Container(width: 3);
      if (sps.NURSE_CLINIC_selected) {
        final icon = [_getPaddedSupportIcon('assets/icons/nurse_clinic.png', active: isActivated && !pa.NURSE_CLINIC_done), spacer];
        pa.NURSE_CLINIC_done ? icons.addAll(icon) : icons.insertAll(0, icon);
      }
      if (sps.SATURDAY_CLINIC_CLUB_selected && pa.saturdayClinicClubAvailable) {
        final icon = [_getPaddedSupportIcon('assets/icons/saturday_clinic_club.png', active: isActivated && !pa.SATURDAY_CLINIC_CLUB_done), spacer];
        pa.SATURDAY_CLINIC_CLUB_done ? icons.addAll(icon) : icons.insertAll(0, icon);
      }
      if (sps.COMMUNITY_YOUTH_CLUB_selected && pa.communityYouthClubAvailable) {
        final icon = [_getPaddedSupportIcon('assets/icons/youth_club.png', active: isActivated && !pa.COMMUNITY_YOUTH_CLUB_done), spacer];
        pa.COMMUNITY_YOUTH_CLUB_done ? icons.addAll(icon) : icons.insertAll(0, icon);
      }
      if (sps.PHONE_CALL_PE_selected) {
        final icon = [_getPaddedSupportIcon('assets/icons/phonecall_pe.png', active: isActivated && !pa.PHONE_CALL_PE_done), spacer];
        pa.PHONE_CALL_PE_done ? icons.addAll(icon) : icons.insertAll(0, icon);
      }
      if (sps.HOME_VISIT_PE_selected && pa.homeVisitPEPossible) {
        final icon = [_getPaddedSupportIcon('assets/icons/homevisit_pe.png', active: isActivated && !pa.HOME_VISIT_PE_done), spacer];
        pa.HOME_VISIT_PE_done ? icons.addAll(icon) : icons.insertAll(0, icon);
      }
      if (sps.SCHOOL_VISIT_PE_selected && pa.schoolVisitPEPossible) {
        final icon = [_getPaddedSupportIcon('assets/icons/schooltalk_pe.png', active: isActivated && !pa.SCHOOL_VISIT_PE_done), spacer];
        pa.SCHOOL_VISIT_PE_done ? icons.addAll(icon) : icons.insertAll(0, icon);
      }
      if (sps.PITSO_VISIT_PE_selected && pa.pitsoPEPossible) {
        final icon = [_getPaddedSupportIcon('assets/icons/pitso.png', active: isActivated && !pa.PITSO_VISIT_PE_done), spacer];
        pa.PITSO_VISIT_PE_done ? icons.addAll(icon) : icons.insertAll(0, icon);
      }
      if (sps.areAllDeselected) {
        icons.add(_getPaddedSupportIcon('assets/icons/no_support.png', active: isActivated));
        icons.add(spacer);
      } if (icons.isEmpty) {
        // indicate with '…' that options were selected which do not have an icon
        return _formatPatientRowText('…', isActivated: isActivated);
      }
      if (icons.length > 0 && icons.last == spacer) {
        // remove last spacer as there are no more icons that follow it
        icons.removeLast();
      }
      return Row(children: icons);
    }

    Widget _buildEmptyBox() {
      return SizedBox.shrink();
    }

    final Widget _headerRow = Padding(
      padding: EdgeInsets.symmetric(horizontal: _cardMarginHorizontal + _rowPaddingHorizontal),
      child: Row(
        children: <Widget>[
          SizedBox(width: _colorBarWidth),
          Container(
            width: _artNumberWidth,
            child: _formatHeaderRowText('ART NR.'),
          ),
          _userData.healthCenter.studyArm == 2 ? _buildEmptyBox() : Container(
            width: _nextRefillWidth,
            child: _formatHeaderRowText('NEXT REFILL'),
          ),
          _userData.healthCenter.studyArm == 1 ? _buildEmptyBox() : Container(
            width: _refillByWidth,
            child: _formatHeaderRowText('       '),
          ),
          _userData.healthCenter.studyArm == 2 ? _buildEmptyBox() : Container(
            width: _refillByWidth,
            child: _formatHeaderRowText('REFILL BY'),
          ),
          _userData.healthCenter.studyArm == 2 ? _buildEmptyBox() : Container(
            width: _supportWidth,
            child: _formatHeaderRowText('SUPPORT'),
          ),
          Container(
            width: _viralLoadWidth,
            child: _formatHeaderRowText('VIRAL LOAD'),
          ),
          _userData.healthCenter.studyArm == 2 ? _buildEmptyBox() : Container(
            width: _nextAssessmentWidth,
            child: _formatHeaderRowText('NEXT ASSESSMENT'),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        if (curPatient.mostRecentViralLoad?.failed != null && curPatient.mostRecentViralLoad.failed) {
          viralLoadIcon = _getPaddedIcon('assets/icons/viralload_failed.png', color: iconColor);
        } else if (curPatient.mostRecentViralLoad?.isSuppressed != null && curPatient.mostRecentViralLoad.isSuppressed) {
          viralLoadIcon = _getPaddedIcon('assets/icons/viralload_suppressed.png', color: iconColor);
          viralLoadBadge = ViralLoadBadge(curPatient.mostRecentViralLoad, smallSize: true); // TODO: show greyed out version if isActivated is false
        } else if (curPatient.mostRecentViralLoad?.isSuppressed != null && !curPatient.mostRecentViralLoad.isSuppressed) {
          viralLoadIcon = _getPaddedIcon('assets/icons/viralload_unsuppressed.png', color: iconColor);
          viralLoadBadge = ViralLoadBadge(curPatient.mostRecentViralLoad, smallSize: true); // TODO: show greyed out version if isActivated is false
        }
        return viralLoadIcon;
//        return viralLoadBadge;
      }

      String nextRefillText = '—';
      DateTime nextARTRefillDate = curPatient.latestDoneARTRefill?.nextRefillDate ?? curPatient.enrollmentDate;
      nextRefillText = formatDate(nextARTRefillDate);

      String refillByText = '—';
      ARTRefillOption aro = curPatient.latestPreferenceAssessment?.lastRefillOption;
      if (aro != null) {
        refillByText = aro.descriptionShort;
      }

      String nextAssessmentText = '—';
      DateTime lastAssessmentDate = curPatient.latestPreferenceAssessment?.createdDate;
      DateTime nextAssessmentDate = calculateNextAssessment(lastAssessmentDate, isSuppressed(curPatient)) ?? curPatient.enrollmentDate;
      nextAssessmentText = formatDate(nextAssessmentDate);

      bool nextRefillTextHighlighted = false;
      bool nextAssessmentTextHighlighted = false;
      if (nextAssessmentDate.isBefore(nextARTRefillDate)) {
        nextAssessmentTextHighlighted = true;
      } else if (nextARTRefillDate.isBefore(nextAssessmentDate)) {
        nextRefillTextHighlighted = true;
      } else {
        // both on the same day
        nextAssessmentTextHighlighted = true;
        nextRefillTextHighlighted = true;
      }

      final _curCardMargin = EdgeInsets.symmetric(
          vertical: _cardMarginVertical,
          horizontal: _cardMarginHorizontal);

      void _showAlertDialogToActivatePatient() {
        final AnimationController controller = animationControllers[curPatient.artNumber];
        final originalAnimationDuration = controller.duration;
        final Duration _quickAnimationDuration = Duration(milliseconds: (_ANIMATION_TIME / 2).round());
        controller.duration = _quickAnimationDuration;
        showDialog(
          context: _context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(curPatient.artNumber),
            backgroundColor: BACKGROUND_COLOR,
            content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 180.0,
                    child: PEBRAButtonRaised(
                      curPatient.isActivated ? 'Deactivate Participant' : 'Activate Participant',
                      onPressed: () async {
                        Navigator.of(context).pop();
                        // *****************************
                        // activate / deactivate patient
                        // *****************************
                        if (!curPatient.isActivated) {
                          var uploadPatientStatus = await uploadPatientStatusVisibleImpact(curPatient, 'active');
                          print(uploadPatientStatus);
                        }
                        curPatient.isActivated = !curPatient.isActivated;
                        DatabaseProvider().insertPatient(curPatient);
                        await controller.animateBack(0.0, duration: _quickAnimationDuration, curve: Curves.ease); // fold patient card up
                        setState(() {}); // re-render the patient card (grey it out / un-grey it and sort it at the right position in the table)
                        await controller.forward(); // unfold patient card
                        controller.duration = originalAnimationDuration; // reset animation duration
                      },
                    ),
                  ),
                  SizedBox(height: kReleaseMode ? 0.0 : 10.0),
                  kReleaseMode ? SizedBox() : SizedBox(
                    width: 180.0,
                    child: PEBRAButtonRaised(
                      'Delete Participant',
                      onPressed: () async {
                        // **************
                        // delete patient
                        // **************
                        Navigator.of(context).pop();
                        DatabaseProvider().deletePatient(curPatient);
                        _patients.removeWhere((Patient p) => p.artNumber == curPatient.artNumber);
                        await controller.animateBack(0.0, duration: _quickAnimationDuration, curve: Curves.ease); // fold patient card up
                        controller.duration = originalAnimationDuration; // reset animation duration
                      },
                    ),
                  ),
                  SizedBox(height: 15.0),
                  PEBRAButtonFlat(
                    'Close',
                    onPressed: () { Navigator.of(context).pop(); },
                  ),
                ]),
          ),
        );
      }

      Widget patientCard = Card(
        color: curPatient.isActivated ? CARD_ACTIVE : CARD_INACTIVE,
        elevation: 5.0,
        margin: _curCardMargin,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            _pushPatientScreen(curPatient);
          },
          onLongPress: (kReleaseMode && curPatient.isActivated) ? null : _showAlertDialogToActivatePatient,
          child: Row(
            children: [
              // color bar
              _userData.healthCenter.studyArm == 2 ? _buildEmptyBox() : Container(width: _colorBarWidth, color: _calculateCardColor(curPatient)),
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
                      _userData.healthCenter.studyArm == 2 ? _buildEmptyBox() : Container(
                        width: _nextRefillWidth,
                        child: _formatPatientRowText(nextRefillText, isActivated: curPatient.isActivated, highlight: nextRefillTextHighlighted),
                      ),
                      // Empty Cell
                      _userData.healthCenter.studyArm == 1 ? _buildEmptyBox()  : Container(
                        width: _refillByWidth,
                        child: _formatPatientRowText(" ", isActivated: curPatient.isActivated),
                      ),
                      // Refill By
                      _userData.healthCenter.studyArm == 2 ? _buildEmptyBox()  : Container(
                        width: _refillByWidth,
                        child: _formatPatientRowText(refillByText, isActivated: curPatient.isActivated),
                      ),
                      // Support
                      _userData.healthCenter.studyArm == 2 ? _buildEmptyBox() : Container(
                        width: _supportWidth,
                        child: _buildSupportIcons(curPatient?.latestPreferenceAssessment, isActivated: curPatient.isActivated),
                      ),
                      // Viral Load
                      Container(
                        width: _viralLoadWidth,
                        child: Container(alignment: Alignment.centerLeft, child: _getViralLoadIndicator(isActivated: curPatient.isActivated)),
                      ),
                      // Next Assessment
                      _userData.healthCenter.studyArm == 2 ? _buildEmptyBox() : Container(
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
      );

      // wrap in stack to display action required label
      final int numOfActionsRequired = curPatient.calculateDueRequiredActions(userData : _userData).length;
      if (curPatient.isActivated && numOfActionsRequired > 0) {
        final List<Widget> badges = [];
        for (int i = 0; i < numOfActionsRequired; i++) {
          final bool shouldAnimateBadge = shouldAnimateRequiredActionBadge[curPatient.artNumber] ?? false;
          badges.add(
            Hero(
              tag: "RequiredAction_${curPatient.artNumber}_$i",
              child: RequiredActionBadge(
                '${i+1}',
                animate: shouldAnimateBadge,
              ),
            ),
          );
        }
        shouldAnimateRequiredActionBadge[curPatient.artNumber] = false;

        patientCard = Stack(
          alignment: AlignmentDirectional(1.025, -1.0),
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
    if (daysUntilNextAction <= 1) {
      return URGENCY_HIGH;
    }
    if (daysUntilNextAction <= 3) {
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
    DateTime nextARTRefillDate = patient.latestDoneARTRefill?.nextRefillDate ?? patient.enrollmentDate;
    DateTime nextPreferenceAssessmentDate = calculateNextAssessment(patient.latestPreferenceAssessment?.createdDate, isSuppressed(patient)) ?? patient.enrollmentDate;
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
