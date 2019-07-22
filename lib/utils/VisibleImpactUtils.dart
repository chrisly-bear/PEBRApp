
import 'dart:convert';
import 'package:pebrapp/config/VisibleImpactConfig.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/ViralLoadSource.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
import 'package:pebrapp/database/models/UserData.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/exceptions/MultiplePatientsException.dart';
import 'package:pebrapp/exceptions/PatientNotFoundException.dart';
import 'package:pebrapp/exceptions/VisibleImpactLoginFailedException.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:http/http.dart' as http;

/// ART Refill Date Upload
Future<void> uploadNextARTRefillDate(Patient patient, DateTime nextARTRefillDate) async {
  // TODO: upload the new date to the visible impact database and if it didn't work show a message that the upload has to be retried manually
  // TODO: if [nextARTRefillDate] is null then do nothing (which is the case if the patient has been deactivated/'refill not done' was selected by the user)
  await Future.delayed(Duration(seconds: 3));
  final bool success = false;
  if (success) {
    await _handleSuccess(patient, RequiredActionType.ART_REFILL_DATE_UPLOAD_REQUIRED);
  } else {
    await _handleFailure(patient, RequiredActionType.ART_REFILL_DATE_UPLOAD_REQUIRED);
    showFlushbar('Please upload the next ART refill date manually.',
      title: 'Upload of ART Refill Date Failed',
      error: true,
      buttonText: 'Retry\nNow',
      onButtonPress: () {
        uploadNextARTRefillDate(patient, nextARTRefillDate);
      },
    );
  }
}

/// Notifications Upload
Future<void> uploadNotificationsPreferences(Patient patient, PreferenceAssessment latestPreferenceAssessment) async {
  // TODO: upload the notifications preferences from the assessment to the visible impact database and if it didn't work show a message that the upload has to be retried manually
  print('...uploading notifications preferences\n'
      'Adherence Reminder: ${latestPreferenceAssessment?.adherenceReminderEnabled}\n'
      'ART Refill Reminder: ${latestPreferenceAssessment?.artRefillReminderEnabled}\n'
      'Viral Load Notifications: ${latestPreferenceAssessment?.vlNotificationEnabled}');
  await Future.delayed(Duration(seconds: 3));
  final bool success = false;
  if (success) {
    await _handleSuccess(patient, RequiredActionType.NOTIFICATIONS_UPLOAD_REQUIRED);
  } else {
    await _handleFailure(patient, RequiredActionType.NOTIFICATIONS_UPLOAD_REQUIRED);
    showFlushbar('Please upload the notifications preferences manually.',
      title: 'Upload of Notifications Preferences Failed',
      error: true,
      buttonText: 'Retry\nNow',
      onButtonPress: () {
        uploadNotificationsPreferences(patient, latestPreferenceAssessment);
      },
    );
  }
}

/// Patient Phone Number Update
Future<void> uploadPatientPhoneNumber(Patient patient, String phoneNumber) async {
  // TODO: upload the patient phone number to the visible impact database and if it didn't work show a message that the upload has to be retried manually
  // NOTE: [phoneNumber] can be null
  await Future.delayed(Duration(seconds: 3));
  final bool success = false;
  if (success) {
    await _handleSuccess(patient, RequiredActionType.PATIENT_PHONE_UPLOAD_REQUIRED);
  } else {
    await _handleFailure(patient, RequiredActionType.PATIENT_PHONE_UPLOAD_REQUIRED);
    showFlushbar('Please upload the patient phone number manually.',
      title: 'Upload of Patient Phone Number Failed',
      error: true,
      buttonText: 'Retry\nNow',
      onButtonPress: () {
        uploadPatientPhoneNumber(patient, phoneNumber);
      },
    );
  }
}

Future<bool> _uploadPeerEducatorPhoneNumber(List<String> patientARTs, String peerEducatorPhoneNumber) async {
  // TODO: upload the peer educator phone number to the visible impact database
  await Future.delayed(Duration(seconds: 3));
  final bool success = false;
  return success;
}

/// PE Phone Number Upload for single patient
///
/// Will be called during first preference assessment of a patient.
Future<void> uploadPeerEducatorPhoneNumber(String patientART, String peerEducatorPhoneNumber) async {
  final bool success = await _uploadPeerEducatorPhoneNumber([patientART], peerEducatorPhoneNumber);
  if (success) {
    final UserData user = await DatabaseProvider().retrieveLatestUserData();
    user.phoneNumberUploadRequired = false;
    await DatabaseProvider().insertUserData(user);
  } else {
    showFlushbar('Please upload your phone number manually.',
      title: 'Upload of Peer Educator Phone Number Failed',
      error: true,
      buttonText: 'Retry\nNow',
      onButtonPress: () {
        uploadPeerEducatorPhoneNumber(patientART, peerEducatorPhoneNumber);
      },
    );
  }
}

/// PE Phone Number Upload for all patients
///
/// Will be called when the Peer Educator changes their phone number and all of
/// their patients need to be updated on the VisibleImpact side.
///
/// Will also be called if a [uploadPeerEducatorPhoneNumber] for a single
/// patient failed and the PE triggers a re-sync from the settings screen.
Future<void> uploadPeerEducatorPhoneNumberForAllPatients(String peerEducatorPhoneNumber) async {
  List<String> patientARTNumbers = await DatabaseProvider().retrievePatientsART(retrieveNonConsents: false, retrieveNonEligibles: false);
  final bool success = await _uploadPeerEducatorPhoneNumber(patientARTNumbers, peerEducatorPhoneNumber);
  if (success) {
    final UserData user = await DatabaseProvider().retrieveLatestUserData();
    user.phoneNumberUploadRequired = false;
    await DatabaseProvider().insertUserData(user);
  } else {
    showFlushbar('Please upload your phone number manually.',
      title: 'Upload of Peer Educator Phone Number Failed',
      error: true,
      buttonText: 'Retry\nNow',
      onButtonPress: () {
        uploadPeerEducatorPhoneNumberForAllPatients(peerEducatorPhoneNumber);
      },
    );
  }
}

