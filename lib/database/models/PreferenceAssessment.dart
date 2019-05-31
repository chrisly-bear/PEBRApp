import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pebrapp/database/DatabaseExporter.dart';
import 'package:pebrapp/database/beans/ARTRefillReminderMessage.dart';
import 'package:pebrapp/database/beans/ARTSupplyAmount.dart';
import 'package:pebrapp/database/beans/CondomUsageNotDemonstratedReason.dart';
import 'package:pebrapp/database/beans/HomeVisitPENotPossibleReason.dart';
import 'package:pebrapp/database/beans/PEHomeDeliveryNotPossibleReason.dart';
import 'package:pebrapp/database/beans/PitsoPENotPossibleReason.dart';
import 'package:pebrapp/database/beans/SchoolVisitPENotPossibleReason.dart';
import 'package:pebrapp/database/beans/SupportPreferencesSelection.dart';
import 'package:pebrapp/database/beans/YesNoRefused.dart';
import 'package:pebrapp/utils/Utils.dart';

class PreferenceAssessment implements IExcelExportable {
  static final tableName = 'PreferenceAssessment';

  // column names
  static final colId = 'id'; // primary key
  static final colPatientART = 'patient_art'; // foreign key to [Patient].art_number
  static final colCreatedDate = 'created_date_utc';
  static final colARTRefillOption1 = 'art_refill_option_1';
  static final colARTRefillOption2 = 'art_refill_option_2'; // nullable
  static final colARTRefillOption3 = 'art_refill_option_3'; // nullable
  static final colARTRefillOption4 = 'art_refill_option_4'; // nullable
  static final colARTRefillOption5 = 'art_refill_option_5'; // nullable
  static final colARTRefillPENotPossibleReason = 'art_refill_pe_not_possible_reason'; // nullable
  static final colARTRefillPENotPossibleReasonOther = 'art_refill_pe_not_possible_reason_other'; // nullable
  static final colARTRefillVHWName = 'art_refill_vhw_name'; // nullable
  static final colARTRefillVHWVillage = 'art_refill_vhw_village'; // nullable
  static final colARTRefillVHWPhoneNumber = 'art_refill_vhw_phone_number'; // nullable
  static final colARTRefillTreatmentBuddyART = 'art_refill_treatment_buddy_art'; // nullable
  static final colARTRefillTreatmentBuddyVillage = 'art_refill_treatment_buddy_village'; // nullable
  static final colARTRefillTreatmentBuddyPhoneNumber = 'art_refill_treatment_buddy_phone_number'; // nullable
  static final colARTSupplyAmount = 'art_supply_amount';
  static final colPhoneAvailable = 'phone_available';
  static final colPatientPhoneNumber = 'patient_phone_number'; // nullable
  static final colAdherenceReminderEnabled = 'adherence_reminder_enabled'; // nullable
  static final colAdherenceReminderFrequency = 'adherence_reminder_frequency'; // nullable
  static final colAdherenceReminderTime = 'adherence_reminder_time'; // nullable
  static final colAdherenceReminderMessage = 'adherence_reminder_message'; // nullable
  static final colARTRefillReminderEnabled = 'art_refill_reminder_enabled'; // nullable
  static final colARTRefillReminderDaysBefore = 'art_refill_reminder_days_before'; // nullable
  static final colARTRefillReminderMessage = 'art_refill_reminder_message'; // nullable
  static final colVLNotificationEnabled = 'vl_notification_enabled'; // nullable
  static final colVLNotificationMessageSuppressed = 'vl_notification_message_suppressed'; // nullable
  static final colVLNotificationMessageUnsuppressed = 'vl_notification_message_unsuppressed'; // nullable
  static final colPEPhoneNumber = 'pe_phone_number'; // nullable
  static final colSupportPreferences = 'support_preferences';
  static final colSaturdayClinicClubAvailable = 'saturday_clinic_club_available'; // nullable
  static final colCommunityYouthClubAvailable = 'community_youth_club_available'; // nullable
  static final colHomeVisitPEPossible = 'home_visit_pe_possible'; // nullable
  static final colHomeVisitPENotPossibleReason = 'home_visit_pe_not_possible_reason'; // nullable
  static final colHomeVisitPENotPossibleReasonOther = 'home_visit_pe_not_possible_reason_other'; // nullable
  static final colSchoolVisitPEPossible = 'school_visit_pe_possible'; // nullable
  static final colSchool = 'school'; // nullable
  static final colSchoolVisitPENotPossibleReason = 'school_visit_pe_not_possible_reason'; // nullable
  static final colSchoolVisitPENotPossibleReasonOther = 'school_visit_pe_not_possible_reason_other'; // nullable
  static final colPitsoPEPossible = 'pitso_pe_possible'; // nullable
  static final colPitsoPENotPossibleReason = 'pitso_pe_not_possible_reason'; // nullable
  static final colPitsoPENotPossibleReasonOther = 'pitso_pe_not_possible_reason_other'; // nullable
  static final colCondomUsageDemonstrated = 'condom_usage_demonstrated'; // nullable
  static final colCondomUsageNotDemonstratedReason = 'condom_usage_not_demonstrated_reason'; // nullable
  static final colCondomUsageNotDemonstratedReasonOther = 'condom_usage_not_demonstrated_reason_other'; // nullable
  static final colMoreInfoContraceptives = 'more_info_contraceptives'; // nullable
  static final colMoreInfoVMMC = 'more_info_vmmc'; // nullable
  static final colYoungMothersAvailable = 'young_mothers_available'; // nullable
  static final colFemaleWorthAvailable = 'female_worth_available'; // nullable
  static final colLegalAidSmartphoneAvailable = 'legal_aid_smartphone_available'; // nullable
  static final colTuneMeSmartphoneAvailable = 'tuneme_smartphone_available'; // nullable
  static final colNtlafatsoSmartphoneAvailable = 'ntlafatso_smartphone_available'; // nullable
  static final colPsychosocialShareSomethingAnswer = 'psychosocial_share_something';
  static final colPsychosocialShareSomethingContent = 'psychosocial_share_something_content'; // nullable
  static final colPsychosocialHowDoing = 'psychosocial_how_doing'; // nullable
  static final colUnsuppressedSafeEnvironmentAnswer = 'unsuppressed_safe_env_answer'; // nullable
  static final colUnsuppressedWhyNotSafe = 'unsuppressed_why_not_safe_env'; // nullable

