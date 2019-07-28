import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:pebrapp/config/SharedPreferencesConfig.dart';
import 'package:intl/intl.dart';
import 'package:pebrapp/database/beans/ViralLoadSource.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/main.dart';
import 'package:pebrapp/screens/LockScreen.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:password/password.dart';
import 'package:flushbar/flushbar_route.dart' as route;


/// Displays a notification over the given [context].
///
/// @param [message] The message to display.
///
/// @param [title] An optional title to display.
///
/// @param [error] If this is `true` then the notification will be displayed in red and will stay on screen (see also [stay]).
///
/// @param [onButtonPress] Required if a button should be displayed. This function will be executed when the button is pressed.
///
/// @param [buttonText] Optional button text to be displayed on the button. If this is null or the empty string an info icon will be displayed instead.
///
/// @param [stay] Whether the notification should stay on screen. If false then
/// it will disappear automatically after 5 seconds. If [error] is true, the
/// notification will stay on screen, no matter what the value of [stay] is.
///
/// @param [duration] How long the notification should stay before disappearing. Default is 5 seconds.
Future<void> showFlushbar(String message, {String title, bool error=false, VoidCallback onButtonPress, String buttonText, bool stay: false, Duration duration}) {

  final context = PEBRAppState.rootContext;

  FlatButton button;
  if (onButtonPress != null) {
    button = FlatButton(
      onPressed: onButtonPress,
      child: buttonText == null || buttonText == ''
          ? Icon(Icons.info, color: NOTIFICATION_INFO_ICON)
          : Text(buttonText.toUpperCase(), style: TextStyle(color: NOTIFICATION_INFO_TEXT)),
    );
  }

  // define the maximum width of the notification
  const double MAX_WIDTH = 600;
  const double MIN_PADDING_HORIZONTAL = 10;
  final double screenWidth = MediaQuery.of(context).size.width;
  final double padding = max(MIN_PADDING_HORIZONTAL, (screenWidth - MAX_WIDTH)/2);

  final Flushbar _flushbar = Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    titleText: title == null ? null : Text(title,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: NOTIFICATION_MESSAGE_TEXT,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    messageText: Text(
      message, textAlign: TextAlign.center,
      style: TextStyle(
        color: NOTIFICATION_MESSAGE_TEXT,
        fontSize: title == null ? 18.0 : 16.0,
      ),
    ),
    mainButton: button,
    boxShadows: [BoxShadow(color: NOTIFICATION_SHADOW, blurRadius: 5.0, offset: Offset(0.0, 0.0), spreadRadius: 0.0)],
    borderRadius: 5,
    backgroundColor: error ? NOTIFICATION_ERROR : NOTIFICATION_NORMAL,
    margin: EdgeInsets.symmetric(horizontal: padding),
    duration: (error || stay) ? null : duration ?? Duration(seconds: 5),
  );

  final _route = route.showFlushbar(
    context: context,
    flushbar: _flushbar,
  );

  return Navigator.of(context, rootNavigator: true).push(_route);
}

int get _fbCount => _fbRoutes.length;
List<route.FlushbarRoute<dynamic>> _fbRoutes = [];

Flushbar _buildTransferringFlushbar({@required Widget child, double forwardAnimTime: 1.0, Duration duration}) {

  final context = PEBRAppState.rootContext;

  // define the maximum width of the notification
  const double MAX_WIDTH = 160;
  const double MIN_PADDING_HORIZONTAL = 10;
  final double screenWidth = MediaQuery.of(context).size.width;
  final double padding = max(MIN_PADDING_HORIZONTAL, (screenWidth - MAX_WIDTH)/2);

  return Flushbar(
    flushbarPosition: FlushbarPosition.BOTTOM,
    messageText: child,
    borderRadius: 20.0,
    backgroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    margin: EdgeInsets.only(bottom: 20.0, left: padding, right: padding),
    duration: duration,
    forwardAnimationCurve: Interval(0.0, forwardAnimTime),
  );

}

