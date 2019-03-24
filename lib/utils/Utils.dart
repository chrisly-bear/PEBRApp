import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

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

String eacOptionToString(EACOption option) {
  String returnString;
  switch (option) {
    case EACOption.HOME_VISIT_PE:
      returnString = "Home Visit from PE";
      break;
    case EACOption.NURSE_AT_CLINIC:
      returnString = "Nurse at the Clinic";
      break;
    case EACOption.PHONE_CALL_PE:
      returnString = "Phone Call from PE";
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

Future<void> uploadDatabaseToSWITCHdrive(File sourceFile, String targetFolder,
    String targetFilename, String username, String password) async {

  String _urlEncode(Map data) {
    return data.keys.map((key) => "${Uri.encodeComponent(key)}=${Uri.encodeComponent(data[key])}").join("&");
  }

  String _urlEncodeString(String s) {
    return Uri.encodeComponent(s);
  }

  String _base64Encode(String s) {
    final bytes = utf8.encode(s);
    return base64.encode(bytes);
  }

  final _switchHost = 'drive.switch.ch';
  // https://drive.switch.ch/index.php/login
  final _loginUri = Uri.https(_switchHost, 'index.php/login');

  // https://drive.switch.ch/remote.php/webdav/targetFolder/targetFilename
  final _uploadPath = 'remote.php/webdav/' + targetFolder + '/' + targetFilename;
  final _uploadUri = Uri.https(_switchHost, _uploadPath);

  // get request token
  String requestToken;
  HttpClientRequest request = await HttpClient().getUrl(_loginUri);
  HttpClientResponse response = await request.close();
  await response.transform(utf8.decoder).forEach((String html) {
    final dom.Document doc = parse(html);
    final dom.Element el = doc.querySelector('input[name="requesttoken"]');
    requestToken = el.attributes['value'];
  });

  // log in
  final _payload = _urlEncode({
    'user': username,
    'password': password,
    'requesttoken': requestToken,
  });
  final _contentLength = utf8.encode(_payload).length;
  request = await HttpClient().postUrl(_loginUri)
    ..headers.add('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3')
    ..contentLength = _contentLength
    ..write(_payload);
  response = await request.close();

  // upload file
  request = await HttpClient().putUrl(_uploadUri)
    ..headers.add('Authorization', 'Basic ${_base64Encode(username + ':' + password)}')
    ..contentLength = await sourceFile.length()
    ..add(sourceFile.readAsBytesSync())
  ;
  response = await request.close();

  final statusCode = response.statusCode;
  print("end of upload (status code: $statusCode)");
}