  String patientART;
  DateTime _createdDate;
  ARTRefillOption artRefillOption1;
  ARTRefillOption artRefillOption2;
  ARTRefillOption artRefillOption3;
  ARTRefillOption artRefillOption4;
  ARTRefillOption artRefillOption5;
  PEHomeDeliveryNotPossibleReason artRefillPENotPossibleReason;
  String artRefillPENotPossibleReasonOther;
  String artRefillVHWName;
  String artRefillVHWVillage;
  String artRefillVHWPhoneNumber;
  String artRefillTreatmentBuddyART;
  String artRefillTreatmentBuddyVillage;
  String artRefillTreatmentBuddyPhoneNumber;
  ARTSupplyAmount artSupplyAmount;
  bool phoneAvailable;
  String patientPhoneNumber;
  bool adherenceReminderEnabled;
  AdherenceReminderFrequency adherenceReminderFrequency;
  TimeOfDay adherenceReminderTime;
  AdherenceReminderMessage adherenceReminderMessage;
  bool artRefillReminderEnabled;
  ARTRefillReminderDaysBeforeSelection artRefillReminderDaysBefore;
  ARTRefillReminderMessage artRefillReminderMessage;
  bool vlNotificationEnabled;
  VLSuppressedMessage vlNotificationMessageSuppressed;
  VLUnsuppressedMessage vlNotificationMessageUnsuppressed;
  String pePhoneNumber;
  SupportPreferencesSelection supportPreferences = SupportPreferencesSelection();
  bool saturdayClinicClubAvailable;
  bool communityYouthClubAvailable;
  bool homeVisitPEPossible;
  HomeVisitPENotPossibleReason homeVisitPENotPossibleReason;
  String homeVisitPENotPossibleReasonOther;
  bool schoolVisitPEPossible;
  String school;
  SchoolVisitPENotPossibleReason schoolVisitPENotPossibleReason;
  String schoolVisitPENotPossibleReasonOther;
  bool pitsoPEPossible;
  PitsoPENotPossibleReason pitsoPENotPossibleReason;
  String pitsoPENotPossibleReasonOther;
  bool condomUsageDemonstrated;
  CondomUsageNotDemonstratedReason condomUsageNotDemonstratedReason;
  String condomUsageNotDemonstratedReasonOther;
  String moreInfoContraceptives;
  String moreInfoVMMC;
  bool youngMothersAvailable;
  bool femaleWorthAvailable;
  bool legalAidSmartphoneAvailable;
  bool tuneMeSmartphoneAvailable;
  bool ntlafatsoSmartphoneAvailable;
  YesNoRefused psychosocialShareSomethingAnswer;
  String psychosocialShareSomethingContent;
  String psychosocialHowDoing;
  YesNoRefused unsuppressedSafeEnvironmentAnswer;
  String unsuppressedWhyNotSafe;