void showTransferringDataFlushbar() {

  final context = PEBRAppState.rootContext;

  final Flushbar _flushbar = _buildTransferringFlushbar(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 2.0, width: 15.0, child: LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(SPINNER_SETTINGS_SCREEN),
          backgroundColor: Colors.transparent,
        )),
        SizedBox(width: 10.0),
        Text('transferring data',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: NOTIFICATION_MESSAGE_TEXT,
            fontSize: 12.0,
          ),
        ),
      ],
    ),
  );

  final _route = route.showFlushbar(
    context: context,
    flushbar: _flushbar,
  );

  Navigator.of(context, rootNavigator: true).push(_route);
  _fbRoutes.add(_route);
}

void dismissTransferringDataFlushbar() {

  if (_fbCount < 1) {
    print('$_fbCount notifications showing, doing nothing');
    return;
  }

  final context = PEBRAppState.rootContext;

  final _transferDoneFlushbar = _buildTransferringFlushbar(
    child: Center(
      child: Text(
        'done',
        style: TextStyle(
          color: NOTIFICATION_MESSAGE_TEXT,
          fontSize: 12.0,
        ),
      ),
    ),
    forwardAnimTime: 0.0,
    duration: Duration(seconds: 2),
  );
  final _newRoute = route.showFlushbar(
    context: context,
    flushbar: _transferDoneFlushbar,
  );

  final navigator = Navigator.of(context, rootNavigator: true);
  final toBeRemoved = _fbRoutes.removeAt(0);
  navigator.push(_newRoute).then((dynamic _) {
    // TODO: if a new notification is pushed until this then(...) clause is
    // called the navigator.removeRoute will not work
    // -> It might be easier to just write a custom component using overlays
    // (see https://www.didierboelens.com/2018/06/how-to-create-a-toast-or-notifications-notion-of-overlay/)
    // and setState to change the content to 'done' before dismissing it.
    print('done pushed');
    navigator.removeRoute(toBeRemoved);
  });

}

/// Takes a date and returns a date at the beginning (midnight) of the same day.
DateTime _roundToDays(DateTime date) {
  final day = date.day;
  final month = date.month;
  final year = date.year;
  return DateTime(year, month, day);
}

/// Returns the difference in days between date1 and date2.
///
/// - E.g. 1: if date1 is 2019-12-30 23:55:00.000 and date2 is
/// 2019-12-31 00:05:00.000 the difference will be 1 (day).
///
/// - E.g. 2: if date1 is 2019-12-30 00:05:00.000 and date2 is
/// 2019-12-31 23:55:00.000 the difference will be 1 (day).
int differenceInDays(DateTime date1, DateTime date2) {
  date1 = _roundToDays(date1);
  date2 = _roundToDays(date2);
  return date2.difference(date1).inDays;
}

/// Calculates age of someone since his/her [birthday].
///
/// Returns today's age in years.
int calculateAge(DateTime birthday) {
  final DateTime birthdayUtc = birthday.toLocal();
  final DateTime now = DateTime.now().toLocal();
  int years = now.year - birthdayUtc.year;
  if (birthdayUtc.month > now.month) {
    // birthday is yet to come this year
    years--;
  } else if (birthdayUtc.month == now.month && birthdayUtc.day > now.day) {
    // birthday is yet to come this month
    years--;
  }
  return years;
}

/// Turns date into the format dd.MM.yyyy.
String formatDateConsistent(DateTime date) {
  return DateFormat("dd.MM.yyyy").format(date.toLocal());
}

/// Turns date into the format yyyy-MM-dd.
///
/// Returns null if [date] is null.
String formatDateIso(DateTime date) {
  if (date == null) {
    return null;
  }
  return DateFormat("yyyy-MM-dd").format(date.toLocal());
}

/// Turns date into the format yyyy-MM-dd.
///
/// Returns null if [date] is null.
String formatDateForVisibleImpact(DateTime date) {
  if (date == null) {
    return null;
  }
  return DateFormat("yyyy-MM-dd").format(date.toLocal());
}

/// Turns a date into a formatted String. If the date is
///
/// * today it will return "Today"
/// * tomorrow it will return "Tomorrow"
/// * within 7 days from now it will return "x days from now"
/// * yesterday it will return "Yesterday"
/// * in the past it will return "x days ago".
String formatDate(DateTime date) {
  final int daysFromToday = differenceInDays(DateTime.now(), date);
  if (daysFromToday == 0) {
    return "Today";
  } else if (daysFromToday == 1) {
      return "Tomorrow";
  } else if (daysFromToday > 1 && daysFromToday <= 7) {
    return "$daysFromToday days from now";
  } else if (daysFromToday == -1) {
    return "Yesterday";
  } else if (daysFromToday < -1) {
    return "${-daysFromToday} days ago";
  }
  return DateFormat("dd.MM.yyyy").format(date.toLocal());
}

