import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;
import 'package:pebrapp/config/SwitchConfig.dart';
import 'package:pebrapp/config/PebraCloudConfig.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/exceptions/DocumentNotFoundException.dart';
import 'package:pebrapp/exceptions/InvalidPINException.dart';
import 'package:pebrapp/exceptions/NoLoginDataException.dart';
import 'package:pebrapp/exceptions/NoPasswordFileException.dart';
import 'package:pebrapp/exceptions/SWITCHLoginFailedException.dart';
import 'package:path/path.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/Utils.dart';

/// Uploads `sourceFile` to PEBRAcloud.
///
/// `folder` is one of "data", "backups", "passwords".
///
/// If `filename` is not provided the `sourceFile`'s file name will be used.
///
/// Throws `SWITCHLoginFailedException` if the login to PEBRAcloud fails.
///
/// Throws `SocketException` if there is no internet connection or SWITCH cannot be reached.
Future<void> uploadFileToPebraCloud(File sourceFile, String folder, {String filename}) async {
  final uri = Uri.parse(PEBRA_CLOUD_API);
  final multiPartFile = await http.MultipartFile.fromPath('file', sourceFile.path, filename: filename);
  final uploadRequest = http.MultipartRequest('POST', uri)
    ..files.add(multiPartFile)
    ..fields.addAll({
      'folder': folder,
    });
  final responseStream = await uploadRequest.send();
  final response = await http.Response.fromStream(responseStream);
  print(response.statusCode);
  print(response.body);
}

/// Downloads the latest SQLite file from SWITCH and replaces the one on the devices.
///
/// Throws `NoLoginDataException` if loginData object is null.
///
/// Throws `InvalidPINException` if the PIN code for the given user is incorrect.
///
/// Throws `NoPasswordFileException` if there is not password file on SWITCHtoolbox.
///
/// Throws `SWITCHLoginFailedException` if the login to SWITCHtoolbox fails.
///
/// Throws `SocketException` if there is no internet connection or SWITCH cannot be reached.
///
/// Throws `DocumentNotFoundException` if backup for the given [username] is not available.
Future<void> restoreFromSWITCHtoolbox(String username, String pinCodeHash) async {
  if (username == null) {
    throw NoLoginDataException();
  }
  if (!(await existsBackupForUser(username))) {
    throw DocumentNotFoundException();
  }
  if (!(await _pinCodeValid(username, pinCodeHash))) {
    throw InvalidPINException();
  }
  final File backupFile = await _downloadLatestBackup(username);
  await DatabaseProvider().restoreFromFile(backupFile);
  PatientBloc.instance.sinkAllPatientsFromDatabase();
  storeLatestBackupInSharedPrefs();
}

/// Checks if the given [username] is already taken, i.e., if a backup for the
/// given [username] exists on SWITCHtoolbox. Returns [true] if [username]
/// exists, [false] otherwise.
///
/// Throws `SWITCHLoginFailedException` if the login to SWITCHtoolbox fails.
Future<bool> existsBackupForUser(String username) async {
  try {
    await _getFirstDocumentNameForDocumentStartingWith(username, SWITCH_TOOLBOX_BACKUP_FOLDER_ID);
  } catch (DocumentNotFoundException) {
    return false;
  }
  return true;
}

/// Uploads a new version of the document with name `sourceFile` on SWITCHtoolbox.
/// Update only works if a document with the name `documentName` is already in the specified folder on SWITCHtoolbox.
///
/// If `folderID` is not provided the update will be attempted in the root folder (folderId = 1).
///
/// Throws `SWITCHLoginFailedException` if the login to SWITCHtoolbox fails.
///
/// Throws `DocumentNotFoundException` if no matching document was found.
Future<void> updateFileOnSWITCHtoolbox(File sourceFile, String documentName, {int folderId = 1}) async {
  final int docId = await _getFirstDocumentIdForDocumentWithName(documentName, folderId);

  // upload file
  final _req1 = http.MultipartRequest('POST', Uri.parse('https://letodms.toolbox.switch.ch/$SWITCH_TOOLBOX_PROJECT/op/op.UpdateDocument.php'))
    ..files.add(await http.MultipartFile.fromPath('userfile', sourceFile.path))
    ..fields.addAll({
      'documentid': '$docId',
    });

  final _resp2Stream = await _req1.send();
  final _resp2 = await http.Response.fromStream(_resp2Stream);
  // TODO: return something to indicate whether the upload was successful or not
}

/// Throws `NoPasswordFileException` if there is no password file stored on
/// SWITCHtoolbox.
Future<bool> _pinCodeValid(String username, String pinCodeHash) async {
  try {
    final File passwordFile = await _downloadPasswordFile(username);
    final String truePINCodeHash = await passwordFile.readAsString();
    return pinCodeHash == truePINCodeHash;
  } on DocumentNotFoundException {
    throw NoPasswordFileException();
  }
}

