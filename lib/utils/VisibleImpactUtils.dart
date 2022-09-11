import 'dart:convert';
import 'package:pebrapp/config/VisibleImpactConfig.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/ARTRefillReminderDaysBeforeSelection.dart';
import 'package:pebrapp/database/beans/Gender.dart';
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
import 'package:pebrapp/exceptions/VisibleImpactLoginFailedException.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:http/http.dart' as http;

/// Updates the patient's data on VisibleImpact.
///
/// @param [reUploadNotifications] The upload of the patient's phone number does
/// not affect the phone number to which the (previously uploaded) notifications
/// will be sent. If the patient's phone number changed and you want to update
/// the notifications to be sent to the new phone number, set
/// [reUploadNotifications] to true.
Future<void> uploadPatientCharacteristics(Patient patient,
    {bool reUploadNotifications: false, bool showNotification: true}) async {
  print('uploading patient characteristics to VisibleImpact...');
  try {
    final String token = await _getAPIToken();
    final int patientId = await _getPatientIdVisibleImpact(patient, token);
    String gender;
    if (patient.gender == Gender.MALE()) gender = "M";
    if (patient.gender == Gender.FEMALE()) gender = "F";
    Map<String, dynamic> body = {
      "patient_id": patientId,
      "mobile_phone": patient.phoneAvailability == PhoneAvailability.YES()
          ? _formatPhoneNumberForVI(patient.phoneNumber)
          : null,
      "mobile_owner": patient.phoneAvailability == PhoneAvailability.YES()
          ? "patient"
          : null,
      "birth_date": formatDateForVisibleImpact(patient.birthday),
      "sex": gender,
    };
    final _resp = await http.put(
      '$VI_API/patient',
      headers: {
        'Authorization': 'Custom $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    _checkStatusCode(_resp);
    _handleSuccess(
        patient, RequiredActionType.PATIENT_CHARACTERISTICS_UPLOAD_REQUIRED);
  } catch (e, s) {
    _handleFailure(
        patient, RequiredActionType.PATIENT_CHARACTERISTICS_UPLOAD_REQUIRED);
    if (showNotification) {
      showFlushbar(
        'The automatic upload of the participant\'s characteristics failed. Please upload manually.',
        title: 'Upload of Participant Characteristics Failed',
        error: true,
        buttonText: 'Retry\nNow',
        onButtonPress: () {
          uploadPatientCharacteristics(patient, reUploadNotifications: false);
        },
      );
    }
    print('Exception caught: $e');
    print('Stacktrace: $s');
  }
  if (reUploadNotifications) {
    await uploadNotificationsPreferences(patient);
  }
}

/// Update the patient_status on Visible Impact database
Future<bool> uploadPatientStatusVisibleImpact(Patient patient, String status,
    {bool reUploadNotifications: false, bool showNotification: true}) async {
  print('uploading patient status to VisibleImpact...');
  // Make sure the patient status is not empty
  if (status == "") {
    return false;
  }
  try {
    final String token = await _getAPIToken();
    final int patientId = await _getPatientIdVisibleImpact(patient, token);
    Map<String, dynamic> body = {
      "patient_id": patientId,
      "patient_status": status
    };
    final _resp = await http.put(
      '$VI_API/patient',
      headers: {
        'Authorization': 'Custom $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    _checkStatusCode(_resp);
    _handleSuccess(patient, RequiredActionType.PATIENT_STATUS_UPLOAD_REQUIRED);
    if (_resp.statusCode == 200) {
      return true;
    }
  } catch (e, s) {
    _handleFailure(patient, RequiredActionType.PATIENT_STATUS_UPLOAD_REQUIRED);
    if (showNotification) {
      showFlushbar(
        'The automatic upload of the participant\'s status failed. Please upload manually.',
        title: 'Upload of Participant Status Failed',
        error: true,
        buttonText: 'Retry\nNow',
        onButtonPress: () {
          uploadPatientStatusVisibleImpact(patient, status,
              reUploadNotifications: false);
        },
      );
    }
    print('Exception caught: $e');
    print('Stacktrace: $s');
  }
  if (reUploadNotifications) {
    await uploadPatientStatusVisibleImpact(patient, status);
  }
  return false;
}

/// Updates the peer educator's phone number by re-uploading all notifications
/// preferences for all patients. If there are a lot of patients this might take
/// a while.
///
/// If the upload is successful, the phoneNumberUploadRequired variable on the
/// UserData object is set to false and a AppStateSettingsRequiredActionData
/// event with isDone = true is sent.
///
/// Returns true if the upload was successful, false otherwise.
Future<bool> uploadPeerEducatorPhoneNumber() async {
  try {
    final UserData user = await DatabaseProvider().retrieveLatestUserData();
    final List<Patient> patients = await DatabaseProvider()
        .retrieveLatestPatients(
            retrieveNonEligibles: false, retrieveNonConsents: false);
    patients.removeWhere((Patient p) {
      final bool isActivated = p.isActivated ?? false;
      final PreferenceAssessment pa = p.latestPreferenceAssessment;
      final bool notificationsEnabled =
          (pa?.adherenceReminderEnabled ?? false) ||
              (pa?.artRefillReminderEnabled ?? false) ||
              (pa?.vlNotificationEnabled ?? false);
      return !isActivated || !notificationsEnabled;
    });
    if (patients.length <= 0) {
      print(
          'uploadPeerEducatorPhoneNumber: No activated patients with enabled notifications found. No notifications upload required.');
    } else {
      final String token = await _getAPIToken();
      for (Patient patient in patients) {
        // TODO: move the try-catch block inside this for loop so that if the
        //  upload fails for one patient the loop continues and the notification
        //  preferences for the remaining patients can still be uploaded
        final int patientId = await _getPatientIdVisibleImpact(patient, token);
        await _uploadAdherenceReminder(patient, patientId, token, pe: user);
        await _uploadRefillReminder(patient, patientId, token, pe: user);
        await _uploadViralLoadNotification(patient, patientId, token, pe: user);
      }
    }
    user.phoneNumberUploadRequired = false;
    await PatientBloc.instance.sinkSettingsRequiredActionData(true);
    await DatabaseProvider().insertUserData(user);
    return true;
  } catch (e, s) {
    showFlushbar(
      'The automatic upload of your phone number failed. Please upload manually.',
      title: 'Upload of Peer Educator Phone Number Failed',
      error: true,
      buttonText: 'Retry\nNow',
      onButtonPress: () {
        uploadPeerEducatorPhoneNumber();
      },
    );
    print('Exception caught: $e');
    print('Stacktrace: $s');
    return false;
  }
}

/// Upload notifications preferences from latest preference assessment.
///
/// Make sure that [patient.latestPreferenceAssessment] and
/// [patient.latestARTRefill] are up to date.
Future<void> uploadNotificationsPreferences(Patient patient) async {
  final PreferenceAssessment _pa = patient.latestPreferenceAssessment;
  if (!((_pa?.adherenceReminderEnabled ?? false) ||
      (_pa?.artRefillReminderEnabled ?? false) ||
      (_pa?.vlNotificationEnabled ?? false))) {
    print(
        'uploadNotificationsPreferences: No notifications enabled. No notifications upload required.');
    return;
  }
  try {
    final UserData pe = await DatabaseProvider().retrieveLatestUserData();
    final String token = await _getAPIToken();
    final int patientId = await _getPatientIdVisibleImpact(patient, token);
    await _uploadAdherenceReminder(patient, patientId, token, pe: pe);
    await _uploadRefillReminder(patient, patientId, token, pe: pe);
    await _uploadViralLoadNotification(patient, patientId, token, pe: pe);
    _handleSuccess(patient, RequiredActionType.NOTIFICATIONS_UPLOAD_REQUIRED);
  } catch (e, s) {
    _handleFailure(patient, RequiredActionType.NOTIFICATIONS_UPLOAD_REQUIRED);
    showFlushbar(
      'The automatic upload of the notifications failed. Please upload manually.',
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
Future<void> _uploadAdherenceReminder(
    Patient patient, int patientId, String token,
    {UserData pe}) async {
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
  if (artRefill == null || artRefill.refillType == RefillType.NOT_DONE())
    return;
  // adherence reminders disabled or null (patient has no phone), do not upload
  if (!(pa.adherenceReminderEnabled ?? false)) return;
  Map<String, dynamic> body = {
    "message_type": "adherence_reminder",
    "patient_id": patientId,
    "mobile_phone": _formatPhoneNumberForVI(patient.phoneNumber),
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
      'Authorization': 'Custom $token',
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
Future<void> _uploadRefillReminder(Patient patient, int patientId, String token,
    {UserData pe}) async {
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
  if (artRefill == null || artRefill.refillType == RefillType.NOT_DONE())
    return;
  // refill reminders disabled or null (patient has no phone), do not upload
  if (!(pa.artRefillReminderEnabled ?? false)) return;
  List<String> sendDates = calculateRefillReminderSendDates(
      pa.artRefillReminderDaysBefore, artRefill.nextRefillDate);
  Map<String, dynamic> body = {
    "message_type": "refill_reminder",
    "patient_id": patientId,
    "mobile_phone": _formatPhoneNumberForVI(patient.phoneNumber),
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
      'Authorization': 'Custom $token',
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
Future<void> _uploadViralLoadNotification(
    Patient patient, int patientId, String token,
    {UserData pe}) async {
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
    "mobile_phone": _formatPhoneNumberForVI(patient.phoneNumber),
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
    "message_failed":
        "Sephetho hasea sebetseha. Re kopa o itlalehe setsing sa bophelo mo o sebeletsoang teng hang hang, u hopotse mooki ka sephetho sa liteko!",
  };
  final _resp = await http.put(
    '$VI_API/pebramessage',
    headers: {
      'Authorization': 'Custom $token',
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
/// Throws [VisibleImpactLoginFailedException] if the authentication fails.
///
/// Throws [MultiplePatientsException] if VisibleImpact returns more than one
/// patient ID for the given [patientART] number.
///
/// Throws [HTTPStatusNotOKException] if the VisibleImpact API returns anything
/// else than 200 (OK).
Future<List<ViralLoad>> downloadViralLoadsFromDatabase(Patient patient) async {
  final String _token = await _getAPIToken();
  final int patientId = await _getPatientIdVisibleImpact(patient, _token);
  final _resp = await http.get(
    '$VI_API/labdata?patient_id=$patientId',
    headers: {'Authorization': 'Custom $_token'},
  );
  _checkStatusCode(_resp);
  final List<dynamic> list = jsonDecode(_resp.body);
  List<ViralLoad> viralLoadsFromDB = list.map((dynamic vlLabResult) {
    final ViralLoad vl = ViralLoad(
      patientART: patient.artNumber,
      dateOfBloodDraw: DateTime.parse(vlLabResult['date_sample']),
      labNumber: vlLabResult['lab_number'],
      viralLoad: vlLabResult['lab_hivvmnumerical'],
      failed: vlLabResult['lab_hivvmnumerical'] == null,
      source: ViralLoadSource.DATABASE(),
    );
    return vl;
  }).toList();
  // ignore viral loads which date back more than one year before patient's enrollment date
  viralLoadsFromDB.removeWhere((ViralLoad vl) => vl.dateOfBloodDraw.isBefore(
      DateTime(patient.enrollmentDate.year - 1, patient.enrollmentDate.month,
          patient.enrollmentDate.day)));
  viralLoadsFromDB.sort((ViralLoad a, ViralLoad b) =>
      a.dateOfBloodDraw.isBefore(b.dateOfBloodDraw) ? -1 : 1);
  if (viralLoadsFromDB.isNotEmpty && viralLoadsFromDB.last.failed) {
    // if the last viral load has failed, send the patient to blood draw
    RequiredAction vlRequired = RequiredAction(
        patient.artNumber,
        RequiredActionType.VIRAL_LOAD_MEASUREMENT_REQUIRED,
        DateTime.fromMillisecondsSinceEpoch(0));
    DatabaseProvider().insertRequiredAction(vlRequired);
    PatientBloc.instance.sinkRequiredActionData(vlRequired, false);
  }
  return viralLoadsFromDB;
}

List<String> calculateRefillReminderSendDates(
    ARTRefillReminderDaysBeforeSelection artRefillReminderDaysBefore,
    DateTime nextRefillDate) {
  List<String> sendDates = [];
  if (artRefillReminderDaysBefore.SEVEN_DAYS_BEFORE_selected) {
    sendDates.add(
        formatDateForVisibleImpact(nextRefillDate.subtract(Duration(days: 7))));
  }
  if (artRefillReminderDaysBefore.THREE_DAYS_BEFORE_selected) {
    sendDates.add(
        formatDateForVisibleImpact(nextRefillDate.subtract(Duration(days: 3))));
  }
  if (artRefillReminderDaysBefore.TWO_DAYS_BEFORE_selected) {
    sendDates.add(
        formatDateForVisibleImpact(nextRefillDate.subtract(Duration(days: 2))));
  }
  if (artRefillReminderDaysBefore.ONE_DAY_BEFORE_selected) {
    sendDates.add(
        formatDateForVisibleImpact(nextRefillDate.subtract(Duration(days: 1))));
  }
  if (artRefillReminderDaysBefore.ZERO_DAYS_BEFORE_selected) {
    sendDates.add(formatDateForVisibleImpact(nextRefillDate));
  }
  return sendDates;
}

/// Throws [VisibleImpactLoginFailedException] if the authentication fails.
Future<String> _getAPIToken() async {
  String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$VI_USERNAME:$VI_PASSWORD'));
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

/// Creates a new patient on VisibleImpact.
///
/// Returns the patient id created for this new patient by VisibleImpact.
///
/// Throws [SocketException] if there is no connection to VisibleImpact.
///
/// Throws [VisibleImpactLoginFailedException] if status code is 401.
///
/// Throws [HTTPStatusNotOKException] if status code is not 200.
Future<int> _createPatient(Patient patient, String apiToken,
    {VIPatientStatus status: VIPatientStatus.ACTIVE}) async {
  print('🌟 creating new patient on VisibleImpact...');
  String gender;
  if (patient.gender == Gender.MALE()) gender = "M";
  if (patient.gender == Gender.FEMALE()) gender = "F";
  Map<String, dynamic> body = {
    "art_number": patient.artNumber,
    "mobile_phone": patient.phoneAvailability == PhoneAvailability.YES()
        ? _formatPhoneNumberForVI(patient.phoneNumber)
        : null,
    "mobile_owner":
        patient.phoneAvailability == PhoneAvailability.YES() ? "patient" : null,
    "birth_date": formatDateForVisibleImpact(patient.birthday),
    "sex": gender,
    "patient_status": toStringVIPatientStatus(status),
  };
  final _resp = await http.post(
    '$VI_API/patient',
    headers: {
      'Authorization': 'Custom $apiToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );
  _checkStatusCode(_resp);
  return jsonDecode(_resp.body)['patient_id'];
}

/// Matches ART number to IDs on the VisibleImpact database. If the ART number
/// is not found on VisibleImpact, a new patient is created on VisibleImpact.
///
/// @param [patient] to look for on VisibleImpact (ART number is used for
/// lookup).
///
/// Throws [MultiplePatientsException] if VisibleImpact returns more than one
/// patient ID for the given [patientART] number.
///
/// Throws [VisibleImpactLoginFailedException] if status code is 401.
///
/// Throws [HTTPStatusNotOKException] if status code is not 200.
Future<int> _getPatientIdVisibleImpact(
    Patient patient, String _apiAuthToken) async {
  final _resp = await http.get(
    '$VI_API/patient?art_number=${patient.artNumber}',
    headers: {'Authorization': 'Custom $_apiAuthToken'},
  );
  _checkStatusCode(_resp);
  final List<dynamic> list = jsonDecode(_resp.body);
  List<int> patientIds = list.map((dynamic patientMap) {
    return patientMap['patient_id'] as int;
  }).toList();
  if (patientIds.isEmpty) {
    return _createPatient(patient, _apiAuthToken);
  }
  if (patientIds.length > 1) {
    // TODO: decide how to handle this case (i.e. when there are duplicates)
    // Try to find the proper entry by matching birth_date, sex, mobile_phone.
    // If the conflict can still not be resolved this way inform the user (make
    // them pick the correct entry for example).

    // Search for a matching patient object by comparing birth_date, sex and mobile_phone.
    var match = getMatchingPatient(list, patient);
    // If there is a match
    if (match != null) {
      // Assign the first element in the patientIds list to the patient_id of the match
      patientIds[0] = match['patient_id'];
    } else {
      showFlushbar(
          'Several matching patients with ART number ${patient.artNumber}\ found on VisibleImpact.',
          title: 'Resolve the issue',
          error: true);
      // set the duplicate flag in the database
      patient.isDuplicate = true;
      await DatabaseProvider().insertPatient(patient);
    }
  }
  return patientIds.first;
}

/// Format a patient's gender to a string (character) that can easily be stored in
/// the Visible Impact Database
///
/// if (patient.gender == Gender.MALE()) gender = "M";
///  if (patient.gender == Gender.FEMALE()) gender = "F";
String _formatGenderForVisibleImpact(Patient patient) {
  if (patient.gender == Gender.MALE()) {
    return "M";
  } else if (patient.gender == Gender.FEMALE()) {
    return "F";
  }
  return "";
}

/// Get a matching patient in a list of objects from the Visible Impact Database
/// Search through the list by matching the 'birth_date', 'sex' and 'mobile_phone'
/// of a patient.
///
/// Return a null object if there is no match and if there are multiple matches that
/// can not be resolved to one match
dynamic getMatchingPatient(List<dynamic> patients, Patient patient) {
  List<dynamic> matches = [];
  for (dynamic p in patients) {
    if (DateTime.parse(p['birth_date']).year == patient.birthday.year &&
        p['sex'] == _formatGenderForVisibleImpact(patient)) {
      matches.add(p);
    }
  }
  if (matches.length == 1) {
    return matches.first;
  }
  return null;
}

Future<void> _handleSuccess(
    Patient patient, RequiredActionType actionType) async {
  print('$actionType uploaded to visible impact database successfully.');
  await DatabaseProvider().removeRequiredAction(patient.artNumber, actionType);
  PatientBloc.instance.sinkRequiredActionData(
      RequiredAction(patient.artNumber, actionType, null), true);
}

Future<void> _handleFailure(
    Patient patient, RequiredActionType actionType) async {
  final newAction = RequiredAction(
      patient.artNumber, actionType, DateTime.fromMillisecondsSinceEpoch(0));
  await DatabaseProvider().insertRequiredAction(newAction);
  PatientBloc.instance.sinkRequiredActionData(newAction, false);
}

/// Checks whether the status code of [response] is 200. If it is not it either
/// throws a [VisibleImpactLoginFailedException] (if status code is 401) or a
/// [HTTPStatusNotOKException].
void _checkStatusCode(http.Response response) {
  if (response.statusCode == 401) {
    throw VisibleImpactLoginFailedException();
  } else if (response.statusCode != 200) {
    print(
        'An unknown status code was returned while interacting with VisibleImpact.');
    print(response.statusCode);
    print(response.body);
    throw HTTPStatusNotOKException(
        'An unknown status code was returned while interacting with VisibleImpact.\n'
        'Status Code: ${response.statusCode}\n'
        'Response Body:\n${response.body}');
  }
}

/// Removes all '-' from the [phoneNumber] string so that we get a phone number
/// in the form '+26612345678' as expected by the VisibleImpact API.
String _formatPhoneNumberForVI(String phoneNumber) {
  return phoneNumber.replaceAll(RegExp(r'[-]'), '');
}

enum VIPatientStatus { ACTIVE, DEAD, LTFU, TRANSFEROUT }

String toStringVIPatientStatus(VIPatientStatus status) {
  String statusString;
  switch (status) {
    case VIPatientStatus.ACTIVE:
      statusString = 'active';
      break;
    case VIPatientStatus.DEAD:
      statusString = 'dead';
      break;
    case VIPatientStatus.LTFU:
      statusString = 'ltfu';
      break;
    case VIPatientStatus.TRANSFEROUT:
      statusString = 'transferout';
  }
  return statusString;
}
