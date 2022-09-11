import 'package:flutter/material.dart';
import 'package:pebrapp/database/DatabaseExporter.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/ARTRefillOption.dart';
import 'package:pebrapp/database/beans/ARTRefillReminderDaysBeforeSelection.dart';
import 'package:pebrapp/database/beans/ARTRefillReminderMessage.dart';
import 'package:pebrapp/database/beans/ARTSupplyAmount.dart';
import 'package:pebrapp/database/beans/AdherenceReminderFrequency.dart';
import 'package:pebrapp/database/beans/AdherenceReminderMessage.dart';
import 'package:pebrapp/database/beans/HomeVisitPENotPossibleReason.dart';
import 'package:pebrapp/database/beans/PEHomeDeliveryNotPossibleReason.dart';
import 'package:pebrapp/database/beans/PitsoPENotPossibleReason.dart';
import 'package:pebrapp/database/beans/SchoolVisitPENotPossibleReason.dart';
import 'package:pebrapp/database/beans/SupportOption.dart';
import 'package:pebrapp/database/beans/SupportPreferencesSelection.dart';
import 'package:pebrapp/database/beans/VLSuppressedMessage.dart';
import 'package:pebrapp/database/beans/VLUnsuppressedMessage.dart';
import 'package:pebrapp/database/beans/YesNoRefused.dart';
import 'package:pebrapp/database/models/SupportOptionDone.dart';
import 'package:pebrapp/utils/Utils.dart';

class PreferenceAssessment implements IExcelExportable {
  static final tableName = 'PreferenceAssessment';

  // column names
  static final colId = 'id'; // primary key
  static final colPatientART =
      'patient_art'; // foreign key to [Patient].art_number
  static final colCreatedDate = 'created_date';
  static final colARTRefillOption1 = 'art_refill_option_1';
  static final colARTRefillOption2 = 'art_refill_option_2'; // nullable
  static final colARTRefillOption3 = 'art_refill_option_3'; // nullable
  static final colARTRefillOption4 = 'art_refill_option_4'; // nullable
  static final colARTRefillOption5 = 'art_refill_option_5'; // nullable
  static final colARTRefillPENotPossibleReason =
      'art_refill_pe_not_possible_reason'; // nullable
  static final colARTRefillPENotPossibleReasonOther =
      'art_refill_pe_not_possible_reason_other'; // nullable
  static final colARTRefillVHWName = 'art_refill_vhw_name'; // nullable
  static final colARTRefillVHWVillage = 'art_refill_vhw_village'; // nullable
  static final colARTRefillVHWPhoneNumber =
      'art_refill_vhw_phone_number'; // nullable
  static final colARTRefillTreatmentBuddyART =
      'art_refill_treatment_buddy_art'; // nullable
  static final colARTRefillTreatmentBuddyVillage =
      'art_refill_treatment_buddy_village'; // nullable
  static final colARTRefillTreatmentBuddyPhoneNumber =
      'art_refill_treatment_buddy_phone_number'; // nullable
  static final colARTSupplyAmount = 'art_supply_amount';
  static final colPatientPhoneAvailable = 'patient_phone_available';
  static final colAdherenceReminderEnabled =
      'adherence_reminder_enabled'; // nullable
  static final colAdherenceReminderFrequency =
      'adherence_reminder_frequency'; // nullable
  static final colAdherenceReminderTime = 'adherence_reminder_time'; // nullable
  static final colAdherenceReminderMessage =
      'adherence_reminder_message'; // nullable
  static final colARTRefillReminderEnabled =
      'art_refill_reminder_enabled'; // nullable
  static final colARTRefillReminderDaysBefore =
      'art_refill_reminder_days_before'; // nullable
  static final colARTRefillReminderMessage =
      'art_refill_reminder_message'; // nullable
  static final colVLNotificationEnabled = 'vl_notification_enabled'; // nullable
  static final colVLNotificationMessageSuppressed =
      'vl_notification_message_suppressed'; // nullable
  static final colVLNotificationMessageUnsuppressed =
      'vl_notification_message_unsuppressed'; // nullable
  static final colSupportPreferences = 'support_preferences';
  static final colSaturdayClinicClubAvailable =
      'saturday_clinic_club_available'; // nullable
  static final colCommunityYouthClubAvailable =
      'community_youth_club_available'; // nullable
  static final colHomeVisitPEPossible = 'home_visit_pe_possible'; // nullable
  static final colHomeVisitPENotPossibleReason =
      'home_visit_pe_not_possible_reason'; // nullable
  static final colHomeVisitPENotPossibleReasonOther =
      'home_visit_pe_not_possible_reason_other'; // nullable
  static final colSchoolVisitPEPossible =
      'school_visit_pe_possible'; // nullable
  static final colSchool = 'school'; // nullable
  static final colSchoolVisitPENotPossibleReason =
      'school_visit_pe_not_possible_reason'; // nullable
  static final colSchoolVisitPENotPossibleReasonOther =
      'school_visit_pe_not_possible_reason_other'; // nullable
  static final colPitsoPEPossible = 'pitso_pe_possible'; // nullable
  static final colPitsoPENotPossibleReason =
      'pitso_pe_not_possible_reason'; // nullable
  static final colPitsoPENotPossibleReasonOther =
      'pitso_pe_not_possible_reason_other'; // nullable
  static final colMoreInfoContraceptives =
      'more_info_contraceptives'; // nullable
  static final colMoreInfoVMMC = 'more_info_vmmc'; // nullable
  static final colYoungMothersAvailable = 'young_mothers_available'; // nullable
  static final colFemaleWorthAvailable = 'female_worth_available'; // nullable
  static final colPsychosocialShareSomethingAnswer =
      'psychosocial_share_something';
  static final colPsychosocialShareSomethingContent =
      'psychosocial_share_something_content'; // nullable
  static final colPsychosocialHowDoing = 'psychosocial_how_doing'; // nullable
  static final colUnsuppressedSafeEnvironmentAnswer =
      'unsuppressed_safe_env_answer'; // nullable
  static final colUnsuppressedWhyNotSafe =
      'unsuppressed_why_not_safe_env'; // nullable

