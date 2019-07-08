
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
import 'package:pebrapp/database/models/UserData.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/Utils.dart';

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
      'Adherence Reminder: ${latestPreferenceAssessment.adherenceReminderEnabled}\n'
      'ART Refill Reminder: ${latestPreferenceAssessment.artRefillReminderEnabled}\n'
      'Viral Load Notifications: ${latestPreferenceAssessment.vlNotificationEnabled}');
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

/// Viral Load Measurements Download
Future<List<ViralLoad>> downloadViralLoadsFromDatabase(String patientART) async {
  // TODO: fetch all viral loads for the given [patientART]
  return null;
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