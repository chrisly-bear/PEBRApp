import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;
import 'package:pebrapp/config/SwitchConfig.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/exceptions/BackupNotAvailableException.dart';
import 'package:pebrapp/exceptions/NoLoginDataException.dart';
import 'package:pebrapp/screens/SettingsScreen.dart';
import 'package:path/path.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/Utils.dart';

/// Uploads `sourceFile` to SWITCHtoolbox.
///
/// If `filename` is not provided the `sourceFile`'s file name will be used.
///
/// If `folderID` is not provided the file will be uploaded to the root folder (folderID = 1).
Future<void> uploadFileToSWITCHtoolbox(File sourceFile, {String filename, int folderID = 1}) async {

  // get necessary cookies
  final String _shibsessionCookie = await _getShibSession(SWITCH_USERNAME, SWITCH_PASSWORD);
  final String _mydmsSessionCookie = await _getMydmsSession(_shibsessionCookie);
  final _cookieHeaderString = '${_mydmsSessionCookie.split(' ').first} ${_shibsessionCookie.split(' ').first}';

  // upload file
  final _req1 = http.MultipartRequest('POST', Uri.parse('https://letodms.toolbox.switch.ch/$SWITCH_TOOLBOX_PROJECT/op/op.AddDocument.php'))
    ..headers['Cookie'] = _cookieHeaderString
    ..files.add(await http.MultipartFile.fromPath('userfile[]', sourceFile.path))
    ..fields.addAll({
      'name': filename == null ? '${sourceFile.path.split('/').last}' : filename,
      'folderid': '$folderID',
      'sequence': '1',
    });

  final _resp2Stream = await _req1.send();
  final _resp2 = await http.Response.fromStream(_resp2Stream);
  // TODO: return something to indicate whether the upload was successful or not
}

/// Downloads the latest SQLite file from SWITCH and replaces the one on the devices.
///
/// Throws `NoLoginDataException` if loginData object is null.
///
/// Throws `SocketException` if there is no internet connection or SWITCH cannot be reached.
///
/// Throws `BackupNotAvailableException` if backup for the loginData is not available.
Future<void> restoreFromSWITCHtoolbox(LoginData loginData) async {
  if (loginData == null) {
    throw NoLoginDataException();
  }
  final File backupFile = await _downloadLatestBackup(loginData);
  if (backupFile == null) {
    throw BackupNotAvailableException();
  } else {
    await DatabaseProvider().restoreFromFile(backupFile);
    await PatientBloc.instance.sinkAllPatientsFromDatabase();
  }
}

/// Downloads the latest backup file that matches the loginData from SWITCHtoolbox.
/// Returns null if no matching backup is found.
Future<File> _downloadLatestBackup(LoginData loginData) async {
  
  // get necessary cookies
  final String _shibsessionCookie = await _getShibSession(SWITCH_USERNAME, SWITCH_PASSWORD);
  final String _mydmssessionCookie = await _getMydmsSession(_shibsessionCookie);
  
  List<BackupLink> backupLinks = await _getAllBackupLinks(_shibsessionCookie, _mydmssessionCookie);

  BackupLink mostRecentMatchingBackup;
  for (BackupLink backupLink in backupLinks) {
    if (backupLink.loginData == loginData
          && (mostRecentMatchingBackup == null || backupLink.date.isAfter(mostRecentMatchingBackup.date))) {
        mostRecentMatchingBackup = backupLink;
    }
  }
  if (mostRecentMatchingBackup == null) {
    return null;
  }

  // download file
  final resp = await http.get(
    mostRecentMatchingBackup.downloadUri,
    headers: {'Cookie': '$_shibsessionCookie; $_mydmssessionCookie'},
  );

  // store file in database directory
  final String filepath = join(await DatabaseProvider().databasesDirectoryPath, 'PEBRApp-backup.db');
  File backupFile = File(filepath);
  backupFile = await backupFile.writeAsBytes(resp.bodyBytes, flush: true);
  return backupFile;
}

Future<bool> existsBackupForUser(LoginData loginData) async {
  final String _shibsessionCookie = await _getShibSession(SWITCH_USERNAME, SWITCH_PASSWORD);
  final String _mydmssessionCookie = await _getMydmsSession(_shibsessionCookie);
  List<BackupLink> backupLinks = await _getAllBackupLinks(_shibsessionCookie, _mydmssessionCookie);
  for (BackupLink backupLink in backupLinks) {
    if (backupLink.loginData == loginData) { return true; }
  }
  return false;
}

Future<List<BackupLink>> _getAllBackupLinks(String _shibsessionCookie, String _mydmssessionCookie) async {

  // get list of files
  final resp = await http.get(
    Uri.parse('https://letodms.toolbox.switch.ch/$SWITCH_TOOLBOX_PROJECT/out/out.ViewFolder.php?folderid=$SWITCH_TOOLBOX_BACKUP_FOLDER_ID'),
    headers: {'Cookie': '$_shibsessionCookie; $_mydmssessionCookie'},
  );

  // parse html
  final dom.Document _doc = parse(resp.body);
  final dom.Element _tableBody = _doc.querySelector('table[class="folderView"] > tbody');
  final aElements = _tableBody.getElementsByTagName('a');

  // create BackupLink objects
  List<BackupLink> backupLinks = [];
  aElements.forEach((dom.Element a) {
    final textSplitted = a.text.split('_');
    if (textSplitted.length == 4) {
      final String firstName = textSplitted[0];
      final String lastName = textSplitted[1];
      final String healthCenter = textSplitted[2];
      final LoginData loginData = LoginData(firstName, lastName, healthCenter);
      final DateTime date = DateTime.parse(textSplitted[3]);
      final relativeLink = a.attributes['href'];
      final Uri relativeUri = Uri.parse(relativeLink);
      final String switchDocumentId = relativeUri.queryParameters['documentid'];
      final String absoluteLink = 'https://letodms.toolbox.switch.ch/pebrapp-data/op/op.Download.php?documentid=$switchDocumentId&version=1';
      final Uri absoluteUri = Uri.parse(absoluteLink);
      final BackupLink backupLink = BackupLink(loginData, date, absoluteUri);
      backupLinks.add(backupLink);
    }
  });

  return backupLinks.toList(growable: false);
}

Future<String> _getShibSession(String username, String password) async {

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

Future<String> _getMydmsSession(String shibsessionCookie) async {
  final req = http.Request('GET', Uri.parse('https://letodms.toolbox.switch.ch/$SWITCH_TOOLBOX_PROJECT/op/op.Login.php?referuri='))
    ..headers['Cookie'] = shibsessionCookie
    ..followRedirects = false;
  final resp = await req.send();
  final mydmssessionCookie = resp.headers['set-cookie'];
  return mydmssessionCookie;
}

class BackupLink {
  final LoginData _loginData;
  final DateTime _date;
  final Uri _downloadUri;
  BackupLink(this._loginData, this._date, this._downloadUri);

  LoginData get loginData => _loginData;

  Uri get downloadUri => _downloadUri;

  DateTime get date => _date;
}