/// Turns a date into a formatted String. If the date is
///
/// * today it will return "Today, HH:mm"
/// * yesterday it will return "Yesterday, HH:mm"
/// * in the past it will return "dd.MM.yyyy HH:mm".
///
/// Returns null if [date] is null.
String formatDateAndTimeTodayYesterday(DateTime date) {
  if (date == null) {
    return null;
  }
  final int daysFromToday = differenceInDays(DateTime.now(), date);
  if (daysFromToday == 0) {
    return "today, ${DateFormat("HH:mm").format(date.toLocal())}";
  } else if (daysFromToday == -1) {
    return "yesterday, ${DateFormat("HH:mm").format(date.toLocal())}";
  }
  return DateFormat("dd.MM.yyyy HH:mm").format(date.toLocal());
}

/// Turns a date into a formatted String with date and time. If the date is
/// today it will return "Today, HH:mm". If the date was yesterday, it will
/// return "Yesterday, HH:mm". If the date was before yesterday, it will return
/// "X days ago".
String formatDateAndTime(DateTime date) {
  final int daysFromToday = differenceInDays(DateTime.now(), date);
  if (daysFromToday == -1) {
    return "Yesterday, ${DateFormat("HH:mm").format(date.toLocal())}";
  } else if (daysFromToday == 0) {
    return "Today, ${DateFormat("HH:mm").format(date.toLocal())}";
  } else {
    return "${-daysFromToday} days ago";
  }
}

/// Turns a DateTime object into the format HH:mm:ss.
///
/// Returns null if [date] is null.
String formatTimeIso(DateTime date) {
  if (date == null) {
    return null;
  }
  return DateFormat("HH:mm:ss").format(date.toLocal());
}

/// Formats a TimeOfDay object in the format HH:mm.
///
/// Returns null if [time] is null.
String formatTime(TimeOfDay time) {
  if (time == null) {
    return null;
  }
  final DateTime date = DateTime(1970, 1, 1, time.hour, time.minute);
  return DateFormat("HH:mm").format(date.toLocal());
}

/// Formats a TimeOfDay object in the format HH:mm.
///
/// Returns null if [time] is null.
String formatTimeForVisibleImpact(TimeOfDay time) {
  if (time == null) {
    return null;
  }
  final DateTime date = DateTime(1970, 1, 1, time.hour, time.minute);
  return DateFormat("HH:mm").format(date.toLocal());
}

/// Expects a time string of the format HH:mm.
///
/// Returns null if [time] is null.
TimeOfDay parseTimeOfDay(String time) {
  if (time == null) {
    return null;
  }
  final int hour = int.parse(time.split(':')[0]);
  final int minute = int.parse(time.split(':')[1]);
  return TimeOfDay(hour: hour, minute: minute);
}

/// Calculates the due date of the next preference assessment based on the date
/// of the last preference assessment and whether the patient is [suppressed]
/// (+3 months) or unsuppressed (+1 month).
/// 
/// Returns `null` if [lastAssessment] is `null`.
DateTime calculateNextAssessment(DateTime lastAssessment, bool suppressed) {
  if (lastAssessment == null) { return null; }
  DateTime newDate = DateTime(lastAssessment.year, suppressed ? lastAssessment.month + 3 : lastAssessment.month + 1, lastAssessment.day);
  return newDate;
}