  int id;
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
  bool patientPhoneAvailable;
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
  SupportPreferencesSelection supportPreferences =
      SupportPreferencesSelection();
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
  String moreInfoContraceptives;
  String moreInfoVMMC;
  bool youngMothersAvailable;
  bool femaleWorthAvailable;
  YesNoRefused psychosocialShareSomethingAnswer;
  String psychosocialShareSomethingContent;
  String psychosocialHowDoing;
  YesNoRefused unsuppressedSafeEnvironmentAnswer;
  String unsuppressedWhyNotSafe;
  // The following fields are from the [SupportOptionDone] table.
  // Will be null until the [initializeSupportOptionDoneFields] methods is
  // called.
  Set<SupportOptionDone> _supportOptionDones = {};

  // Constructors
  // ------------

  PreferenceAssessment(
    this.id,
    this.patientART,
    this.artRefillOption1,
    this.supportPreferences,
    this.artSupplyAmount,
    this.psychosocialShareSomethingAnswer, {
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
    this.patientPhoneAvailable,
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
    this.moreInfoContraceptives,
    this.moreInfoVMMC,
    this.youngMothersAvailable,
    this.femaleWorthAvailable,
    this.psychosocialShareSomethingContent,
    this.psychosocialHowDoing,
    this.unsuppressedSafeEnvironmentAnswer,
    this.unsuppressedWhyNotSafe,
  });

  PreferenceAssessment.uninitialized();

