import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:pebrapp/config/SharedPreferencesConfig.dart';
import 'package:intl/intl.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/screens/LockScreen.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:password/password.dart';


/// Displays a notification over the given [context].
///
/// @param [message]: The message to display.
///
/// @param [title]: An optional title to display.
///
/// @param [error]: If this is `true` then the notification will be displayed in red.
///
/// @param [onButtonPress]: Required if a button should be displayed. This function will be executed when the button is pressed.
///
/// @param [buttonText]: Optional button text to be displayed on the button. If this is null or the empty string an info icon will be displayed instead.
void showFlushBar(BuildContext context, String message, {String title, bool error=false, VoidCallback onButtonPress, String buttonText}) {

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

  Flushbar(
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
    aroundPadding: EdgeInsets.symmetric(horizontal: padding),
    duration: error ? null : Duration(seconds: 5),
  ).show(context);
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

/// Calculates the due date of the next ART refill based on the date of the last
/// ART refill (+90 days).
///
/// Returns `null` if [lastARTRefill] is `null`.
DateTime calculateNextARTRefill(DateTime lastARTRefill) {
  if (lastARTRefill == null) { return null; }
  // TODO: implement proper calculation of adding three months
  return lastARTRefill.add(Duration(days: 90));
}

/// Updates the date of the last successful backup to now (local time).
Future<void> storeLatestBackupInSharedPrefs() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(LAST_SUCCESSFUL_BACKUP_KEY, DateTime.now().toIso8601String());
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
  return patient.mostRecentViralLoad?.isSuppressed ?? false;
}

/// Shows the lock screen, where the user has to enter their PIN code to unlock.
Future<T> lockApp<T extends Object>(BuildContext context) {
  return Navigator.of(context).push(
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