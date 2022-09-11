import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pebrapp/config/PebraCloudConfig.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/exceptions/BackupNotFoundException.dart';
import 'package:pebrapp/exceptions/HTTPStatusNotOKException.dart';
import 'package:pebrapp/exceptions/InvalidPINException.dart';
import 'package:pebrapp/exceptions/NoLoginDataException.dart';
import 'package:pebrapp/exceptions/NoPasswordFileException.dart';
import 'package:pebrapp/exceptions/PebraCloudAuthFailedException.dart';
import 'package:path/path.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/Utils.dart';

/// Uploads [sourceFile] to PEBRAcloud.
///
/// [folder] is one of "data", "backups", "passwords".
///
/// If [filename] is not provided the [sourceFile]'s file name will be used.
/// Make sure to provide an accepted file extension, otherwise PEBRAcloud will
/// reject the upload. Accepted file extensions are ".txt", ".db", ".xlsx".
///
/// Throws [PebraCloudAuthFailedException] if the login to PEBRAcloud fails.
///
/// Throws [SocketException] if there is no internet connection or PEBRAcloud
/// cannot be reached.
///
/// Throws [HTTPStatusNotOKException] if PEBRAcloud fails to receive the file.
Future<void> uploadFileToPebraCloud(File sourceFile, String folder,
    {String filename}) async {
  final uri = Uri.parse('$PEBRA_CLOUD_API/upload/$folder');
  final multiPartFile = await http.MultipartFile.fromPath(
      'file', sourceFile.path,
      filename: filename);
  final uploadRequest = http.MultipartRequest('POST', uri)
    ..files.add(multiPartFile)
    ..headers['token'] = PEBRA_CLOUD_TOKEN;
  final responseStream = await uploadRequest.send();
  final response = await http.Response.fromStream(responseStream);
  if (response.statusCode == 401) {
    throw PebraCloudAuthFailedException();
  } else if (response.statusCode != 201) {
    throw HTTPStatusNotOKException(
        'An unexpected status code ${response.statusCode} was returned while interacting with PEBRAcloud.\n');
  }
}

/// Downloads the latest SQLite file from PEBRAcloud and replaces the one on the
/// device.
///
/// Throws [NoLoginDataException] if [username] is null.
///
/// Throws [InvalidPINException] if the PIN code for the given user is
/// incorrect.
///
/// Throws [PebraCloudAuthFailedException] if the login to PEBRAcloud fails.
///
/// Throws [SocketException] if there is no internet connection or PEBRAcloud
/// cannot be reached.
///
/// Throws [BackupNotFoundException] if no backup is found for the given
/// [username] on PEBRAcloud.
///
/// Throws [NoPasswordFileException] if no password file is found for the given
/// [username] on PEBRAcloud.
///
/// Throws [HTTPStatusNotOKException] if interaction with PEBRAcloud fails.
Future<void> restoreFromPebraCloud(String username, String pinCodeHash) async {
  if (username == null) {
    throw NoLoginDataException();
  }
  if (!(await existsBackupForUser(username))) {
    throw BackupNotFoundException();
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
/// given [username] exists on PEBRAcloud. Returns `true` if [username]
/// exists, `false` otherwise.
///
/// Throws [PebraCloudAuthFailedException] if authentication with PEBRAcloud fails.
///
/// Throws [HTTPStatusNotOKException] if interaction with PEBRAcloud fails.
Future<bool> existsBackupForUser(String username) async {
  final folder = PEBRA_CLOUD_BACKUP_FOLDER;
  final uri = Uri.parse('$PEBRA_CLOUD_API/exists/$folder/$username');
  final resp = await http.get(uri, headers: {
    'token': PEBRA_CLOUD_TOKEN,
  });
  if (resp.statusCode == 401) {
    throw PebraCloudAuthFailedException();
  } else if (resp.statusCode != 200) {
    throw HTTPStatusNotOKException(
        'An unexpected status code ${resp.statusCode} was returned while interacting with PEBRAcloud.\n');
  }
  final json = jsonDecode(resp.body) as Map<String, dynamic>;
  return json['exists'];
}

/// Throws [NoPasswordFileException] if no password file is found for the given
/// [username] on PEBRAcloud.
///
/// Throws [PebraCloudAuthFailedException] if the login to PEBRAcloud fails.
///
/// Throws [HTTPStatusNotOKException] if interaction with PEBRAcloud fails.
Future<bool> _pinCodeValid(String username, String pinCodeHash) async {
  final File passwordFile = await _downloadPasswordFile(username);
  final String truePINCodeHash = await passwordFile.readAsString();
  return pinCodeHash == truePINCodeHash;
}

/// Downloads the password file for the given [username].
///
/// Throws [NoPasswordFileException] if no password file is found for the given
/// [username] on PEBRAcloud.
///
/// Throws [PebraCloudAuthFailedException] if the login to PEBRAcloud fails.
///
/// Throws [HTTPStatusNotOKException] if interaction with PEBRAcloud fails.
Future<File> _downloadPasswordFile(String username) async {
  final folder = PEBRA_CLOUD_PASSWORD_FOLDER;
  final uri = Uri.parse('$PEBRA_CLOUD_API/download/$folder/$username');

  // download file
  final resp = await http.get(uri, headers: {
    'token': PEBRA_CLOUD_TOKEN,
  });

  if (resp.statusCode == 401) {
    throw PebraCloudAuthFailedException();
  } else if (resp.statusCode == 400) {
    throw NoPasswordFileException();
  } else if (resp.statusCode != 200) {
    throw HTTPStatusNotOKException(
        'An unexpected status code ${resp.statusCode} was returned while interacting with PEBRAcloud.\n');
  }

  // store file in database directory
  final String filepath =
      join(await DatabaseProvider().databasesDirectoryPath, 'PEBRA-password');
  File passwordFile = File(filepath);
  passwordFile = await passwordFile.writeAsBytes(resp.bodyBytes, flush: true);
  return passwordFile;
}

/// Downloads the latest backup file that matches the [username].
///
/// Throws [BackupNotFoundException] if no backup is found for the given
/// [username] on PEBRAcloud.
///
/// Throws [PebraCloudAuthFailedException] if the login to PEBRAcloud fails.
///
/// Throws [HTTPStatusNotOKException] if interaction with PEBRAcloud fails.
Future<File> _downloadLatestBackup(String username) async {
  final folder = PEBRA_CLOUD_BACKUP_FOLDER;
  final uri = Uri.parse('$PEBRA_CLOUD_API/download/$folder/$username');

  // download file
  final resp = await http.get(uri, headers: {
    'token': PEBRA_CLOUD_TOKEN,
  });

  if (resp.statusCode == 401) {
    throw PebraCloudAuthFailedException();
  } else if (resp.statusCode == 400) {
    throw BackupNotFoundException();
  } else if (resp.statusCode != 200) {
    throw HTTPStatusNotOKException(
        'An unexpected status code ${resp.statusCode} was returned while interacting with PEBRAcloud.\n');
  }

  // store file in database directory
  final String filepath = join(
      await DatabaseProvider().databasesDirectoryPath, 'PEBRApp-backup.db');
  File backupFile = File(filepath);
  backupFile = await backupFile.writeAsBytes(resp.bodyBytes, flush: true);
  return backupFile;
}