  PreferenceAssessment.fromMap(map) {
    this.id = map[colId];
    this.patientART = map[colPatientART];
    this.createdDate = DateTime.parse(map[colCreatedDate]);
    this.artRefillOption1 = ARTRefillOption.fromCode(map[colARTRefillOption1]);
    this.artRefillOption2 = ARTRefillOption.fromCode(map[colARTRefillOption2]);
    this.artRefillOption3 = ARTRefillOption.fromCode(map[colARTRefillOption3]);
    this.artRefillOption4 = ARTRefillOption.fromCode(map[colARTRefillOption4]);
    this.artRefillOption5 = ARTRefillOption.fromCode(map[colARTRefillOption5]);
    this.artRefillPENotPossibleReason =
        PEHomeDeliveryNotPossibleReason.fromCode(
            map[colARTRefillPENotPossibleReason]);
    this.artRefillPENotPossibleReasonOther =
        map[colARTRefillPENotPossibleReasonOther];
    this.artRefillVHWName = map[colARTRefillVHWName];
    this.artRefillVHWVillage = map[colARTRefillVHWVillage];
    this.artRefillVHWPhoneNumber = map[colARTRefillVHWPhoneNumber];
    this.artRefillTreatmentBuddyART = map[colARTRefillTreatmentBuddyART];
    this.artRefillTreatmentBuddyVillage =
        map[colARTRefillTreatmentBuddyVillage];
    this.artRefillTreatmentBuddyPhoneNumber =
        map[colARTRefillTreatmentBuddyPhoneNumber];
    this.artSupplyAmount = ARTSupplyAmount.fromCode(map[colARTSupplyAmount]);
    this.patientPhoneAvailable = map[colPatientPhoneAvailable] == 1;
    if (map[colAdherenceReminderEnabled] != null) {
      this.adherenceReminderEnabled = map[colAdherenceReminderEnabled] == 1;
    }
    this.adherenceReminderFrequency =
        AdherenceReminderFrequency.fromCode(map[colAdherenceReminderFrequency]);
    this.adherenceReminderTime = parseTimeOfDay(map[colAdherenceReminderTime]);
    this.adherenceReminderMessage =
        AdherenceReminderMessage.fromCode(map[colAdherenceReminderMessage]);
    if (map[colARTRefillReminderEnabled] != null) {
      this.artRefillReminderEnabled = map[colARTRefillReminderEnabled] == 1;
    }
    this.artRefillReminderDaysBefore =
        map[colARTRefillReminderDaysBefore] == null
            ? null
            : ARTRefillReminderDaysBeforeSelection.deserializeFromJSON(
                map[colARTRefillReminderDaysBefore]);
    this.artRefillReminderMessage =
        ARTRefillReminderMessage.fromCode(map[colARTRefillReminderMessage]);
    if (map[colVLNotificationEnabled] != null) {
      this.vlNotificationEnabled = map[colVLNotificationEnabled] == 1;
    }
    this.vlNotificationMessageSuppressed =
        VLSuppressedMessage.fromCode(map[colVLNotificationMessageSuppressed]);
    this.vlNotificationMessageUnsuppressed = VLUnsuppressedMessage.fromCode(
        map[colVLNotificationMessageUnsuppressed]);
    this.supportPreferences = SupportPreferencesSelection.deserializeFromJSON(
        map[colSupportPreferences]);
    this.saturdayClinicClubAvailable =
        map[colSaturdayClinicClubAvailable] == null
            ? null
            : map[colSaturdayClinicClubAvailable] == 1;
    this.communityYouthClubAvailable =
        map[colCommunityYouthClubAvailable] == null
            ? null
            : map[colCommunityYouthClubAvailable] == 1;
    this.homeVisitPEPossible = map[colHomeVisitPEPossible] == null
        ? null
        : map[colHomeVisitPEPossible] == 1;
    this.homeVisitPENotPossibleReason = HomeVisitPENotPossibleReason.fromCode(
        map[colHomeVisitPENotPossibleReason]);
    this.homeVisitPENotPossibleReasonOther =
        map[colHomeVisitPENotPossibleReasonOther];
    this.schoolVisitPEPossible = map[colSchoolVisitPEPossible] == null
        ? null
        : map[colSchoolVisitPEPossible] == 1;
    this.school = map[colSchool];
    this.schoolVisitPENotPossibleReason =
        SchoolVisitPENotPossibleReason.fromCode(
            map[colSchoolVisitPENotPossibleReason]);
    this.schoolVisitPENotPossibleReasonOther =
        map[colSchoolVisitPENotPossibleReasonOther];
    this.pitsoPEPossible =
        map[colPitsoPEPossible] == null ? null : map[colPitsoPEPossible] == 1;
    this.pitsoPENotPossibleReason =
        PitsoPENotPossibleReason.fromCode(map[colPitsoPENotPossibleReason]);
    this.pitsoPENotPossibleReasonOther = map[colPitsoPENotPossibleReasonOther];
    this.moreInfoContraceptives = map[colMoreInfoContraceptives];
    this.moreInfoVMMC = map[colMoreInfoVMMC];
    this.youngMothersAvailable = map[colYoungMothersAvailable] == null
        ? null
        : map[colYoungMothersAvailable] == 1;
    this.femaleWorthAvailable = map[colFemaleWorthAvailable] == null
        ? null
        : map[colFemaleWorthAvailable] == 1;
    this.psychosocialShareSomethingAnswer =
        YesNoRefused.fromCode(map[colPsychosocialShareSomethingAnswer]);
    this.psychosocialShareSomethingContent =
        map[colPsychosocialShareSomethingContent];
    this.psychosocialHowDoing = map[colPsychosocialHowDoing];
    this.unsuppressedSafeEnvironmentAnswer =
        YesNoRefused.fromCode(map[colUnsuppressedSafeEnvironmentAnswer]);
    this.unsuppressedWhyNotSafe = map[colUnsuppressedWhyNotSafe];
  }