/// Throws [VisibleImpactLoginFailedException] if the authentication fails.
Future<String> _getAPIToken() async {
  String basicAuth = 'Basic ' + base64Encode(utf8.encode('$VI_USERNAME:$VI_PASSWORD'));
  http.Response _resp = await http.post(
    'https://lstowards909090.org/db-test/apiv1/token',
    headers: {'authorization': basicAuth},
  );
  if (_resp.statusCode != 200 || _resp.body == '') {
    print('_getAPIToken received:\n${_resp.statusCode}\n${_resp.body}');
    throw VisibleImpactLoginFailedException();
  }
  return jsonDecode(_resp.body)['token'];
}

/// Viral Load Measurements Download
///
/// Throws [VisibleImpactLoginFailedException] if the authentication fails.
///
/// Throws [PatientNotFoundException] if patient with given [patientART] number
/// is not found on VisibleImpact database.
///
/// Throws [MultiplePatientsException] if VisibleImpact returns more than one
/// patient ID for the given [patientART] number.
Future<List<ViralLoad>> downloadViralLoadsFromDatabase(String patientART) async {
  final String _token = await _getAPIToken();
  final List<int> patientIds = await _getPatientIdsVisibleImpact(patientART, _token);
  if (patientIds.isEmpty) {
    throw PatientNotFoundException('No patient with ART number $patientART found on VisibleImpact.');
  }
  if (patientIds.length > 1) {
    // TODO: decide how to handle this case (i.e. when there are duplicates)
    // -> a simple solution would be to just return all viral loads from all
    // duplicates (the user can still add manual entries to override the last
    // entry if it doesn't make sense)
    throw MultiplePatientsException('Several matching patients with ART number $patientART found on VisibleImpact.');
  }
  final _resp = await http.get(
    'https://lstowards909090.org/db-test/apiv1/labdata?patient_id=${patientIds.first}',
    headers: {'Authorization' : 'Custom $_token'},
  );
  if (_resp.statusCode == 401) {
    throw VisibleImpactLoginFailedException();
  } else if (_resp.statusCode != 200) {
    print('An unknown status code was returned while fetching viral loads from database.');
    print(_resp.statusCode);
    print(_resp.body);
    throw Exception('An unknown status code was returned while fetching viral loads from database.\n'
        'Status Code: ${_resp.statusCode}\n'
        'Response Body:\n${_resp.body}');
  }
  final List<dynamic> list = jsonDecode(_resp.body);
  List<ViralLoad> viralLoadsFromDB = list.map((dynamic vlLabResult) {
    final ViralLoad vl = ViralLoad(
      patientART: patientART,
      dateOfBloodDraw: DateTime.parse(vlLabResult['date_sample']),
      labNumber: vlLabResult['lab_number'],
      viralLoad: vlLabResult['lab_hivvmnumerical'],
      failed: vlLabResult['lab_hivvmnumerical'] == null,
      source: ViralLoadSource.DATABASE(),
    );
    return vl;
  }).toList();
  viralLoadsFromDB.sort((ViralLoad a, ViralLoad b) => a.dateOfBloodDraw.isBefore(b.dateOfBloodDraw) ? -1 : 1);
  if (viralLoadsFromDB.isNotEmpty && viralLoadsFromDB.last.failed) {
    RequiredAction vlRequired = RequiredAction(patientART, RequiredActionType.VIRAL_LOAD_MEASUREMENT_REQUIRED, DateTime.now());
    DatabaseProvider().insertRequiredAction(vlRequired);
    PatientBloc.instance.sinkRequiredActionData(vlRequired, false);
  }
  return viralLoadsFromDB;
}


/// Matches ART number to IDs on the VisibleImpact database.
///
/// @param [patientART] ART number to match. Can be a full ART number
/// (e.g. B/01/11111) or a partial ART number (e.g. B/01). Using a partial ART
/// number will find all patient IDs which partially match it.
Future<List<int>> _getPatientIdsVisibleImpact(String patientART, String _apiAuthToken) async {
  final _resp = await http.get(
    'https://lstowards909090.org/db-test/apiv1/patient?art_number=$patientART',
    headers: {'Authorization' : 'Custom $_apiAuthToken'},
  );
  if (_resp.statusCode != 200) {
    print(
        'An error occurred while fetching viral loads from database, returning null...');
    print(_resp.statusCode);
    print(_resp.body);
    // TODO: maybe return exception (this will most likely fail because of wrong authentication/invalid token)
    return null;
  }
  final List<dynamic> list = jsonDecode(_resp.body);
  List<int> patientIds = list.map((dynamic patientMap) {
    return patientMap['patient_id'] as int;
  }).toList();
  return patientIds;
}


Future<void> _handleSuccess(Patient patient, RequiredActionType actionType) async {
  print('$actionType uploaded to visible impact database successfully.');
  await DatabaseProvider().removeRequiredAction(patient.artNumber, actionType);
  PatientBloc.instance.sinkRequiredActionData(RequiredAction(patient.artNumber, actionType, null), true);
}

Future<void> _handleFailure(Patient patient, RequiredActionType actionType) async {
  final newAction = RequiredAction(patient.artNumber, actionType, DateTime.now());
  await DatabaseProvider().insertRequiredAction(newAction);
  PatientBloc.instance.sinkRequiredActionData(newAction, false);
}