/// Calculates the due date of the next endpoint survey based on the date of
/// enrollment and the open endpoint survey actions in [requiredActions].
/// Endpoint surveys are due 3, 6, and 12 months after the enrollment date.
///
/// Returns `null` if there are no ENDPOINT_xM_SURVEY_REQUIRED actions in
/// [requiredActions].
DateTime calculateNextEndpointSurvey(DateTime enrollmentDate, Set<RequiredAction> requiredActions) {
  final bool _completed12M = !requiredActions.any((RequiredAction a) => a.type == RequiredActionType.ENDPOINT_12M_SURVEY_REQUIRED);
  final bool _completed6M = !requiredActions.any((RequiredAction a) => a.type == RequiredActionType.ENDPOINT_6M_SURVEY_REQUIRED);
  final bool _completed3M = !requiredActions.any((RequiredAction a) => a.type == RequiredActionType.ENDPOINT_3M_SURVEY_REQUIRED);
  DateTime nextDate;
  if (!_completed12M) {
    DateTime twelveMonthsAfter = addMonths(enrollmentDate, 12);
    nextDate = twelveMonthsAfter;
  }
  if (!_completed6M) {
    DateTime sixMonthsAfter = addMonths(enrollmentDate, 6);
    nextDate = sixMonthsAfter;
  }
  if (!_completed3M) {
    DateTime threeMonthsAfter = addMonths(enrollmentDate, 3);
    nextDate = threeMonthsAfter;
  }
  return nextDate;
}

/// Calculates if a given [endpointSurveyType] is due based on the date of
/// enrollment and the current date.
///
/// @param [endpointSurveyType] 3, 6, or 12 month survey type. If any other
/// type is passed (e.g. REFILL_REQUIRED) it will return null.
bool isEndpointSurveyDue(DateTime enrollmentDate, RequiredActionType endpointSurveyType) {
  final DateTime now = DateTime.now();
  switch (endpointSurveyType) {
    case RequiredActionType.ENDPOINT_12M_SURVEY_REQUIRED:
      final DateTime twelveMonthsAfter = addMonths(enrollmentDate, 12);
      return now.isAfter(twelveMonthsAfter);
    case RequiredActionType.ENDPOINT_6M_SURVEY_REQUIRED:
      final DateTime sixMonthsAfter = addMonths(enrollmentDate, 6);
      return now.isAfter(sixMonthsAfter);
    case RequiredActionType.ENDPOINT_3M_SURVEY_REQUIRED:
      final DateTime threeMonthsAfter = addMonths(enrollmentDate, 3);
      return now.isAfter(threeMonthsAfter);
    default:
      return null;
  }
}

/// Adds [monthsToAdd] to [date].
///
/// Hour, minute, second, millisecond, microsecond will all be 0.
DateTime addMonths(DateTime date, int monthsToAdd) {
  return DateTime(date.year, date.month + monthsToAdd, date.day);
}

/// Updates the date of the last successful backup to now (local time).
Future<void> storeLatestBackupInSharedPrefs() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(LAST_SUCCESSFUL_BACKUP_KEY, DateTime.now().toIso8601String());
}

/// Updates the date of the last successful viral load fetch to now (local time).
///
/// @param [patientART] ART number of the patient for which to update the last
/// fetch date.
Future<void> storeLatestViralLoadFetchInSharedPrefs(String patientART) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('${LAST_SUCCESSFUL_VL_FETCH_KEY}_$patientART', DateTime.now().toIso8601String());
}

/// Gets the date of the last successful viral load fetch for the patient with
/// ART number [patientART]. Returns `null` if no date has been stored for this
/// patient yet.
Future<DateTime> getLatestViralLoadFetchFromSharedPrefs(String patientART) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String dateTimeString = prefs.getString('${LAST_SUCCESSFUL_VL_FETCH_KEY}_$patientART');
  return dateTimeString == null ? null : DateTime.parse(dateTimeString);
}

/// Updates the date and time when the app was last active (local time).
Future<void> storeAppLastActiveInSharedPrefs() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(LAST_APP_ACTIVE_KEY, DateTime.now().toIso8601String());
}

Future<DateTime> get appLastActive async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String lastActiveString = prefs.getString(LAST_APP_ACTIVE_KEY);
  return DateTime.tryParse(lastActiveString ?? '');
}

/// Gets the date of the last successful backup. Returns `null` if no date has
/// been stored in SharedPreferences yet.
Future<DateTime> get latestBackupFromSharedPrefs async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String dateTimeString = prefs.getString(LAST_SUCCESSFUL_BACKUP_KEY);
  return dateTimeString == null ? null : DateTime.parse(dateTimeString);
}

/// Launches the [url]. Can be a web page or a link to another app.
///
/// Throws an exception if a url cannot be opened.
Future<void> launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

