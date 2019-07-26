
import 'dart:convert';
import 'package:pebrapp/config/VisibleImpactConfig.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/RefillType.dart';
import 'package:pebrapp/database/beans/ViralLoadSource.dart';
import 'package:pebrapp/database/models/ARTRefill.dart';
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


/// Adherence Reminder Upload
///
/// Make sure that [patient.latestPreferenceAssessment] and
/// [patient.latestARTRefill] are up to date.
Future<void> uploadAdherenceReminder(Patient patient) async {
  final PreferenceAssessment pa = patient.latestPreferenceAssessment;
  final ARTRefill artRefill = patient.latestARTRefill;
  if (artRefill == null || artRefill.refillType == RefillType.NOT_DONE()) {
    // no next ART refill date yet or refill not done, do not upload
    return;
  }
  if (!(pa.adherenceReminderEnabled ?? false)) {
    // adherence reminders disabled or null (patient has no phone), do not upload
    return;
  }
  final String _token = await _getAPIToken();
  final int patientId = await _getPatientIdVisibleImpact(patient.artNumber, _token);
  final _resp = await http.put(
    'https://lstowards909090.org/db-test/apiv1/pebramessage',
    headers: {'Authorization' : 'Custom $_token'},
    body: {
      "message_type": "adherence_reminder",
      "patient_id": patientId,
      "mobile_phone": patient.phoneNumber,
      "send_frequency": pa.adherenceReminderFrequency.visibleImpactAPIString,
      "mobile_owner": "patient",
      "send_time": formatTimeForVisibleImpact(pa.adherenceReminderTime),
      "message": pa.adherenceReminderMessage.description,
      "end_date": formatDateForVisibleImpact(artRefill.nextRefillDate),
    }
  );
  // TODO: error handling
  // TODO: what required action types will we need?
  //   - just one general "notification upload required"
  //   - seperate ones for "adherence reminder upload required", "refill reminder upload required", "vl notification upload required"
  if (_resp.statusCode == 200) {
    _handleSuccess(patient, RequiredActionType.NOTIFICATIONS_UPLOAD_REQUIRED);
  } else {
    _handleFailure(patient, RequiredActionType.NOTIFICATIONS_UPLOAD_REQUIRED);
  }

}


/// Refill Reminder Upload
Future<void> uploadRefillReminder(Patient patient, PreferenceAssessment latestPreferenceAssessment) async {
  // TODO: implement refill reminder upload logic
}


/// Viral Load Notifications Upload
Future<void> uploadViralLoadNotification(Patient patient, PreferenceAssessment latestPreferenceAssessment) async {
  // TODO: implement vl notification upload logic
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
  final int patientId = await _getPatientIdVisibleImpact(patientART, _token);
  final _resp = await http.get(
    'https://lstowards909090.org/db-test/apiv1/labdata?patient_id=$patientId',
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
///
/// Throws [PatientNotFoundException] if patient with given [patientART] number
/// is not found on VisibleImpact database.
///
/// Throws [MultiplePatientsException] if VisibleImpact returns more than one
/// patient ID for the given [patientART] number.
Future<int> _getPatientIdVisibleImpact(String patientART, String _apiAuthToken) async {
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
  return patientIds.first;
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