/// Downloads the password file from SWITCHtoolbox for the given [username].
///
/// Throws `DocumentNotFoundException` if no password file is available for the
/// given [username].
Future<File> _downloadPasswordFile(String username) async {
  final String documentName = await _getFirstDocumentNameForDocumentStartingWith(username, SWITCH_TOOLBOX_PASSWORD_FOLDER_ID);
  final int switchDocumentId = await _getFirstDocumentIdForDocumentWithName(documentName, SWITCH_TOOLBOX_PASSWORD_FOLDER_ID);
  final int latestVersion = await _getLatestVersionOfDocument(switchDocumentId);
  final String absoluteLink = 'https://letodms.toolbox.switch.ch/$SWITCH_TOOLBOX_PROJECT/op/op.Download.php?documentid=$switchDocumentId&version=$latestVersion';
  final Uri downloadUri = Uri.parse(absoluteLink);

  // download file
  final resp = await http.get(downloadUri);

  // store file in database directory
  final String filepath = join(await DatabaseProvider().databasesDirectoryPath, 'PEBRA-password');
  File passwordFile = File(filepath);
  passwordFile = await passwordFile.writeAsBytes(resp.bodyBytes, flush: true);
  return passwordFile;
}

/// Downloads the latest backup file that matches the loginData from SWITCHtoolbox.
/// Returns null if no matching backup is found.
///
/// Throws `DocumentNotFoundException` if no backup is available for the loginData.
Future<File> _downloadLatestBackup(String username) async {
  final String documentName = await _getFirstDocumentNameForDocumentStartingWith(username, SWITCH_TOOLBOX_BACKUP_FOLDER_ID);
  final int switchDocumentId = await _getFirstDocumentIdForDocumentWithName(documentName, SWITCH_TOOLBOX_BACKUP_FOLDER_ID);
  final int latestVersion = await _getLatestVersionOfDocument(switchDocumentId);
  final String absoluteLink = 'https://letodms.toolbox.switch.ch/$SWITCH_TOOLBOX_PROJECT/op/op.Download.php?documentid=$switchDocumentId&version=$latestVersion';
  final Uri downloadUri = Uri.parse(absoluteLink);

  // download file
  final resp = await http.get(downloadUri);

  // store file in database directory
  final String filepath = join(await DatabaseProvider().databasesDirectoryPath, 'PEBRApp-backup.db');
  File backupFile = File(filepath);
  backupFile = await backupFile.writeAsBytes(resp.bodyBytes, flush: true);
  return backupFile;
}

/// Finds the full name of the document that starts with [startsWith] in the folder [folderId].
/// If there are several documents with a matching start string, it will return the name of the first one.
///
/// Throws [DocumentNotFoundException] if no matching document was found.
Future<String> _getFirstDocumentNameForDocumentStartingWith(String startsWith, int folderId) async {
  // get list of files
  final resp = await http.get(
    Uri.parse('https://letodms.toolbox.switch.ch/$SWITCH_TOOLBOX_PROJECT/out/out.ViewFolder.php?folderid=$folderId'),
  );

  // parse html
  final dom.Document _doc = parse(resp.body);
  final dom.Element _tableBody = _doc.querySelector('table[class="folderView"] > tbody');
  if (_tableBody == null) {
    // no documents are in SWITCHtoolbox
    throw DocumentNotFoundException();
  }
  final aElements = _tableBody.getElementsByTagName('a');

  // find first matching document
  for (dom.Element a in aElements) {
    final String linkText = a.text;
    if (linkText.startsWith(startsWith)) {
      return linkText;
    }
  }
  // no matching document found
  throw DocumentNotFoundException();
}

/// Finds the document id of a document that matches `documentName` in the folder `folderId`.
/// If there are several documents with a matching name, it will return the id of the first one.
///
/// Throws 'DocumentNotFoundException' if no matching document was found.
Future<int> _getFirstDocumentIdForDocumentWithName(String documentName, int folderId) async {

  // get list of files
  final resp = await http.get(
    Uri.parse('https://letodms.toolbox.switch.ch/$SWITCH_TOOLBOX_PROJECT/out/out.ViewFolder.php?folderid=$folderId'),
  );

  // parse html
  final dom.Document _doc = parse(resp.body);
  final dom.Element _tableBody = _doc.querySelector('table[class="folderView"] > tbody');
  if (_tableBody == null) {
    // no documents are in SWITCHtoolbox
    throw DocumentNotFoundException();
  }
  final aElements = _tableBody.getElementsByTagName('a');

  // find first matching document
  for (dom.Element a in aElements) {
    final String linkText = a.text;
    if (linkText == documentName) {
      final relativeLink = a.attributes['href'];
      final Uri relativeUri = Uri.parse(relativeLink);
      final String switchDocumentId = relativeUri.queryParameters['documentid'];
      return int.parse(switchDocumentId);
    }
  }
  // no matching document found
  throw DocumentNotFoundException();
}

/// Finds the latest version of the document with `documentId`.
///
/// Throws `DocumentNotFoundException` if document with `documentId` does not exist.
Future<int> _getLatestVersionOfDocument(int documentId) async {
  // get list of files
  final resp = await http.get(
    Uri.parse('https://letodms.toolbox.switch.ch/$SWITCH_TOOLBOX_PROJECT/out/out.ViewDocument.php?documentid=$documentId&showtree=1'),
  );

  // parse html
  final dom.Document _doc = parse(resp.body);
  final List<dom.Element> _contentHeadings = _doc.querySelectorAll('div[class="contentHeading"]');
  if (_contentHeadings.length == 0) {
    throw DocumentNotFoundException();
  }
  for (dom.Element el in _contentHeadings) {
    if (el.text == 'Current version') {
      final dom.Element sibling = el.nextElementSibling;
      final dom.Element versionEl = sibling.querySelectorAll('table[class="folderView"] > tbody > tr > td')[1];
      final String version = versionEl.text;
      return int.parse(version);
    }
  }

  // we should never reach this point -> maybe throw an exception instead?
  return null;
}