/// Displays the exception [e] and its stacktrace [s] as a popup over the given
/// [context].
void showErrorInPopup(e, StackTrace s, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('${e.runtimeType}: $e'),
        content: SingleChildScrollView(child: Text(s.toString())),
        actions: [
          FlatButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


/// Returns true if the patient's most recent viral load is LTDL (lower than
/// detectable limit) or suppressed.
///
/// Returns false if
///
/// * there is no viral load data
///
/// * viral load data is unsuppressed.
///
/// Make sure you have called [patient.initializeViralLoadFields()] before using
/// this method. Otherwise the viral load will be `null` and this method will
/// return false.
bool isSuppressed(Patient patient) {
  return patient.mostRecentViralLoad?.isSuppressed ?? true;
}

/// Shows the lock screen, where the user has to enter their PIN code to unlock.
Future<T> lockApp<T extends Object>(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<T>(
      opaque: false,
      settings: RouteSettings(name: '/lock'),
      transitionsBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2, Widget widget) {
        return FadeTransition(
          opacity: anim1,
          child: widget, // child is the value returned by pageBuilder
        );
      },
      pageBuilder: (BuildContext context, _, __) {
        return LockScreen();
      },
    ),
  );
}

/// Hashes the [string] and returns the hashed value.
String hash(String string) {
  return Password.hash(string, PBKDF2(iterationCount: 500));
}

/// Verifies that the [string] corresponds to the [hash].
///
/// This method is blocking.
bool verifyHash(String string, String hash) {
  return Password.verify(string, hash);
}

/// Verifies that the [string] corresponds to the [hash].
///
/// This method can run in the background.
Future<bool> verifyHashAsync(String string, String hash) async {
  return compute(_verifyHashOneArg, {'string': string, 'hash': hash});
}

/// Same as [verifyHash] but takes only one arguments so it can be passed to the
/// compute function.
bool _verifyHashOneArg(Map<String, String> stringAndHash) {
  return Password.verify(stringAndHash['string'], stringAndHash['hash']);
}

/// Sorts a list of viral loads [viralLoads] according to the following rules:
///
/// 1. older createdDate comes before newer createdDate
///
/// 2. older dateOfBloodDraw comes before newer dateOfBloodDraw
///
/// 3. source manual comes before any other sources
///
/// 4. labNumber alphabetically ordered
void sortViralLoads(List<ViralLoad> viralLoads) {
  viralLoads.sort((ViralLoad a, ViralLoad b) {
    if (a.createdDate.isBefore(b.createdDate)) {
      return -1;
    }
    if (b.createdDate.isBefore(a.createdDate)) {
      return 1;
    }
    if (a.dateOfBloodDraw.isBefore(b.dateOfBloodDraw)) {
      return -1;
    }
    if (b.dateOfBloodDraw.isBefore(a.dateOfBloodDraw)) {
      return 1;
    }
    if (a.source == ViralLoadSource.MANUAL_INPUT() && b.source != ViralLoadSource.MANUAL_INPUT()) {
      return -1;
    }
    if (a.source != ViralLoadSource.MANUAL_INPUT() && b.source == ViralLoadSource.MANUAL_INPUT()) {
      return 1;
    }
    return a.labNumber.compareTo(b.labNumber);
  });
}

/// Returns true if a discrepancy has been found for this patient.
Future<bool> checkForViralLoadDiscrepancies(Patient patient) async {
  // TODO: check for viral load discrepancies in this patient.
  // Compare manual baseline and database baseline viral load. If there is a
  // discrepancy between them, set their discrepancy variable to true and insert
  // them into the SQLite database again, then return true. If no discrepancy
  // has been found, do nothing and return false.
  bool discrepancyFound = false;
  return discrepancyFound;
}

String composeSMS({@required String message, @required String peName, @required String pePhone}) {
  String pePhoneNoSpecialChars = pePhone.replaceAll(RegExp(r'[^0-9]'), '');
  return "PEBRA\n\n"
    "$message\n\n"
    "Etsetsa call-back nomorong ena $peName, penya *140*$pePhoneNoSpecialChars#"
    " (VCL) kapa *181*$pePhoneNoSpecialChars# (econet).";
}
