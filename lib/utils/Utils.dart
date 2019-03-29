import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
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

Future<int> loginToSWITCHdrive(String username, String password) async {

  String _urlEncode(Map data) {
    return data.keys.map((key) => "${Uri.encodeComponent(key)}=${Uri.encodeComponent(data[key])}").join("&");
  }

  String _urlEncodeString(String s) {
    return Uri.encodeComponent(s);
  }

  final _switchHost = 'drive.switch.ch';
  // https://drive.switch.ch/index.php/login
  final _loginUri = Uri.https(_switchHost, 'index.php/login');

  // log in
  final _payload = _urlEncode({
    'user': username,
    'password': password,
  });
  final _contentLength = utf8.encode(_payload).length;
  final request = await HttpClient().postUrl(_loginUri)
    ..headers.add('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3')
    ..contentLength = _contentLength
    ..write(_payload);
  final response = await request.close();

  // TODO: always returns 200, even if login is clearly wrong

  final statusCode = response.statusCode;
  print("end of login (status code: $statusCode)");
  return statusCode;
}

/// Upload a file to the SWITCH toolbox's file storage.
Future<void> uploadFileToSWITCHdrive(File sourceFile, String targetFolder,
    String targetFilename, String username, String password) async {

  String _base64Encode(String s) {
    final bytes = utf8.encode(s);
    return base64.encode(bytes);
  }

  final _switchHost = 'drive.switch.ch';
  // https://drive.switch.ch/remote.php/webdav/targetFolder/targetFilename
  final _uploadPath = 'remote.php/webdav/' + targetFolder + '/' + targetFilename;
  final _uploadUri = Uri.https(_switchHost, _uploadPath);

  // upload file
  final request = await HttpClient().putUrl(_uploadUri)
    ..headers.add('Authorization', 'Basic ${_base64Encode(username + ':' + password)}')
    ..contentLength = await sourceFile.length()
    ..add(sourceFile.readAsBytesSync())
  ;
  final response = await request.close();

  final statusCode = response.statusCode;
  print("end of upload (status code: $statusCode)");
}

Future<void> uploadFileToSWITCHtoolbox(File sourceFile, String targetFolder,
    String targetFilename, String username, String password) async {

  final _shibsessionCookie = await authenticateWithSWITCHtoolboxServiceProvider(username, password);

  // get mydms_session cookie (required to access toolbox file storage service)
  final _req0 = http.Request('GET', Uri.parse('https://letodms.toolbox.switch.ch/pebrapp-data/op/op.Login.php?referuri='))
    ..headers['Cookie'] = _shibsessionCookie
    ..followRedirects = false;
  final _resp0 = await _req0.send();

  final _mydmsSessionCookie = _resp0.headers['set-cookie'];
  final _cookieHeaderString = '${_mydmsSessionCookie.split(' ').first} ${_shibsessionCookie.split(' ').first}';

  // upload file
  final _req1 = http.MultipartRequest('POST', Uri.parse('https://letodms.toolbox.switch.ch/pebrapp-data/op/op.AddDocument.php'))
    ..headers['Cookie'] = _cookieHeaderString
    ..files.add(await http.MultipartFile.fromPath('userfile[]', sourceFile.path))
    ..fields.addAll({
      'name': '${sourceFile.path.split('/').last}',
      'folderid': '1',
      'sequence': '1',
    });

  final _resp2Stream = await _req1.send();
  final _resp2 = await http.Response.fromStream(_resp2Stream);
  // TODO: return something to indicate whether the upload was successful or not
}

Future<String> authenticateWithSWITCHtoolboxServiceProvider(String username, String password) async {

  /// debug helper method: print the response object to console
  void _printHTMLResponse(http.Response r, {printBody = true}) {
    print('Response status: ${r.statusCode}');
    print('Response isRedirect: ${r.isRedirect}');
    print('Response headers: ${r.headers}');
    print('Response body:\n${r.body}');
  }

  // TODO: does this even do anything? we would have to pass a _shibsession_
  //       cookie to get any session information. we could maybe change this
  //       to take a _shibsession_ cookie as an argument and check if the
  //       session is valid.
  /// debug helper method: check if there is a valid session
  Future<void> _printSessionInfo() async {
    print('~~~ show session info ~~~');
    final _url = 'https://letodms.toolbox.switch.ch/Shibboleth.sso/Session';
    final _response = await http.get(_url);
    _printHTMLResponse(_response);
  }


  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% - 1 - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  // link composed with
  // https://www.switch.ch/aai/guides/discovery/login-link-composer/
  final _req1 = http.Request('GET', Uri.parse('https://letodms.toolbox.switch.ch/Shibboleth.sso/Login?entityID=https%3A%2F%2Feduid.ch%2Fidp%2Fshibboleth&target=https%3A%2F%2Fletodms.toolbox.switch.ch%2Fpebrapp-data%2F'))
  ..followRedirects = false;
  final _resp1Stream = await _req1.send();
  final _resp1 = await http.Response.fromStream(_resp1Stream);

  final _redirectUrl1 = _resp1.headers['location'];


  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% - 2 - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // get JSESSIONID cookie

  final _req2 = http.Request('GET', Uri.parse(_redirectUrl1))
    ..followRedirects = false;
  final _resp2Stream = await _req2.send();
  final _resp2 = await http.Response.fromStream(_resp2Stream);

  final _jsessionidCookie = _resp2.headers['set-cookie'];
  final _host = 'https://login.eduid.ch';
  final _redirectUrl2 = _host + _resp2.headers['location'];


  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% - 3 - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  final _req3 = http.Request('GET', Uri.parse(_redirectUrl2))
    ..followRedirects = false
    ..headers['Cookie'] = _jsessionidCookie;
  final _resp3Stream = await _req3.send();
  final _resp3 = await http.Response.fromStream(_resp3Stream);


  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% - 4 - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // get RelayState and SAMLResponse tokens

  final _resp4 = await http.post(
      _redirectUrl2,
      headers: {'Cookie': _jsessionidCookie},
      body: {
        'j_username': username,
        'j_password': password,
        '_eventId_proceed': '',
      });


  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% - 5 - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // get _shibsession_ cookie

  final dom.Document _doc = parse(_resp4.body);
  final dom.Element _formEl = _doc.querySelector('form');
  final dom.Element _relayStateEl = _doc.querySelector('input[name="RelayState"]');
  final dom.Element _samlResponseEl = _doc.querySelector('input[name="SAMLResponse"]');
  final _formUrl = _formEl.attributes['action'];
  final _relayState = _relayStateEl.attributes['value'];
  final _samlResponse = _samlResponseEl.attributes['value'];

  final _resp5 = await http.post(_formUrl, body: {
    'RelayState': _relayState,
    'SAMLResponse': _samlResponse,
  });

  final _shibsessionCookie = _resp5.headers['set-cookie'];

  return _shibsessionCookie;
}
