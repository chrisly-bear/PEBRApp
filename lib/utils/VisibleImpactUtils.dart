
import 'dart:convert';
import 'package:pebrapp/config/VisibleImpactConfig.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/ARTRefillReminderDaysBeforeSelection.dart';
import 'package:pebrapp/database/beans/PhoneAvailability.dart';
import 'package:pebrapp/database/beans/RefillType.dart';
import 'package:pebrapp/database/beans/ViralLoadSource.dart';
import 'package:pebrapp/database/models/ARTRefill.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
import 'package:pebrapp/database/models/UserData.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/exceptions/HTTPStatusNotOKException.dart';
import 'package:pebrapp/exceptions/MultiplePatientsException.dart';
import 'package:pebrapp/exceptions/PatientNotFoundException.dart';
import 'package:pebrapp/exceptions/VisibleImpactLoginFailedException.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:http/http.dart' as http;

/// Updates the patient's phone number on the VisibleImpact database.
///
/// @param [reUploadNotifications] The upload of the patient's phone number does
/// not affect the phone number to which the (previously uploaded) notifications
/// will be sent. If you want to update the notifications to be sent to the new
/// phone number, set [reUploadNotifications] to true.
Future<void> uploadPatientPhoneNumber(Patient patient, {bool reUploadNotifications: false}) async {
  try {
    final String token = await _getAPIToken();
    final int patientId = await _getPatientIdVisibleImpact(patient.artNumber, token);
    Map<String, dynamic> body = {
      "patient_id": patientId,
      "mobile_phone": patient.phoneAvailability == PhoneAvailability.YES() ? _formatPhoneNumberForVI(patient.phoneNumber) : null,
      "mobile_owner": patient.phoneAvailability == PhoneAvailability.YES() ? "patient" : null,
    };
    final _resp = await http.put(
      '$VI_API/patient',
      headers: {
        'Authorization' : 'Custom $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    _checkStatusCode(_resp);
    _handleSuccess(patient, RequiredActionType.PATIENT_PHONE_UPLOAD_REQUIRED);
  } catch (e, s) {
    _handleFailure(patient, RequiredActionType.PATIENT_PHONE_UPLOAD_REQUIRED);
    showFlushbar('The automatic upload of the patient\'s phone number failed. Please upload manually.',
      title: 'Upload of Patient Phone Number Failed',
      error: true,
      buttonText: 'Retry\nNow',
      onButtonPress: () {
        uploadPatientPhoneNumber(patient, reUploadNotifications: false);
      },
    );
    print('Exception caught: $e');
    print('Stacktrace: $s');
  }
  if (reUploadNotifications) {
    await uploadNotificationsPreferences(patient);
  }
}


/// Updates the peer educator's phone number by re-uploading all notifications
/// preferences for all patients. If there are a lot of patients this might take
/// a while.
Future<void> uploadPeerEducatorPhoneNumber() async {
  try {
    final UserData user = await DatabaseProvider().retrieveLatestUserData();
    final List<Patient> patients = await DatabaseProvider().retrieveLatestPatients(retrieveNonEligibles: false, retrieveNonConsents: false);
    patients.removeWhere((Patient p) => !(p.isActivated ?? false));
    final String token = await _getAPIToken();
    for (Patient patient in patients) {
      final int patientId = await _getPatientIdVisibleImpact(patient.artNumber, token);
      await _uploadAdherenceReminder(patient, patientId, token, pe: user);
      await _uploadRefillReminder(patient, patientId, token, pe: user);
      await _uploadViralLoadNotification(patient, patientId, token, pe: user);
    }
    user.phoneNumberUploadRequired = false;
    await DatabaseProvider().insertUserData(user);
  } catch (e, s) {
    showFlushbar('The automatic upload of your phone number failed. Please upload manually.',
      title: 'Upload of Peer Educator Phone Number Failed',
      error: true,
      buttonText: 'Retry\nNow',
      onButtonPress: () {
        uploadPeerEducatorPhoneNumber();
      },
    );
    print('Exception caught: $e');
    print('Stacktrace: $s');
  }
}


/// Upload notifications preferences from latest preference assessment.
///
/// Make sure that [patient.latestPreferenceAssessment] and
/// [patient.latestARTRefill] are up to date.
Future<void> uploadNotificationsPreferences(Patient patient) async {
  try {
    final UserData pe = await DatabaseProvider().retrieveLatestUserData();
    final String token = await _getAPIToken();
    final int patientId = await _getPatientIdVisibleImpact(patient.artNumber, token);
    await _uploadAdherenceReminder(patient, patientId, token, pe: pe);
    await _uploadRefillReminder(patient, patientId, token, pe: pe);
    await _uploadViralLoadNotification(patient, patientId, token, pe: pe);
    _handleSuccess(patient, RequiredActionType.NOTIFICATIONS_UPLOAD_REQUIRED);
  } catch (e, s) {
    _handleFailure(patient, RequiredActionType.NOTIFICATIONS_UPLOAD_REQUIRED);
    showFlushbar('The automatic upload of the notifications failed. Please upload manually.',
      title: 'Upload of Notifications Failed',
      error: true,
      buttonText: 'Retry\nNow',
      onButtonPress: () {
        uploadNotificationsPreferences(patient);
      },
    );
    print('Exception caught: $e');
    print('Stacktrace: $s');
  }
}


/// Adherence Reminder Upload
///
/// Make sure that [patient.latestPreferenceAssessment] and
/// [patient.latestARTRefill] are up to date.
///
/// Throws [VisibleImpactLoginFailedException] if the authentication fails.
///
/// Throws [HTTPStatusNotOKException] if the VisibleImpact API returns anything
/// else than 200 (OK).
Future<void> _uploadAdherenceReminder(Patient patient, int patientId, String token, {UserData pe}) async {
  if (pe == null) {
    pe = await DatabaseProvider().retrieveLatestUserData();
  }
  final PreferenceAssessment pa = patient.latestPreferenceAssessment;
  final ARTRefill artRefill = patient.latestARTRefill;
  // patient is deactivated, do not upload
  if (!(patient.isActivated ?? false)) return;
  // no preference assessment yet, do not upload
  if (pa == null) return;
  // no next ART refill date yet or refill not done, do not upload
  if (artRefill == null || artRefill.refillType == RefillType.NOT_DONE()) return;
  // adherence reminders disabled or null (patient has no phone), do not upload
  if (!(pa.adherenceReminderEnabled ?? false)) return;
  Map<String, dynamic> body = {
    "message_type": "adherence_reminder",
    "patient_id": patientId,
    "mobile_phone": patient.phoneNumber,
    "send_frequency": pa.adherenceReminderFrequency.visibleImpactAPIString,
    "mobile_owner": "patient",
    "send_time": formatTimeForVisibleImpact(pa.adherenceReminderTime),
    "message": composeSMS(
      message: pa.adherenceReminderMessage.description,
      peName: '${pe.firstName} ${pe.lastName}',
      pePhone: pe.phoneNumber,
    ),
    "end_date": formatDateForVisibleImpact(artRefill.nextRefillDate),
  };
  final _resp = await http.put(
    '$VI_API/pebramessage',
    headers: {
      'Authorization' : 'Custom $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );
  _checkStatusCode(_resp);
}


/// Refill Reminder Upload
///
/// Make sure that [patient.latestPreferenceAssessment] and
/// [patient.latestARTRefill] are up to date.
///
/// Throws [VisibleImpactLoginFailedException] if the authentication fails.
///
/// Throws [HTTPStatusNotOKException] if the VisibleImpact API returns anything
/// else than 200 (OK).
Future<void> _uploadRefillReminder(Patient patient, int patientId, String token, {UserData pe}) async {
  if (pe == null) {
    pe = await DatabaseProvider().retrieveLatestUserData();
  }
  final PreferenceAssessment pa = patient.latestPreferenceAssessment;
  final ARTRefill artRefill = patient.latestARTRefill;
  // patient is deactivated, do not upload
  if (!(patient.isActivated ?? false)) return;
  // no preference assessment yet, do not upload
  if (pa == null) return;
  // no next ART refill date yet or refill not done, do not upload
  if (artRefill == null || artRefill.refillType == RefillType.NOT_DONE()) return;
  // refill reminders disabled or null (patient has no phone), do not upload
  if (!(pa.artRefillReminderEnabled ?? false)) return;
  List<String> sendDates = calculateRefillReminderSendDates(pa.artRefillReminderDaysBefore, artRefill.nextRefillDate);
  Map<String, dynamic> body = {
    "message_type": "refill_reminder",
    "patient_id": patientId,
    "mobile_phone": patient.phoneNumber,
    "send_dates": sendDates,
    "mobile_owner": "patient",
    "message": composeSMS(
      message: pa.artRefillReminderMessage.description,
      peName: '${pe.firstName} ${pe.lastName}',
      pePhone: pe.phoneNumber,
    ),
  };
  final _resp = await http.put(
    '$VI_API/pebramessage',
    headers: {
      'Authorization' : 'Custom $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );
  _checkStatusCode(_resp);
}


/// Viral Load Notifications Upload
///
/// Make sure that [patient.latestPreferenceAssessment] is up to date.
///
/// Throws [VisibleImpactLoginFailedException] if the authentication fails.
///
/// Throws [HTTPStatusNotOKException] if the VisibleImpact API returns anything
/// else than 200 (OK).
Future<void> _uploadViralLoadNotification(Patient patient, int patientId, String token, {UserData pe}) async {
  if (pe == null) {
    pe = await DatabaseProvider().retrieveLatestUserData();
  }
  final PreferenceAssessment pa = patient.latestPreferenceAssessment;
  // patient is deactivated, do not upload
  if (!(patient.isActivated ?? false)) return;
  // no preference assessment yet, do not upload
  if (pa == null) return;
  // viral load notifications disabled or null (patient has no phone), do not upload
  if (!(pa.vlNotificationEnabled ?? false)) return;
  Map<String, dynamic> body = {
    "message_type": "vl_notification",
    "patient_id": patientId,
    "mobile_phone": patient.phoneNumber,
    "active": true,
    "mobile_owner": "patient",
    "message_suppressed": composeSMS(
      message: pa.vlNotificationMessageSuppressed.description,
      peName: '${pe.firstName} ${pe.lastName}',
      pePhone: pe.phoneNumber,
    ),
    "message_unsuppressed": composeSMS(
      message: pa.vlNotificationMessageUnsuppressed.description,
      peName: '${pe.firstName} ${pe.lastName}',
      pePhone: pe.phoneNumber,
    ),
    "message_failed": "Sephetho hasea sebetseha. Re kopa o itlalehe setsing sa bophelo mo o sebeletsoang teng hang hang, u hopotse mooki ka sephetho sa liteko!",
  };
  final _resp = await http.put(
    '$VI_API/pebramessage',
    headers: {
      'Authorization' : 'Custom $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );
  _checkStatusCode(_resp);
}


/// Viral Load Measurements Download
///
/// Fetches viral loads from VisibleImpact that date back one year before the
/// enrollmentDate or less. The resulting list will be sorted by date of blood
/// draw (oldest first). If the latest viral load has status 'failed' a viral
/// load required action will be created.
///
/// @param [enrollmentDate] The patient's enrollment date. This is used to
/// filter out any viral loads that date back more than one year before the
/// [enrollmentDate].
///
/// Throws [VisibleImpactLoginFailedException] if the authentication fails.
///
/// Throws [PatientNotFoundException] if patient with given [patientART] number
/// is not found on VisibleImpact database.
///
/// Throws [MultiplePatientsException] if VisibleImpact returns more than one
/// patient ID for the given [patientART] number.
///
/// Throws [HTTPStatusNotOKException] if the VisibleImpact API returns anything
/// else than 200 (OK).
Future<List<ViralLoad>> downloadViralLoadsFromDatabase(String patientART, DateTime enrollmentDate) async {
  final String _token = await _getAPIToken();
  final int patientId = await _getPatientIdVisibleImpact(patientART, _token);
  final _resp = await http.get(
    '$VI_API/labdata?patient_id=$patientId',
    headers: {'Authorization' : 'Custom $_token'},
  );
  _checkStatusCode(_resp);
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
  viralLoadsFromDB.removeWhere((ViralLoad vl) => vl.dateOfBloodDraw.isBefore(enrollmentDate));
  viralLoadsFromDB.sort((ViralLoad a, ViralLoad b) => a.dateOfBloodDraw.isBefore(b.dateOfBloodDraw) ? -1 : 1);
  if (viralLoadsFromDB.isNotEmpty && viralLoadsFromDB.last.failed) {
    // if the last viral load has failed, send the patient to blood draw
    RequiredAction vlRequired = RequiredAction(patientART, RequiredActionType.VIRAL_LOAD_MEASUREMENT_REQUIRED, DateTime.fromMillisecondsSinceEpoch(0));
    DatabaseProvider().insertRequiredAction(vlRequired);
    PatientBloc.instance.sinkRequiredActionData(vlRequired, false);
  }
  return viralLoadsFromDB;
}


List<String> calculateRefillReminderSendDates(ARTRefillReminderDaysBeforeSelection artRefillReminderDaysBefore, DateTime nextRefillDate) {
  List<String> sendDates = [];
  if (artRefillReminderDaysBefore.SEVEN_DAYS_BEFORE_selected) {
    sendDates.add(formatDateForVisibleImpact(nextRefillDate.subtract(Duration(days: 7))));
  }
  if (artRefillReminderDaysBefore.THREE_DAYS_BEFORE_selected) {
    sendDates.add(formatDateForVisibleImpact(nextRefillDate.subtract(Duration(days: 3))));
  }
  if (artRefillReminderDaysBefore.TWO_DAYS_BEFORE_selected) {
    sendDates.add(formatDateForVisibleImpact(nextRefillDate.subtract(Duration(days: 2))));
  }
  if (artRefillReminderDaysBefore.ONE_DAY_BEFORE_selected) {
    sendDates.add(formatDateForVisibleImpact(nextRefillDate.subtract(Duration(days: 1))));
  }
  if (artRefillReminderDaysBefore.ZERO_DAYS_BEFORE_selected) {
    sendDates.add(formatDateForVisibleImpact(nextRefillDate));
  }
  return sendDates;
}


/// Throws [VisibleImpactLoginFailedException] if the authentication fails.
Future<String> _getAPIToken() async {
  String basicAuth = 'Basic ' + base64Encode(utf8.encode('$VI_USERNAME:$VI_PASSWORD'));
  http.Response _resp = await http.post(
    '$VI_API/token',
    headers: {'authorization': basicAuth},
  );
  if (_resp.statusCode != 200 || _resp.body == '') {
    print('_getAPIToken received:\n${_resp.statusCode}\n${_resp.body}');
    throw VisibleImpactLoginFailedException();
  }
  return jsonDecode(_resp.body)['token'];
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
    '$VI_API/patient?art_number=$patientART',
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
    // TODO: create patient with the given ART number instead of throwing this exception
    // -> the VI API returns the patient json object with the newly created patient_id
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
  final newAction = RequiredAction(patient.artNumber, actionType, DateTime.fromMillisecondsSinceEpoch(0));
  await DatabaseProvider().insertRequiredAction(newAction);
  PatientBloc.instance.sinkRequiredActionData(newAction, false);
}


void _checkStatusCode(http.Response response) {
  if (response.statusCode == 401) {
    throw VisibleImpactLoginFailedException();
  } else if (response.statusCode != 200) {
    print('An unknown status code was returned while interacting with VisibleImpact.');
    print(response.statusCode);
    print(response.body);
    throw HTTPStatusNotOKException('An unknown status code was returned while interacting with VisibleImpact.\n'
        'Status Code: ${response.statusCode}\n'
        'Response Body:\n${response.body}');
  }
}

/// Removes all '-' from the [phoneNumber] string so that we get a phone number
/// in the form '+26612345678' as expected by the VisibleImpact API.
String _formatPhoneNumberForVI(String phoneNumber) {
  return phoneNumber.replaceAll(RegExp(r'[-]'), '');
}