  // Constructors
  // ------------

  PreferenceAssessment(
      this.patientART,
      this.artRefillOption1,
      this.phoneAvailable,
      this.supportPreferences,
      this.artSupplyAmount,
      this.psychosocialShareSomethingAnswer,
      {
        this.artRefillOption2,
        this.artRefillOption3,
        this.artRefillOption4,
        this.artRefillOption5,
        this.artRefillPENotPossibleReason,
        this.artRefillPENotPossibleReasonOther,
        this.artRefillVHWName,
        this.artRefillVHWVillage,
        this.artRefillVHWPhoneNumber,
        this.artRefillTreatmentBuddyART,
        this.artRefillTreatmentBuddyVillage,
        this.artRefillTreatmentBuddyPhoneNumber,
        this.patientPhoneNumber,
        this.adherenceReminderEnabled,
        this.adherenceReminderFrequency,
        this.adherenceReminderTime,
        this.adherenceReminderMessage,
        this.artRefillReminderEnabled,
        this.artRefillReminderDaysBefore,
        this.artRefillReminderMessage,
        this.vlNotificationEnabled,
        this.vlNotificationMessageSuppressed,
        this.vlNotificationMessageUnsuppressed,
        this.pePhoneNumber,
        this.saturdayClinicClubAvailable,
        this.communityYouthClubAvailable,
        this.homeVisitPEPossible,
        this.homeVisitPENotPossibleReason,
        this.homeVisitPENotPossibleReasonOther,
        this.schoolVisitPEPossible,
        this.school,
        this.schoolVisitPENotPossibleReason,
        this.schoolVisitPENotPossibleReasonOther,
        this.pitsoPEPossible,
        this.pitsoPENotPossibleReason,
        this.pitsoPENotPossibleReasonOther,
        this.condomUsageDemonstrated,
        this.condomUsageNotDemonstratedReason,
        this.condomUsageNotDemonstratedReasonOther,
        this.moreInfoContraceptives,
        this.moreInfoVMMC,
        this.youngMothersAvailable,
        this.femaleWorthAvailable,
        this.legalAidSmartphoneAvailable,
        this.tuneMeSmartphoneAvailable,
        this.ntlafatsoSmartphoneAvailable,
        this.psychosocialShareSomethingContent,
        this.psychosocialHowDoing,
        this.unsuppressedSafeEnvironmentAnswer,
        this.unsuppressedWhyNotSafe,
      });

  PreferenceAssessment.uninitialized();

