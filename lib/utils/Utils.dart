import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:pebrapp/config/SharedPreferencesConfig.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:intl/intl.dart';
import 'package:pebrapp/screens/SettingsScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


void showFlushBar(BuildContext context, String message, {String title, bool error=false}) {
  Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
    titleText: title == null ? null : Text(title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
    ),
    messageText: Text(
        message, textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: title == null ? 18.0 : 16.0,
        ),
    ),
    boxShadows: [BoxShadow(color: Colors.black, blurRadius: 5.0, offset: Offset(0.0, 0.0), spreadRadius: 0.0)],
    borderRadius: 5,
    backgroundColor: error ? Colors.redAccent : Colors.black.withAlpha(200),
    aroundPadding: EdgeInsets.symmetric(horizontal: 80.0),
    duration: error ? null : Duration(seconds: 5),
  ).show(context);
}

String artRefillOptionToString(ARTRefillOption option) {
  String returnString;
  switch (option) {
    case ARTRefillOption.CLINIC:
      returnString = "At the clinic";
      break;
    case ARTRefillOption.PE_HOME_DELIVERY:
      returnString = "PE (home delivery)";
      break;
    case ARTRefillOption.VHW:
      returnString = "VHW (at the VHW's home)";
      break;
    case ARTRefillOption.TREATMENT_BUDDY:
      returnString = "Treatment Buddy";
      break;
    case ARTRefillOption.COMMUNITY_ADHERENCE_CLUB:
      returnString = "CAC (Community Adherence Club)";
      break;
  }
  return returnString;
}

String adherenceReminderFrequencyToString(AdherenceReminderFrequency frequency) {
  String returnString;
  switch (frequency) {
    case AdherenceReminderFrequency.DAILY:
      returnString = "Daily";
      break;
    case AdherenceReminderFrequency.WEEKLY:
      returnString = "Weekly";
      break;
    case AdherenceReminderFrequency.MONTHLY:
      returnString = "Monthly";
      break;
  }
  return returnString;
}

String adherenceReminderMessageToString(AdherenceReminderMessage message) {
  String returnString;
  switch (message) {
    case AdherenceReminderMessage.MESSAGE_1:
      returnString = "Meds time 🕒";
      break;
    case AdherenceReminderMessage.MESSAGE_2:
      returnString = "Nako ea lithlare 🕒";
      break;
    case AdherenceReminderMessage.MESSAGE_3:
      returnString = "Recharge!";
      break;
    case AdherenceReminderMessage.MESSAGE_4:
      returnString = "Healthy living!";
      break;
    case AdherenceReminderMessage.MESSAGE_5:
      returnString = "Bophelo bo botle!";
      break;
    case AdherenceReminderMessage.MESSAGE_6:
      returnString = "Me and good health!";
      break;
    case AdherenceReminderMessage.MESSAGE_7:
      returnString = "Nna le bophelo bo botle!";
      break;
    case AdherenceReminderMessage.MESSAGE_8:
      returnString = "Right time!";
      break;
    case AdherenceReminderMessage.MESSAGE_9:
      returnString = "Nake e nepahetseng";
      break;
  }
  return returnString;
}

String vlSuppressedMessageToString(VLSuppressedMessage message) {
  String returnString;
  switch (message) {
    case VLSuppressedMessage.MESSAGE_1:
      returnString = "😊";
      break;
    case VLSuppressedMessage.MESSAGE_2:
      returnString = "Well done, keep it up!";
      break;
    case VLSuppressedMessage.MESSAGE_3:
      returnString = "Hoooha!";
      break;
    case VLSuppressedMessage.MESSAGE_4:
      returnString = "GOT IT!";
      break;
    case VLSuppressedMessage.MESSAGE_5:
      returnString = "WOW!!!";
      break;
    case VLSuppressedMessage.MESSAGE_6:
      returnString = "PELE EA PELE!";
      break;
  }
  return returnString;
}

String vlUnsuppressedMessageToString(VLUnsuppressedMessage message) {
  String returnString;
  switch (message) {
    case VLUnsuppressedMessage.MESSAGE_1:
      returnString = "Keep trying. Do better next time.";
      break;
    case VLUnsuppressedMessage.MESSAGE_2:
      returnString = "No leke. Etsa betere ka moso.";
      break;
    case VLUnsuppressedMessage.MESSAGE_3:
      returnString = "Ahhh!!!";
      break;
    case VLUnsuppressedMessage.MESSAGE_4:
      returnString = "OH NO!!!";
      break;
    case VLUnsuppressedMessage.MESSAGE_5:
      returnString = "Battery low. Take action! 😑";
      break;
    case VLUnsuppressedMessage.MESSAGE_6:
      returnString = "Battery e tlase. Etsa hohong! 😑";
      break;
  }
  return returnString;
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

/// Turns a date into a formatted String. If the date is
///
/// * today it will return "Today"
/// * tomorrow it will return "Tomorrow"
/// * within 3 days from now it will return "x days from now"
/// * yesterday it will return "Yesterday"
/// * in the past it will return "x days ago".
String formatDate(DateTime date) {
  final int daysFromToday = differenceInDays(DateTime.now(), date);
  if (daysFromToday == 0) {
    return "Today";
  } else if (daysFromToday == 1) {
      return "Tomorrow";
  } else if (daysFromToday > 1 && daysFromToday <= 3) {
    return "$daysFromToday days from now";
  } else if (daysFromToday == -1) {
    return "Yesterday";
  } else if (daysFromToday < -1) {
    return "${-daysFromToday} days ago";
  }
  return DateFormat("dd.MM.yyyy").format(date.toLocal());
}

/// Turns a date into a formatted String. If the date is within 3 days from now
/// it will return "In x days". If the date is today it will return "Today". If
/// the date is in the past, it will return "x days ago".
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
/// of the last preference assessment (+60 days).
/// 
/// Returns `null` if [lastAssessment] is `null`.
DateTime calculateNextAssessment(DateTime lastAssessment) {
  if (lastAssessment == null) { return null; }
  // TODO: implement proper calculation of adding two months
  return lastAssessment.add(Duration(days: 60));
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

/// Loads the login data from the on-device storage (SharedPreferences). Returns
/// null if there are no login data.
Future<LoginData> get loginDataFromSharedPrefs async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final prefKeys = prefs.getKeys();
  if (prefKeys.contains(FIRSTNAME_KEY)
      && prefKeys.contains(LASTNAME_KEY)
      && prefKeys.contains(HEALTHCENTER_KEY)) {
    final firstName = prefs.get(FIRSTNAME_KEY);
    final lastName = prefs.get(LASTNAME_KEY);
    final healthCenter = prefs.get(HEALTHCENTER_KEY);
    return LoginData(firstName, lastName, healthCenter);
  }
  return null;
}

/// Updates the date of the last successful backup to now (local time).
Future<void> storeLatestBackupInSharedPrefs() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(LAST_SUCCESSFUL_BACKUP_KEY, DateTime.now().toIso8601String());
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
