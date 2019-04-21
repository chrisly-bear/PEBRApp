import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