  PreferenceAssessment.fromMap(map) {
    this.patientART = map[colPatientART];
    this.createdDate = DateTime.parse(map[colCreatedDate]);
    this.artRefillOption1 = map[colARTRefillOption1] == null ? null : ARTRefillOption.values[map[colARTRefillOption1]];
    this.artRefillOption2 = map[colARTRefillOption2] == null ? null : ARTRefillOption.values[map[colARTRefillOption2]];
    this.artRefillOption3 = map[colARTRefillOption3] == null ? null : ARTRefillOption.values[map[colARTRefillOption3]];
    this.artRefillOption4 = map[colARTRefillOption4] == null ? null : ARTRefillOption.values[map[colARTRefillOption4]];
    this.artRefillOption5 = map[colARTRefillOption5] == null ? null : ARTRefillOption.values[map[colARTRefillOption5]];
    this.artRefillPENotPossibleReason = PEHomeDeliveryNotPossibleReason.fromCode(map[colARTRefillPENotPossibleReason]);
    this.artRefillPENotPossibleReasonOther = map[colARTRefillPENotPossibleReasonOther];
    this.artRefillVHWName = map[colARTRefillVHWName];
    this.artRefillVHWVillage = map[colARTRefillVHWVillage];
    this.artRefillVHWPhoneNumber = map[colARTRefillVHWPhoneNumber];
    this.artRefillTreatmentBuddyART = map[colARTRefillTreatmentBuddyART];
    this.artRefillTreatmentBuddyVillage = map[colARTRefillTreatmentBuddyVillage];
    this.artRefillTreatmentBuddyPhoneNumber = map[colARTRefillTreatmentBuddyPhoneNumber];
    this.artSupplyAmount = ARTSupplyAmount.fromCode(map[colARTSupplyAmount]);
    if (map[colPhoneAvailable] != null) {
      this.phoneAvailable = map[colPhoneAvailable] == 1;
    }
    this.patientPhoneNumber = map[colPatientPhoneNumber];
    if (map[colAdherenceReminderEnabled] != null) {
      this.adherenceReminderEnabled = map[colAdherenceReminderEnabled] == 1;
    }
    this.adherenceReminderFrequency = map[colAdherenceReminderFrequency] == null ? null : AdherenceReminderFrequency.values[map[colAdherenceReminderFrequency]];
    this.adherenceReminderTime = parseTimeOfDay(map[colAdherenceReminderTime]);
    this.adherenceReminderMessage = map[colAdherenceReminderMessage] == null ? null : AdherenceReminderMessage.values[map[colAdherenceReminderMessage]];
    if (map[colARTRefillReminderEnabled] != null) {
      this.artRefillReminderEnabled = map[colARTRefillReminderEnabled] == 1;
    }
    this.artRefillReminderDaysBefore = map[colARTRefillReminderDaysBefore] == null ? null : ARTRefillReminderDaysBeforeSelection.deserializeFromJSON(map[colARTRefillReminderDaysBefore]);
    this.artRefillReminderMessage = ARTRefillReminderMessage.fromCode(map[colARTRefillReminderMessage]);
    if (map[colVLNotificationEnabled] != null) {
      this.vlNotificationEnabled = map[colVLNotificationEnabled] == 1;
    }
    this.vlNotificationMessageSuppressed = map[colVLNotificationMessageSuppressed] == null ? null : VLSuppressedMessage.values[map[colVLNotificationMessageSuppressed]];
    this.vlNotificationMessageUnsuppressed = map[colVLNotificationMessageUnsuppressed] == null ? null : VLUnsuppressedMessage.values[map[colVLNotificationMessageUnsuppressed]];
    this.pePhoneNumber = map[colPEPhoneNumber];
    this.supportPreferences = SupportPreferencesSelection.deserializeFromJSON(map[colSupportPreferences]);
    this.saturdayClinicClubAvailable = map[colSaturdayClinicClubAvailable] == null ? null : map[colSaturdayClinicClubAvailable] == 1;
    this.communityYouthClubAvailable = map[colCommunityYouthClubAvailable] == null ? null : map[colCommunityYouthClubAvailable] == 1;
    this.homeVisitPEPossible = map[colHomeVisitPEPossible] == null ? null : map[colHomeVisitPEPossible] == 1;
    this.homeVisitPENotPossibleReason = HomeVisitPENotPossibleReason.fromCode(map[colHomeVisitPENotPossibleReason]);
    this.homeVisitPENotPossibleReasonOther = map[colHomeVisitPENotPossibleReasonOther];
    this.schoolVisitPEPossible = map[colSchoolVisitPEPossible] == null ? null : map[colSchoolVisitPEPossible] == 1;
    this.school = map[colSchool];
    this.schoolVisitPENotPossibleReason = SchoolVisitPENotPossibleReason.fromCode(map[colSchoolVisitPENotPossibleReason]);
    this.schoolVisitPENotPossibleReasonOther = map[colSchoolVisitPENotPossibleReasonOther];
    this.pitsoPEPossible = map[colPitsoPEPossible] == null ? null : map[colPitsoPEPossible] == 1;
    this.pitsoPENotPossibleReason = PitsoPENotPossibleReason.fromCode(map[colPitsoPENotPossibleReason]);
    this.pitsoPENotPossibleReasonOther = map[colPitsoPENotPossibleReasonOther];
    this.condomUsageDemonstrated = map[colCondomUsageDemonstrated] == null ? null : map[colCondomUsageDemonstrated] == 1;
    this.condomUsageNotDemonstratedReason = CondomUsageNotDemonstratedReason.fromCode(map[colCondomUsageNotDemonstratedReason]);
    this.condomUsageNotDemonstratedReasonOther = map[colCondomUsageNotDemonstratedReasonOther];
    this.moreInfoContraceptives = map[colMoreInfoContraceptives];
    this.moreInfoVMMC = map[colMoreInfoVMMC];
    this.youngMothersAvailable = map[colYoungMothersAvailable] == null ? null : map[colYoungMothersAvailable] == 1;
    this.femaleWorthAvailable = map[colFemaleWorthAvailable] == null ? null : map[colFemaleWorthAvailable] == 1;
    this.legalAidSmartphoneAvailable = map[colLegalAidSmartphoneAvailable] == null ? null : map[colLegalAidSmartphoneAvailable] == 1;
    this.tuneMeSmartphoneAvailable = map[colTuneMeSmartphoneAvailable] == null ? null : map[colTuneMeSmartphoneAvailable] == 1;
    this.ntlafatsoSmartphoneAvailable = map[colNtlafatsoSmartphoneAvailable] == null ? null : map[colNtlafatsoSmartphoneAvailable] == 1;
    this.psychosocialShareSomethingAnswer = YesNoRefused.fromCode(map[colPsychosocialShareSomethingAnswer]);
    this.psychosocialShareSomethingContent = map[colPsychosocialShareSomethingContent];
    this.psychosocialHowDoing = map[colPsychosocialHowDoing];
    this.unsuppressedSafeEnvironmentAnswer = YesNoRefused.fromCode(map[colUnsuppressedSafeEnvironmentAnswer]);
    this.unsuppressedWhyNotSafe = map[colUnsuppressedWhyNotSafe];
  }


