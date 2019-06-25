
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/Utils.dart';

Future<void> uploadNextARTRefillDate(Patient patient, DateTime nextARTRefillDate) async {
  // TODO: upload the new date to the visible impact database and if it didn't work show a message that the upload has to be retried manually
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

Future<void> _handleSuccess(Patient patient, RequiredActionType actionType) async {
  print('$actionType uploaded to visible impact database successfully.');
  patient.requiredActions.removeWhere((RequiredAction action) => action.type == actionType);
  await DatabaseProvider().removeRequiredAction(patient.artNumber, actionType);
  PatientBloc.instance.sinkRequiredActionData(RequiredAction(patient.artNumber, actionType, null), true);
}

Future<void> _handleFailure(Patient patient, RequiredActionType actionType) async {
  final newAction = RequiredAction(patient.artNumber, actionType, DateTime.now());
  patient.requiredActions.add(newAction);
  await DatabaseProvider().insertRequiredAction(newAction);
  PatientBloc.instance.sinkRequiredActionData(newAction, false);
}