  // Other
  // -----

  toMap() {
    var map = Map<String, dynamic>();
    map[colPatientART] = patientART;
    map[colCreatedDate] = createdDate.toIso8601String();
    map[colARTRefillOption1] = artRefillOption1.code;
    map[colARTRefillOption2] = artRefillOption2?.code;
    map[colARTRefillOption3] = artRefillOption3?.code;
    map[colARTRefillOption4] = artRefillOption4?.code;
    map[colARTRefillOption5] = artRefillOption5?.code;
    map[colARTRefillPENotPossibleReason] = artRefillPENotPossibleReason?.code;
    map[colARTRefillPENotPossibleReasonOther] =
        artRefillPENotPossibleReasonOther;
    map[colARTRefillVHWName] = artRefillVHWName;
    map[colARTRefillVHWVillage] = artRefillVHWVillage;
    map[colARTRefillVHWPhoneNumber] = artRefillVHWPhoneNumber;
    map[colARTRefillTreatmentBuddyART] = artRefillTreatmentBuddyART;
    map[colARTRefillTreatmentBuddyVillage] = artRefillTreatmentBuddyVillage;
    map[colARTRefillTreatmentBuddyPhoneNumber] =
        artRefillTreatmentBuddyPhoneNumber;
    map[colARTSupplyAmount] = artSupplyAmount.code;
    map[colPatientPhoneAvailable] = patientPhoneAvailable;
    map[colAdherenceReminderEnabled] = adherenceReminderEnabled;
    map[colAdherenceReminderFrequency] = adherenceReminderFrequency?.code;
    map[colAdherenceReminderTime] = formatTime(adherenceReminderTime);
    map[colAdherenceReminderMessage] = adherenceReminderMessage?.code;
    map[colARTRefillReminderEnabled] = artRefillReminderEnabled;
    map[colARTRefillReminderDaysBefore] =
        artRefillReminderDaysBefore?.serializeToJSON();
    map[colARTRefillReminderMessage] = artRefillReminderMessage?.code;
    map[colVLNotificationEnabled] = vlNotificationEnabled;
    map[colVLNotificationMessageSuppressed] =
        vlNotificationMessageSuppressed?.code;
    map[colVLNotificationMessageUnsuppressed] =
        vlNotificationMessageUnsuppressed?.code;
    map[colSupportPreferences] = supportPreferences.serializeToJSON();
    map[colSaturdayClinicClubAvailable] = saturdayClinicClubAvailable;
    map[colCommunityYouthClubAvailable] = communityYouthClubAvailable;
    map[colHomeVisitPEPossible] = homeVisitPEPossible;
    map[colHomeVisitPENotPossibleReason] = homeVisitPENotPossibleReason?.code;
    map[colHomeVisitPENotPossibleReasonOther] =
        homeVisitPENotPossibleReasonOther;
    map[colSchoolVisitPEPossible] = schoolVisitPEPossible;
    map[colSchool] = school;
    map[colSchoolVisitPENotPossibleReason] =
        schoolVisitPENotPossibleReason?.code;
    map[colSchoolVisitPENotPossibleReasonOther] =
        schoolVisitPENotPossibleReasonOther;
    map[colPitsoPEPossible] = pitsoPEPossible;
    map[colPitsoPENotPossibleReason] = pitsoPENotPossibleReason?.code;
    map[colPitsoPENotPossibleReasonOther] = pitsoPENotPossibleReasonOther;
    map[colMoreInfoContraceptives] = moreInfoContraceptives;
    map[colMoreInfoVMMC] = moreInfoVMMC;
    map[colYoungMothersAvailable] = youngMothersAvailable;
    map[colFemaleWorthAvailable] = femaleWorthAvailable;
    map[colPsychosocialShareSomethingAnswer] =
        psychosocialShareSomethingAnswer.code;
    map[colPsychosocialShareSomethingContent] =
        psychosocialShareSomethingContent;
    map[colPsychosocialHowDoing] = psychosocialHowDoing;
    map[colUnsuppressedSafeEnvironmentAnswer] =
        unsuppressedSafeEnvironmentAnswer?.code;
    map[colUnsuppressedWhyNotSafe] = unsuppressedWhyNotSafe;
    return map;
  }