  // Other
  // -----

  toMap() {
    var map = Map<String, dynamic>();
    map[colPatientART] = patientART;
    map[colCreatedDate] = createdDate.toIso8601String();
    map[colARTRefillOption1] = artRefillOption1.index;
    map[colARTRefillOption2] = artRefillOption2?.index;
    map[colARTRefillOption3] = artRefillOption3?.index;
    map[colARTRefillOption4] = artRefillOption4?.index;
    map[colARTRefillOption5] = artRefillOption5?.index;
    map[colARTRefillPENotPossibleReason] = artRefillPENotPossibleReason?.code;
    map[colARTRefillPENotPossibleReasonOther] = artRefillPENotPossibleReasonOther;
    map[colARTRefillVHWName] = artRefillVHWName;
    map[colARTRefillVHWVillage] = artRefillVHWVillage;
    map[colARTRefillVHWPhoneNumber] = artRefillVHWPhoneNumber;
    map[colARTRefillTreatmentBuddyART] = artRefillTreatmentBuddyART;
    map[colARTRefillTreatmentBuddyVillage] = artRefillTreatmentBuddyVillage;
    map[colARTRefillTreatmentBuddyPhoneNumber] = artRefillTreatmentBuddyPhoneNumber;
    map[colARTSupplyAmount] = artSupplyAmount.code;
    map[colPhoneAvailable] = phoneAvailable;
    map[colPatientPhoneNumber] = patientPhoneNumber;
    map[colAdherenceReminderEnabled] = adherenceReminderEnabled;
    map[colAdherenceReminderFrequency] = adherenceReminderFrequency?.index;
    map[colAdherenceReminderTime] = formatTime(adherenceReminderTime);
    map[colAdherenceReminderMessage] = adherenceReminderMessage?.index;
    map[colARTRefillReminderEnabled] = artRefillReminderEnabled;
    map[colARTRefillReminderDaysBefore] = artRefillReminderDaysBefore?.serializeToJSON();
    map[colARTRefillReminderMessage] = artRefillReminderMessage?.code;
    map[colVLNotificationEnabled] = vlNotificationEnabled;
    map[colVLNotificationMessageSuppressed] = vlNotificationMessageSuppressed?.index;
    map[colVLNotificationMessageUnsuppressed] = vlNotificationMessageUnsuppressed?.index;
    map[colPEPhoneNumber] = pePhoneNumber;
    map[colSupportPreferences] = supportPreferences.serializeToJSON();
    map[colSaturdayClinicClubAvailable] = saturdayClinicClubAvailable;
    map[colCommunityYouthClubAvailable] = communityYouthClubAvailable;
    map[colHomeVisitPEPossible] = homeVisitPEPossible;
    map[colHomeVisitPENotPossibleReason] = homeVisitPENotPossibleReason?.code;
    map[colHomeVisitPENotPossibleReasonOther] = homeVisitPENotPossibleReasonOther;
    map[colSchoolVisitPEPossible] = schoolVisitPEPossible;
    map[colSchool] = school;
    map[colSchoolVisitPENotPossibleReason] = schoolVisitPENotPossibleReason?.code;
    map[colSchoolVisitPENotPossibleReasonOther] = schoolVisitPENotPossibleReasonOther;
    map[colPitsoPEPossible] = pitsoPEPossible;
    map[colPitsoPENotPossibleReason] = pitsoPENotPossibleReason?.code;
    map[colPitsoPENotPossibleReasonOther] = pitsoPENotPossibleReasonOther;
    map[colCondomUsageDemonstrated] = condomUsageDemonstrated;
    map[colCondomUsageNotDemonstratedReason] = condomUsageNotDemonstratedReason?.code;
    map[colCondomUsageNotDemonstratedReasonOther] = condomUsageNotDemonstratedReasonOther;
    map[colMoreInfoContraceptives] = moreInfoContraceptives;
    map[colMoreInfoVMMC] = moreInfoVMMC;
    map[colYoungMothersAvailable] = youngMothersAvailable;
    map[colFemaleWorthAvailable] = femaleWorthAvailable;
    map[colLegalAidSmartphoneAvailable] = legalAidSmartphoneAvailable;
    map[colTuneMeSmartphoneAvailable] = tuneMeSmartphoneAvailable;
    map[colNtlafatsoSmartphoneAvailable] = ntlafatsoSmartphoneAvailable;
    map[colPsychosocialShareSomethingAnswer] = psychosocialShareSomethingAnswer.code;
    map[colPsychosocialShareSomethingContent] = psychosocialShareSomethingContent;
    map[colPsychosocialHowDoing] = psychosocialHowDoing;
    map[colUnsuppressedSafeEnvironmentAnswer] = unsuppressedSafeEnvironmentAnswer?.code;
    map[colUnsuppressedWhyNotSafe] = unsuppressedWhyNotSafe;
    return map;
  }

