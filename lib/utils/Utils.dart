import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:pebrapp/config/SharedPreferencesConfig.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:intl/intl.dart';
import 'package:pebrapp/screens/SettingsScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';


void showFlushBar(BuildContext context, String message, {String title}) {
  Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
    title: title,
    messageText: Text(
        message, textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
        ),
    ),
    duration: Duration(seconds: 5),
  ).show(context);
}

String artRefillOptionToString(ARTRefillOption option) {
  String returnString;
  switch (option) {
    case ARTRefillOption.CLINIC:
      returnString = "Clinic";
      break;
    case ARTRefillOption.PE_HOME_DELIVERY:
      returnString = "Home Delivery PE";
      break;
    case ARTRefillOption.VHW:
      returnString = "VHW";
      break;
    case ARTRefillOption.TREATMENT_BUDDY:
      returnString = "Treatment Buddy";
      break;
    case ARTRefillOption.COMMUNITY_ADHERENCE_CLUB:
      returnString = "Community Adherence Club";
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
      returnString = "MESSAGE 1";
      break;
    case AdherenceReminderMessage.MESSAGE_2:
      returnString = "MESSAGE 2";
      break;
  }
  return returnString;
}

String vlSuppressedMessageToString(VLSuppressedMessage message) {
  String returnString;
  switch (message) {
    case VLSuppressedMessage.MESSAGE_1:
      returnString = ":)";
      break;
    case VLSuppressedMessage.MESSAGE_2:
      returnString = "MESSAGE 2";
      break;
  }
  return returnString;
}

String vlUnsuppressedMessageToString(VLUnsuppressedMessage message) {
  String returnString;
  switch (message) {
    case VLUnsuppressedMessage.MESSAGE_1:
      returnString = ":(";
      break;
    case VLUnsuppressedMessage.MESSAGE_2:
      returnString = "MESSAGE 2";
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
int _differenceInDays(DateTime date1, DateTime date2) {
  date1 = _roundToDays(date1);
  date2 = _roundToDays(date2);
  return date2.difference(date1).inDays;
}

/// Turns a date into a formatted String. If the date is within 3 days from now
/// it will return "In x days". If the date is today it will return "Today". If
/// the date is in the past, it will return "x days ago".
String formatDate(DateTime date) {
  final int daysFromToday = _differenceInDays(DateTime.now(), date);
  if (daysFromToday > 3) {
    return DateFormat("dd.MM.yyyy").format(date.toLocal());
  } else if (daysFromToday > 0 && daysFromToday <= 3) {
    return "In $daysFromToday days";
  } else if (daysFromToday == 0) {
    return "Today";
  } else {
    return "${-daysFromToday} days ago";
  }
}

/// Calculates the due date of the next preference assessment based on the date
/// of the last preference assessment (+60 days).
DateTime calculateNextAssessment(DateTime lastAssessment) {
  // TODO: implement proper calculation of adding two months
  return lastAssessment.add(Duration(days: 60));
}

/// Calculates the due date of the next ART refill based on the date of the last
/// ART refill (+90 days).
DateTime calculateNextARTRefill(DateTime lastARTRefill) {
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