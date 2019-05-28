import 'dart:convert';

import 'package:pebrapp/database/beans/PEHomeDeliveryNotPossibleReason.dart';
import 'package:pebrapp/database/beans/SupportPreferencesSelection.dart';

class PreferenceAssessment {
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
  static final colPhoneAvailable = 'phone_available';
  static final colPatientPhoneNumber = 'patient_phone_number'; // nullable
  static final colAdherenceReminderEnabled = 'adherence_reminder_enabled'; // nullable
  static final colAdherenceReminderFrequency = 'adherence_reminder_frequency'; // nullable
  static final colAdherenceReminderTime = 'adherence_reminder_time'; // nullable
  static final colAdherenceReminderMessage = 'adherence_reminder_message'; // nullable
  static final colARTRefillReminderEnabled = 'art_refill_reminder_enabled'; // nullable
  static final colARTRefillReminderDaysBefore = 'art_refill_reminder_days_before'; // nullable
  static final colVLNotificationEnabled = 'vl_notification_enabled'; // nullable
  static final colVLNotificationMessageSuppressed = 'vl_notification_message_suppressed'; // nullable
  static final colVLNotificationMessageUnsuppressed = 'vl_notification_message_unsuppressed'; // nullable
  static final colPEPhoneNumber = 'pe_phone_number'; // nullable
  static final colSupportPreferences = 'support_preferences';

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
  bool phoneAvailable;
  String patientPhoneNumber;
  bool adherenceReminderEnabled;
  AdherenceReminderFrequency adherenceReminderFrequency;
  String adherenceReminderTime;
  AdherenceReminderMessage adherenceReminderMessage;
  bool artRefillReminderEnabled;
  ARTRefillReminderDaysBeforeSelection artRefillReminderDaysBefore;
  bool vlNotificationEnabled;
  VLSuppressedMessage vlNotificationMessageSuppressed;
  VLUnsuppressedMessage vlNotificationMessageUnsuppressed;
  String pePhoneNumber;
  SupportPreferencesSelection supportPreferences = SupportPreferencesSelection();


  // Constructors
  // ------------

  PreferenceAssessment(
      this.patientART,
      this.artRefillOption1,
      this.phoneAvailable,
      this.supportPreferences,
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
        this.vlNotificationEnabled,
        this.vlNotificationMessageSuppressed,
        this.vlNotificationMessageUnsuppressed,
        this.pePhoneNumber
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
    if (map[colPhoneAvailable] != null) {
      this.phoneAvailable = map[colPhoneAvailable] == 1;
    }
    this.patientPhoneNumber = map[colPatientPhoneNumber];
    if (map[colAdherenceReminderEnabled] != null) {
      this.adherenceReminderEnabled = map[colAdherenceReminderEnabled] == 1;
    }
    this.adherenceReminderFrequency = map[colAdherenceReminderFrequency] == null ? null : AdherenceReminderFrequency.values[map[colAdherenceReminderFrequency]];
    this.adherenceReminderTime = map[colAdherenceReminderTime];
    this.adherenceReminderMessage = map[colAdherenceReminderMessage] == null ? null : AdherenceReminderMessage.values[map[colAdherenceReminderMessage]];
    if (map[colARTRefillReminderEnabled] != null) {
      this.artRefillReminderEnabled = map[colARTRefillReminderEnabled] == 1;
    }
    this.artRefillReminderDaysBefore = map[colARTRefillReminderDaysBefore] == null ? null : ARTRefillReminderDaysBeforeSelection.deserializeFromJSON(map[colARTRefillReminderDaysBefore]);
    if (map[colVLNotificationEnabled] != null) {
      this.vlNotificationEnabled = map[colVLNotificationEnabled] == 1;
    }
    this.vlNotificationMessageSuppressed = map[colVLNotificationMessageSuppressed] == null ? null : VLSuppressedMessage.values[map[colVLNotificationMessageSuppressed]];
    this.vlNotificationMessageUnsuppressed = map[colVLNotificationMessageUnsuppressed] == null ? null : VLUnsuppressedMessage.values[map[colVLNotificationMessageUnsuppressed]];
    this.pePhoneNumber = map[colPEPhoneNumber];
    this.supportPreferences = SupportPreferencesSelection.deserializeFromJSON(map[colSupportPreferences]);
  }

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
    map[colPhoneAvailable] = phoneAvailable;
    map[colPatientPhoneNumber] = patientPhoneNumber;
    map[colAdherenceReminderEnabled] = adherenceReminderEnabled;
    map[colAdherenceReminderFrequency] = adherenceReminderFrequency?.index;
    map[colAdherenceReminderTime] = adherenceReminderTime;
    map[colAdherenceReminderMessage] = adherenceReminderMessage?.index;
    map[colARTRefillReminderEnabled] = artRefillReminderEnabled;
    map[colARTRefillReminderDaysBefore] = artRefillReminderDaysBefore?.serializeToJSON();
    map[colVLNotificationEnabled] = vlNotificationEnabled;
    map[colVLNotificationMessageSuppressed] = vlNotificationMessageSuppressed?.index;
    map[colVLNotificationMessageUnsuppressed] = vlNotificationMessageUnsuppressed?.index;
    map[colPEPhoneNumber] = pePhoneNumber;
    map[colSupportPreferences] = supportPreferences.serializeToJSON();
    return map;
  }

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  set createdDate(DateTime date) => this._createdDate = date;

  DateTime get createdDate => this._createdDate;

}

class ARTRefillReminderDaysBeforeSelection {
  bool sevenDaysBeforeSelected = false;
  bool twoDaysBeforeSelected = false;
  bool oneDayBeforeSelected = false;

  static String get sevenDaysBeforeDescription => "7 Days Before";
  static String get twoDaysBeforeDescription => "2 Days Before";
  static String get oneDayBeforeDescription => "1 Day Before";

  void deselectAll() {
    sevenDaysBeforeSelected = false;
    twoDaysBeforeSelected = false;
    oneDayBeforeSelected = false;
  }

  bool get areAllDeselected {
    return !(sevenDaysBeforeSelected ||
        twoDaysBeforeSelected ||
        oneDayBeforeSelected);
  }

  String serializeToJSON() {
    var map = Map<String, bool>();
    map['sevenDaysBeforeSelected'] = sevenDaysBeforeSelected;
    map['twoDaysBeforeSelected'] = twoDaysBeforeSelected;
    map['oneDayBeforeSelected'] = oneDayBeforeSelected;
    return jsonEncode(map);
  }

  static ARTRefillReminderDaysBeforeSelection deserializeFromJSON(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    var obj = ARTRefillReminderDaysBeforeSelection();
    obj.sevenDaysBeforeSelected = map['sevenDaysBeforeSelected'] ?? false;
    obj.twoDaysBeforeSelected = map['twoDaysBeforeSelected'] ?? false;
    obj.oneDayBeforeSelected = map['oneDayBeforeSelected'] ?? false;
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
enum VLSuppressedMessage { MESSAGE_1, MESSAGE_2 }

// Do not change the order of the enums as their index is used to store the instance in the database!
enum VLUnsuppressedMessage { MESSAGE_1, MESSAGE_2 }