  static const int _numberOfColumns = 58;

  /// Column names for the header row in the excel sheet.
  // If we change the order here, make sure to change the order in the
  // [toExcelRow] method as well!
  static List<String> get excelHeaderRow {
    List<String> row = List<String>(_numberOfColumns);
    row[0] = 'DATE_CREATED';
    row[1] = 'TIME_CREATED';
    row[2] = 'IND_ID';
    row[3] = 'ART_REFILL_1';
    row[4] = 'ART_REFILL_2';
    row[5] = 'ART_REFILL_3';
    row[6] = 'ART_REFILL_4';
    row[7] = 'ART_REFILL_5';
    row[8] = 'ART_REFILL_PE_NO';
    row[9] = 'ART_REFILL_PE_NO_OTHER';
    row[10] = 'ART_REFILL_VHW_NAME';
    row[11] = 'ART_REFILL_VHW_VILLAGE';
    row[12] = 'ART_REFILL_VHW_CELL';
    row[13] = 'ART_REFILL_TB_ART';
    row[14] = 'ART_REFILL_TB_VILLAGE';
    row[15] = 'ART_REFILL_TB_CELL';
    row[16] = 'ART_REFILL_INTERVAL';
    row[17] = 'CELL_GIVEN';
    row[18] = 'CELL';
    row[19] = 'NOT_ADH';
    row[20] = 'NOT_ADH_FREQ';
    row[21] = 'NOT_ADH_TIME';
    row[22] = 'NOT_ADH_MESSAGE';
    row[23] = 'NOT_REFILL';
    row[24] = 'NOT_REFILL_WHEN';
    row[25] = 'NOT_REFILL_MESSAGE';
    row[26] = 'NOT_VL';
    row[27] = 'NOT_VL_SUPPR_MESSAGE';
    row[28] = 'NOT_VL_UNSUPPR_MESSAGE';
    row[29] = 'NOT_CELL_PE';
    row[30] = 'SUPPORT';
    row[31] = 'SUPPORT_SCC';
    row[32] = 'SUPPORT_CYC';
    row[33] = 'SUPPORT_HV';
    row[34] = 'SUPPORT_HV_NO';
    row[35] = 'SUPPORT_HV_NO_OTHER';
    row[36] = 'SUPPORT_SV';
    row[37] = 'SUPPORT_SV_SCHOOL';
    row[38] = 'SUPPORT_SV_NO';
    row[39] = 'SUPPORT_SV_NO_OTHER';
    row[40] = 'SUPPORT_PV';
    row[41] = 'SUPPORT_PV_NO';
    row[42] = 'SUPPORT_PV_NO_OTHER';
    row[43] = 'SUPPORT_CD';
    row[44] = 'SUPPORT_CD_NO';
    row[45] = 'SUPPORT_CD_NO_OTHER';
    row[46] = 'SUPPORT_CC';
    row[47] = 'SUPPORT_VMMC';
    row[48] = 'SUPPORT_YM';
    row[49] = 'SUPPORT_W';
    row[50] = 'SUPPORT_LA';
    row[51] = 'SUPPORT_TM';
    row[52] = 'SUPPORT_NF';
    row[53] = 'PSYCH_SHARE';
    row[54] = 'PSYCH_SHARE_NOTE';
    row[55] = 'PSYCH_DOING_NOTE';
    row[56] = 'UVL_ENV';
    row[57] = 'UVL_ENV_NOTE';
    return row;
  }