  static const int _numberOfColumns = 51;

  /// Column names for the header row in the excel sheet.
  // If we change the order here, make sure to change the order in the
  // [toExcelRow] method as well!
  static List<String> get excelHeaderRow {
    List<String> row = List<String>(_numberOfColumns);
    row[0] = 'ID';
    row[1] = 'DATE_CREATED';
    row[2] = 'TIME_CREATED';
    row[3] = 'IND_ID';
    row[4] = 'ART_REFILL_1';
    row[5] = 'ART_REFILL_2';
    row[6] = 'ART_REFILL_3';
    row[7] = 'ART_REFILL_4';
    row[8] = 'ART_REFILL_5';
    row[9] = 'ART_REFILL_PE_NO';
    row[10] = 'ART_REFILL_PE_NO_OTHER';
    row[11] = 'ART_REFILL_VHW_NAME';
    row[12] = 'ART_REFILL_VHW_VILLAGE';
    row[13] = 'ART_REFILL_VHW_CELL';
    row[14] = 'ART_REFILL_TB_ART';
    row[15] = 'ART_REFILL_TB_VILLAGE';
    row[16] = 'ART_REFILL_TB_CELL';
    row[17] = 'ART_REFILL_INTERVAL';
    row[18] = 'CELL_AVAILABLE';
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
    row[29] = 'SUPPORT';
    row[30] = 'SUPPORT_SCC';
    row[31] = 'SUPPORT_CYC';
    row[32] = 'SUPPORT_HV';
    row[33] = 'SUPPORT_HV_NO';
    row[34] = 'SUPPORT_HV_NO_OTHER';
    row[35] = 'SUPPORT_SV';
    row[36] = 'SUPPORT_SV_SCHOOL';
    row[37] = 'SUPPORT_SV_NO';
    row[38] = 'SUPPORT_SV_NO_OTHER';
    row[39] = 'SUPPORT_PV';
    row[40] = 'SUPPORT_PV_NO';
    row[41] = 'SUPPORT_PV_NO_OTHER';
    row[42] = 'SUPPORT_CC';
    row[43] = 'SUPPORT_VMMC';
    row[44] = 'SUPPORT_YM';
    row[45] = 'SUPPORT_W';
    row[46] = 'PSYCH_SHARE';
    row[47] = 'PSYCH_SHARE_NOTE';
    row[48] = 'PSYCH_DOING_NOTE';
    row[49] = 'UVL_ENV';
    row[50] = 'UVL_ENV_NOTE';
    return row;
  }

  /// Turns this object into a row that can be written to the excel sheet.
  // If we change the order here, make sure to change the order in the
  // [excelHeaderRow] method as well!
  @override
  List<dynamic> toExcelRow() {
    List<dynamic> row = List<dynamic>(_numberOfColumns);
    row[0] = id;
    row[1] = formatDateIso(_createdDate);
    row[2] = formatTimeIso(_createdDate);
    row[3] = patientART;
    row[4] = artRefillOption1.code;
    row[5] = artRefillOption2?.code;
    row[6] = artRefillOption3?.code;
    row[7] = artRefillOption4?.code;
    row[8] = artRefillOption5?.code;
    row[9] = artRefillPENotPossibleReason?.code;
    row[10] = artRefillPENotPossibleReasonOther;
    row[11] = artRefillVHWName;
    row[12] = artRefillVHWVillage;
    row[13] = artRefillVHWPhoneNumber;
    row[14] = artRefillTreatmentBuddyART;
    row[15] = artRefillTreatmentBuddyVillage;
    row[16] = artRefillTreatmentBuddyPhoneNumber;
    row[17] = artSupplyAmount.code;
    row[18] = patientPhoneAvailable;
    row[19] = adherenceReminderEnabled;
    row[20] = adherenceReminderFrequency?.code;
    row[21] = formatTime(adherenceReminderTime);
    row[22] = adherenceReminderMessage?.code;
    row[23] = artRefillReminderEnabled;
    row[24] = artRefillReminderDaysBefore?.serializeToJSON();
    row[25] = artRefillReminderMessage?.code;
    row[26] = vlNotificationEnabled;
    row[27] = vlNotificationMessageSuppressed?.code;
    row[28] = vlNotificationMessageUnsuppressed?.code;
    row[29] = supportPreferences.toExcelString();
    row[30] = saturdayClinicClubAvailable;
    row[31] = communityYouthClubAvailable;
    row[32] = homeVisitPEPossible;
    row[33] = homeVisitPENotPossibleReason?.code;
    row[34] = homeVisitPENotPossibleReasonOther;
    row[35] = schoolVisitPEPossible;
    row[36] = school;
    row[37] = schoolVisitPENotPossibleReason?.code;
    row[38] = schoolVisitPENotPossibleReasonOther;
    row[39] = pitsoPEPossible;
    row[40] = pitsoPENotPossibleReason?.code;
    row[41] = pitsoPENotPossibleReasonOther;
    row[42] = moreInfoContraceptives;
    row[43] = moreInfoVMMC;
    row[44] = youngMothersAvailable;
    row[45] = femaleWorthAvailable;
    row[46] = psychosocialShareSomethingAnswer.code;
    row[47] = psychosocialShareSomethingContent;
    row[48] = psychosocialHowDoing;
    row[49] = unsuppressedSafeEnvironmentAnswer?.code;
    row[50] = unsuppressedWhyNotSafe;
    return row;
  }

