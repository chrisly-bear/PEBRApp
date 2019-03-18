import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';

void showFlushBar(BuildContext context, String message, {String title}) {
  Flushbar()
    ..title = title
    ..messageText = Text(message, textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 18.0))
    ..duration = Duration(seconds: 5)
    ..show(context);
}

String artRefillOptionToString(ARTRefillOption option) {
  String returnString;
  switch (option) {
    case ARTRefillOption.CLINIC:
      returnString = "Clinic";
      break;
    case ARTRefillOption.PE_HOME_DELIVERY:
      returnString = "Home Delivery PE";
      break;
    case ARTRefillOption.VHW:
      returnString = "VHW";
      break;
    case ARTRefillOption.TREATMENT_BUDDY:
      returnString = "Treatment Buddy";
      break;
    case ARTRefillOption.COMMUNITY_ADHERENCE_CLUB:
      returnString = "Community Adherence Club";
      break;
  }
  return returnString;
}

String adherenceReminderFrequencyToString(AdherenceReminderFrequency frequency) {
  String returnString;
  switch (frequency) {
    case AdherenceReminderFrequency.DAILY:
      returnString = "Daily";
      break;
    case AdherenceReminderFrequency.WEEKLY:
      returnString = "Weekly";
      break;
    case AdherenceReminderFrequency.MONTHLY:
      returnString = "Monthly";
      break;
  }
  return returnString;
}

String eacOptionToString(EACOption option) {
  String returnString;
  switch (option) {
    case EACOption.HOME:
      returnString = "Home";
      break;
    case EACOption.NURSE:
      returnString = "Nurse";
      break;
    case EACOption.PHONE:
      returnString = "Phone";
      break;
  }
  return returnString;
}