  /// Turns this object into a row that can be written to the excel sheet.
  // If we change the order here, make sure to change the order in the
  // [excelHeaderRow] method as well!
  @override
  List<dynamic> toExcelRow() {
    List<dynamic> row = List<dynamic>(_numberOfColumns);
    row[0] = formatDateIso(_createdDate);
    row[1] = formatTimeIso(_createdDate);
    row[2] = patientART;
    row[3] = artRefillOption1.index; // TODO: use correct encoding
    row[4] = artRefillOption2?.index; // TODO: use correct encoding
    row[5] = artRefillOption3?.index; // TODO: use correct encoding
    row[6] = artRefillOption4?.index; // TODO: use correct encoding
    row[7] = artRefillOption5?.index; // TODO: use correct encoding
    row[8] = artRefillPENotPossibleReason?.code;
    row[9] = artRefillPENotPossibleReasonOther;
    row[10] = artRefillVHWName;
    row[11] = artRefillVHWVillage;
    row[12] = artRefillVHWPhoneNumber;
    row[13] = artRefillTreatmentBuddyART;
    row[14] = artRefillTreatmentBuddyVillage;
    row[15] = artRefillTreatmentBuddyPhoneNumber;
    row[16] = artSupplyAmount.code;
    row[17] = phoneAvailable;
    row[18] = patientPhoneNumber;
    row[19] = adherenceReminderEnabled;
    row[20] = adherenceReminderFrequency?.index; // TODO: use correct encoding
    row[21] = formatTime(adherenceReminderTime);
    row[22] = adherenceReminderMessage?.index; // TODO: use correct encoding
    row[23] = artRefillReminderEnabled;
    row[24] = artRefillReminderDaysBefore?.serializeToJSON(); // TODO: use correct encoding
    row[25] = artRefillReminderMessage?.code;
    row[26] = vlNotificationEnabled;
    row[27] = vlNotificationMessageSuppressed?.index; // TODO: use correct encoding
    row[28] = vlNotificationMessageUnsuppressed?.index; // TODO: use correct encoding
    row[29] = pePhoneNumber;
    row[30] = supportPreferences.serializeToJSON();
    row[31] = saturdayClinicClubAvailable;
    row[32] = communityYouthClubAvailable;
    row[33] = homeVisitPEPossible;
    row[34] = homeVisitPENotPossibleReason?.code;
    row[35] = homeVisitPENotPossibleReasonOther;
    row[36] = schoolVisitPEPossible;
    row[37] = school;
    row[38] = schoolVisitPENotPossibleReason?.code;
    row[39] = schoolVisitPENotPossibleReasonOther;
    row[40] = pitsoPEPossible;
    row[41] = pitsoPENotPossibleReason?.code;
    row[42] = pitsoPENotPossibleReasonOther;
    row[43] = condomUsageDemonstrated;
    row[44] = condomUsageNotDemonstratedReason?.code;
    row[45] = condomUsageNotDemonstratedReasonOther;
    row[46] = moreInfoContraceptives;
    row[47] = moreInfoVMMC;
    row[48] = youngMothersAvailable;
    row[49] = femaleWorthAvailable;
    row[50] = legalAidSmartphoneAvailable;
    row[51] = tuneMeSmartphoneAvailable;
    row[52] = ntlafatsoSmartphoneAvailable;
    row[53] = psychosocialShareSomethingAnswer.code;
    row[54] = psychosocialShareSomethingContent;
    row[55] = psychosocialHowDoing;
    row[56] = unsuppressedSafeEnvironmentAnswer?.code;
    row[57] = unsuppressedWhyNotSafe;
    return row;
  }


  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  set createdDate(DateTime date) => this._createdDate = date;