  /// Initializes the support option done fields with the latest data from the database.
  Future<void> initializeSupportOptionDoneFields() async {
    _supportOptionDones = await DatabaseProvider()
        .retrieveDoneSupportOptionsForPreferenceAssessment(id);
  }

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  set createdDate(DateTime date) => this._createdDate = date;

  DateTime get createdDate => this._createdDate;

  ARTRefillOption get lastRefillOption =>
      artRefillOption5 ??
      artRefillOption4 ??
      artRefillOption3 ??
      artRefillOption2 ??
      artRefillOption1;

  DateTime get NURSE_CLINIC_done_date => _supportOptionDones
      .firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.NURSE_CLINIC() && s.done,
          orElse: () => null)
      ?.createdDate;
  DateTime get SATURDAY_CLINIC_CLUB_done_date => _supportOptionDones
      .firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.SATURDAY_CLINIC_CLUB() && s.done,
          orElse: () => null)
      ?.createdDate;
  DateTime get COMMUNITY_YOUTH_CLUB_done_date => _supportOptionDones
      .firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.COMMUNITY_YOUTH_CLUB() && s.done,
          orElse: () => null)
      ?.createdDate;
  DateTime get PHONE_CALL_PE_done_date => _supportOptionDones
      .firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.PHONE_CALL_PE() && s.done,
          orElse: () => null)
      ?.createdDate;
  DateTime get HOME_VISIT_PE_done_date => _supportOptionDones
      .firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.HOME_VISIT_PE() && s.done,
          orElse: () => null)
      ?.createdDate;
  DateTime get SCHOOL_VISIT_PE_done_date => _supportOptionDones
      .firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.SCHOOL_VISIT_PE() && s.done,
          orElse: () => null)
      ?.createdDate;
  DateTime get PITSO_VISIT_PE_done_date => _supportOptionDones
      .firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.PITSO_VISIT_PE() && s.done,
          orElse: () => null)
      ?.createdDate;
  DateTime get CONDOM_DEMO_done_date => _supportOptionDones
      .firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.CONDOM_DEMO() && s.done,
          orElse: () => null)
      ?.createdDate;
  DateTime get CONTRACEPTIVES_INFO_done_date => _supportOptionDones
      .firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.CONTRACEPTIVES_INFO() && s.done,
          orElse: () => null)
      ?.createdDate;
  DateTime get VMMC_INFO_done_date => _supportOptionDones
      .firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.VMMC_INFO() && s.done,
          orElse: () => null)
      ?.createdDate;
  DateTime get YOUNG_MOTHERS_GROUP_done_date => _supportOptionDones
      .firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.YOUNG_MOTHERS_GROUP() && s.done,
          orElse: () => null)
      ?.createdDate;
  DateTime get FEMALE_WORTH_GROUP_done_date => _supportOptionDones
      .firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.FEMALE_WORTH_GROUP() && s.done,
          orElse: () => null)
      ?.createdDate;
  DateTime get LEGAL_AID_INFO_done_date => _supportOptionDones
      .firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.LEGAL_AID_INFO() && s.done,
          orElse: () => null)
      ?.createdDate;

  bool get NURSE_CLINIC_done =>
      _supportOptionDones.firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.NURSE_CLINIC() && s.done,
          orElse: () => null) !=
      null;
  bool get SATURDAY_CLINIC_CLUB_done =>
      _supportOptionDones.firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.SATURDAY_CLINIC_CLUB() && s.done,
          orElse: () => null) !=
      null;
  bool get COMMUNITY_YOUTH_CLUB_done =>
      _supportOptionDones.firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.COMMUNITY_YOUTH_CLUB() && s.done,
          orElse: () => null) !=
      null;
  bool get PHONE_CALL_PE_done =>
      _supportOptionDones.firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.PHONE_CALL_PE() && s.done,
          orElse: () => null) !=
      null;
  bool get HOME_VISIT_PE_done =>
      _supportOptionDones.firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.HOME_VISIT_PE() && s.done,
          orElse: () => null) !=
      null;
  bool get SCHOOL_VISIT_PE_done =>
      _supportOptionDones.firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.SCHOOL_VISIT_PE() && s.done,
          orElse: () => null) !=
      null;
  bool get PITSO_VISIT_PE_done =>
      _supportOptionDones.firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.PITSO_VISIT_PE() && s.done,
          orElse: () => null) !=
      null;
  bool get CONDOM_DEMO_done =>
      _supportOptionDones.firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.CONDOM_DEMO() && s.done,
          orElse: () => null) !=
      null;
  bool get CONTRACEPTIVES_INFO_done =>
      _supportOptionDones.firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.CONTRACEPTIVES_INFO() && s.done,
          orElse: () => null) !=
      null;
  bool get VMMC_INFO_done =>
      _supportOptionDones.firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.VMMC_INFO() && s.done,
          orElse: () => null) !=
      null;
  bool get YOUNG_MOTHERS_GROUP_done =>
      _supportOptionDones.firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.YOUNG_MOTHERS_GROUP() && s.done,
          orElse: () => null) !=
      null;
  bool get FEMALE_WORTH_GROUP_done =>
      _supportOptionDones.firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.FEMALE_WORTH_GROUP() && s.done,
          orElse: () => null) !=
      null;
  bool get LEGAL_AID_INFO_done =>
      _supportOptionDones.firstWhere(
          (SupportOptionDone s) =>
              s.supportOption == SupportOption.LEGAL_AID_INFO() && s.done,
          orElse: () => null) !=
      null;

  set_NURSE_CLINIC_done(bool done) async {
    SupportOptionDone s = SupportOptionDone(
        preferenceAssessmentId: id,
        supportOption: SupportOption.NURSE_CLINIC(),
        done: done);
    DateTime now = DateTime.now();
    s.createdDate = now;
    _supportOptionDones.remove(s);
    _supportOptionDones.add(s);
    await DatabaseProvider().insertSupportOptionDone(s, createdDate: now);
  }

  set_SATURDAY_CLINIC_CLUB_done(bool done) async {
    SupportOptionDone s = SupportOptionDone(
        preferenceAssessmentId: id,
        supportOption: SupportOption.SATURDAY_CLINIC_CLUB(),
        done: done);
    DateTime now = DateTime.now();
    s.createdDate = now;
    _supportOptionDones.remove(s);
    _supportOptionDones.add(s);
    await DatabaseProvider().insertSupportOptionDone(s, createdDate: now);
  }

  set_COMMUNITY_YOUTH_CLUB_done(bool done) async {
    SupportOptionDone s = SupportOptionDone(
        preferenceAssessmentId: id,
        supportOption: SupportOption.COMMUNITY_YOUTH_CLUB(),
        done: done);
    DateTime now = DateTime.now();
    s.createdDate = now;
    _supportOptionDones.remove(s);
    _supportOptionDones.add(s);
    await DatabaseProvider().insertSupportOptionDone(s, createdDate: now);
  }

  set_PHONE_CALL_PE_done(bool done) async {
    SupportOptionDone s = SupportOptionDone(
        preferenceAssessmentId: id,
        supportOption: SupportOption.PHONE_CALL_PE(),
        done: done);
    DateTime now = DateTime.now();
    s.createdDate = now;
    _supportOptionDones.remove(s);
    _supportOptionDones.add(s);
    await DatabaseProvider().insertSupportOptionDone(s, createdDate: now);
  }

  set_HOME_VISIT_PE_done(bool done) async {
    SupportOptionDone s = SupportOptionDone(
        preferenceAssessmentId: id,
        supportOption: SupportOption.HOME_VISIT_PE(),
        done: done);
    DateTime now = DateTime.now();
    s.createdDate = now;
    _supportOptionDones.remove(s);
    _supportOptionDones.add(s);
    await DatabaseProvider().insertSupportOptionDone(s, createdDate: now);
  }

  set_SCHOOL_VISIT_PE_done(bool done) async {
    SupportOptionDone s = SupportOptionDone(
        preferenceAssessmentId: id,
        supportOption: SupportOption.SCHOOL_VISIT_PE(),
        done: done);
    DateTime now = DateTime.now();
    s.createdDate = now;
    _supportOptionDones.remove(s);
    _supportOptionDones.add(s);
    await DatabaseProvider().insertSupportOptionDone(s, createdDate: now);
  }

  set_PITSO_VISIT_PE_done(bool done) async {
    SupportOptionDone s = SupportOptionDone(
        preferenceAssessmentId: id,
        supportOption: SupportOption.PITSO_VISIT_PE(),
        done: done);
    DateTime now = DateTime.now();
    s.createdDate = now;
    _supportOptionDones.remove(s);
    _supportOptionDones.add(s);
    await DatabaseProvider().insertSupportOptionDone(s, createdDate: now);
  }

  set_CONDOM_DEMO_done(bool done) async {
    SupportOptionDone s = SupportOptionDone(
        preferenceAssessmentId: id,
        supportOption: SupportOption.CONDOM_DEMO(),
        done: done);
    DateTime now = DateTime.now();
    s.createdDate = now;
    _supportOptionDones.remove(s);
    _supportOptionDones.add(s);
    await DatabaseProvider().insertSupportOptionDone(s, createdDate: now);
  }

  set_CONTRACEPTIVES_INFO_done(bool done) async {
    SupportOptionDone s = SupportOptionDone(
        preferenceAssessmentId: id,
        supportOption: SupportOption.CONTRACEPTIVES_INFO(),
        done: done);
    DateTime now = DateTime.now();
    s.createdDate = now;
    _supportOptionDones.remove(s);
    _supportOptionDones.add(s);
    await DatabaseProvider().insertSupportOptionDone(s, createdDate: now);
  }

  set_VMMC_INFO_done(bool done) async {
    SupportOptionDone s = SupportOptionDone(
        preferenceAssessmentId: id,
        supportOption: SupportOption.VMMC_INFO(),
        done: done);
    DateTime now = DateTime.now();
    s.createdDate = now;
    _supportOptionDones.remove(s);
    _supportOptionDones.add(s);
    await DatabaseProvider().insertSupportOptionDone(s, createdDate: now);
  }

  set_YOUNG_MOTHERS_GROUP_done(bool done) async {
    SupportOptionDone s = SupportOptionDone(
        preferenceAssessmentId: id,
        supportOption: SupportOption.YOUNG_MOTHERS_GROUP(),
        done: done);
    DateTime now = DateTime.now();
    s.createdDate = now;
    _supportOptionDones.remove(s);
    _supportOptionDones.add(s);
    await DatabaseProvider().insertSupportOptionDone(s, createdDate: now);
  }

  set_FEMALE_WORTH_GROUP_done(bool done) async {
    SupportOptionDone s = SupportOptionDone(
        preferenceAssessmentId: id,
        supportOption: SupportOption.FEMALE_WORTH_GROUP(),
        done: done);
    DateTime now = DateTime.now();
    s.createdDate = now;
    _supportOptionDones.remove(s);
    _supportOptionDones.add(s);
    await DatabaseProvider().insertSupportOptionDone(s, createdDate: now);
  }

  set_LEGAL_AID_INFO_done(bool done) async {
    SupportOptionDone s = SupportOptionDone(
        preferenceAssessmentId: id,
        supportOption: SupportOption.LEGAL_AID_INFO(),
        done: done);
    DateTime now = DateTime.now();
    s.createdDate = now;
    _supportOptionDones.remove(s);
    _supportOptionDones.add(s);
    await DatabaseProvider().insertSupportOptionDone(s, createdDate: now);
  }
}