  DateTime get createdDate => this._createdDate;

}

class ARTRefillReminderDaysBeforeSelection {
  bool sevenDaysBeforeSelected = false;
  bool threeDaysBeforeSelected = false;
  bool twoDaysBeforeSelected = false;
  bool oneDayBeforeSelected = false;
  bool zeroDaysBeforeSelected = false;

  static String get sevenDaysBeforeDescription => "7 Days Before";
  static String get threeDaysBeforeDescription => "3 Days Before";
  static String get twoDaysBeforeDescription => "2 Days Before";
  static String get oneDayBeforeDescription => "1 Day Before";
  static String get zeroDaysBeforeDescription => "On the day of ART Refill";

  void deselectAll() {
    sevenDaysBeforeSelected = false;
    threeDaysBeforeSelected = false;
    twoDaysBeforeSelected = false;
    oneDayBeforeSelected = false;
    zeroDaysBeforeSelected = false;
  }

  bool get areAllDeselected {
    return !(sevenDaysBeforeSelected ||
        threeDaysBeforeSelected ||
        twoDaysBeforeSelected ||
        oneDayBeforeSelected ||
        zeroDaysBeforeSelected);
  }

  String serializeToJSON() {
    var map = Map<String, bool>();
    map['sevenDaysBeforeSelected'] = sevenDaysBeforeSelected;
    map['threeDaysBeforeSelected'] = threeDaysBeforeSelected;
    map['twoDaysBeforeSelected'] = twoDaysBeforeSelected;
    map['oneDayBeforeSelected'] = oneDayBeforeSelected;
    map['zeroDaysBeforeSelected'] = zeroDaysBeforeSelected;
    return jsonEncode(map);
  }

  static ARTRefillReminderDaysBeforeSelection deserializeFromJSON(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    var obj = ARTRefillReminderDaysBeforeSelection();
    obj.sevenDaysBeforeSelected = map['sevenDaysBeforeSelected'] ?? false;
    obj.threeDaysBeforeSelected = map['threeDaysBeforeSelected'] ?? false;
    obj.twoDaysBeforeSelected = map['twoDaysBeforeSelected'] ?? false;
    obj.oneDayBeforeSelected = map['oneDayBeforeSelected'] ?? false;
    obj.zeroDaysBeforeSelected = map['zeroDaysBeforeSelected'] ?? false;
    return obj;
  }

}

// Do not change the order of the enums as their index is used to store the instance in the database!
enum ARTRefillOption { CLINIC, PE_HOME_DELIVERY, VHW, TREATMENT_BUDDY, COMMUNITY_ADHERENCE_CLUB }

// Do not change the order of the enums as their index is used to store the instance in the database!
enum AdherenceReminderFrequency { DAILY, WEEKLY, MONTHLY }

// Do not change the order of the enums as their index is used to store the instance in the database!
enum AdherenceReminderMessage { MESSAGE_1, MESSAGE_2, MESSAGE_3, MESSAGE_4, MESSAGE_5, MESSAGE_6, MESSAGE_7, MESSAGE_8, MESSAGE_9 }

// Do not change the order of the enums as their index is used to store the instance in the database!
enum VLSuppressedMessage { MESSAGE_1, MESSAGE_2, MESSAGE_3, MESSAGE_4, MESSAGE_5, MESSAGE_6 }

// Do not change the order of the enums as their index is used to store the instance in the database!
enum VLUnsuppressedMessage { MESSAGE_1, MESSAGE_2, MESSAGE_3, MESSAGE_4, MESSAGE_5, MESSAGE_6 }
