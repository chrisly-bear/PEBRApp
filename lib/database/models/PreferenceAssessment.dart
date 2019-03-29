import 'dart:convert';

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
  static final colARTRefillPersonName = 'art_refill_person_name'; // nullable
  static final colARTRefillPersonPhoneNumber = 'art_refill_person_phone_number'; // nullable
  static final colPhoneAvailable = 'phone_available';
  static final colPatientPhoneNumber = 'patient_phone_number'; // nullable
  static final colAdherenceReminderEnabled = 'adherence_reminder_enabled'; // nullable
  static final colAdherenceReminderFrequency = 'adherence_reminder_frequency'; // nullable
  static final colAdherenceReminderTime = 'adherence_reminder_time'; // nullable
  static final colAdherenceReminderMessage = 'adherence_reminder_message'; // nullable
  static final colVLNotificationEnabled = 'vl_notification_enabled'; // nullable
  static final colVLNotificationMessageSuppressed = 'vl_notification_message_suppressed'; // nullable
  static final colVLNotificationMessageUnsuppressed = 'vl_notification_message_unsuppressed'; // nullable
  static final colPEPhoneNumber = 'pe_phone_number'; // nullable
  static final colSupportPreferences = 'support_preferences';
  static final colEACOption = 'eac_option';

  String patientART;
  DateTime _createdDate;
  ARTRefillOption artRefillOption1;
  ARTRefillOption artRefillOption2;
  ARTRefillOption artRefillOption3;
  ARTRefillOption artRefillOption4;
  String artRefillPersonName;
  String artRefillPersonPhoneNumber;
  bool phoneAvailable;
  String patientPhoneNumber;
  bool adherenceReminderEnabled;
  AdherenceReminderFrequency adherenceReminderFrequency;
  String adherenceReminderTime;
  String adherenceReminderMessage;
  bool vlNotificationEnabled;
  String vlNotificationMessageSuppressed;
  String vlNotificationMessageUnsuppressed;
  String pePhoneNumber;
  SupportPreferencesSelection supportPreferences = SupportPreferencesSelection();
  EACOption eacOption;


  // Constructors
  // ------------

  PreferenceAssessment(
      this.patientART,
      this.artRefillOption1,
      this.phoneAvailable,
      this.supportPreferences,
      this.eacOption,
      {
        ARTRefillOption artRefillOption2,
        ARTRefillOption artRefillOption3,
        ARTRefillOption artRefillOption4,
        String artRefillPersonName,
        String artRefillPersonPhoneNumber,
        String patientPhoneNumber,
        bool adherenceReminderEnabled,
        AdherenceReminderFrequency adherenceReminderFrequency,
        String adherenceReminderTime,
        String adherenceReminderMessage,
        bool vlNotificationEnabled,
        String vlNotificationMessageSuppressed,
        String vlNotificationMessageUnsuppressed,
        String pePhoneNumber
      });

  PreferenceAssessment.uninitialized();

  PreferenceAssessment.fromMap(map) {
    this.patientART = map[colPatientART];
    this.createdDate = DateTime.parse(map[colCreatedDate]);
    this.artRefillOption1 = map[colARTRefillOption1] == null ? null : ARTRefillOption.values[map[colARTRefillOption1]];
    this.artRefillOption2 = map[colARTRefillOption2] == null ? null : ARTRefillOption.values[map[colARTRefillOption2]];
    this.artRefillOption3 = map[colARTRefillOption3] == null ? null : ARTRefillOption.values[map[colARTRefillOption3]];
    this.artRefillOption4 = map[colARTRefillOption4] == null ? null : ARTRefillOption.values[map[colARTRefillOption4]];
    this.artRefillPersonName = map[colARTRefillPersonName];
    this.artRefillPersonPhoneNumber = map[colARTRefillPersonPhoneNumber];
    if (map[colPhoneAvailable] != null) {
      this.phoneAvailable = map[colPhoneAvailable] == 1;
    }
    this.patientPhoneNumber = map[colPatientPhoneNumber];
    if (map[colAdherenceReminderEnabled] != null) {
      this.adherenceReminderEnabled = map[colAdherenceReminderEnabled] == 1;
    }
    this.adherenceReminderFrequency = map[colAdherenceReminderFrequency] == null ? null : AdherenceReminderFrequency.values[map[colAdherenceReminderFrequency]];
    this.adherenceReminderTime = map[colAdherenceReminderTime];
    this.adherenceReminderMessage = map[colAdherenceReminderMessage];
    if (map[colVLNotificationEnabled] != null) {
      this.vlNotificationEnabled = map[colVLNotificationEnabled] == 1;
    }
    this.vlNotificationMessageSuppressed = map[colVLNotificationMessageSuppressed];
    this.vlNotificationMessageUnsuppressed = map[colVLNotificationMessageUnsuppressed];
    this.pePhoneNumber = map[colPEPhoneNumber];
    this.supportPreferences = SupportPreferencesSelection.deserializeFromJSON(map[colSupportPreferences]);
    this.eacOption = map[colEACOption] == null ? null : EACOption.values[map[colEACOption]];
  }

  toMap() {
    var map = Map<String, dynamic>();
    map[colPatientART] = patientART;
    map[colCreatedDate] = createdDate.toIso8601String();
    map[colARTRefillOption1] = artRefillOption1.index;
    map[colARTRefillOption2] = artRefillOption2?.index;
    map[colARTRefillOption3] = artRefillOption3?.index;
    map[colARTRefillOption4] = artRefillOption4?.index;
    map[colARTRefillPersonName] = artRefillPersonName;
    map[colARTRefillPersonPhoneNumber] = artRefillPersonPhoneNumber;
    map[colPhoneAvailable] = phoneAvailable;
    map[colPatientPhoneNumber] = patientPhoneNumber;
    map[colAdherenceReminderEnabled] = adherenceReminderEnabled;
    map[colAdherenceReminderFrequency] = adherenceReminderFrequency;
    map[colAdherenceReminderTime] = adherenceReminderTime;
    map[colAdherenceReminderMessage] = adherenceReminderMessage;
    map[colVLNotificationEnabled] = vlNotificationEnabled;
    map[colVLNotificationMessageSuppressed] = vlNotificationMessageSuppressed;
    map[colVLNotificationMessageUnsuppressed] = vlNotificationMessageUnsuppressed;
    map[colPEPhoneNumber] = pePhoneNumber;
    map[colSupportPreferences] = supportPreferences.serializeToJSON();
    map[colEACOption] = eacOption.index;
    return map;
  }

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  set createdDate(DateTime date) => this._createdDate = date;

  DateTime get createdDate => this._createdDate;

}

class SupportPreferencesSelection {
  bool saturdayClinicClubSelected = false;
  bool communityYouthClubSelected = false;
  bool phoneCallPESelected = false;
  bool homeVisitPESelected = false;
  bool nurseAtClinicSelected = false;
  bool schoolTalkPESelected = false;

  static String get saturdayClinicClubDescription => "Saturday Clinic Club";
  static String get communityYouthClubDescription => "Community Youth Club";
  static String get phoneCallPEDescription => "1x Phone Call from PE";
  static String get homeVisitPEDescription => "1x Home Visit from PE";
  static String get nurseAtClinicDescription => "Nurse at the Clinic";
  static String get schoolTalkPEDescription => "School Talk PE";
  static String get noneDescription => "None";

  void deselectAll() {
    saturdayClinicClubSelected = false;
    communityYouthClubSelected = false;
    phoneCallPESelected = false;
    homeVisitPESelected = false;
    nurseAtClinicSelected = false;
    schoolTalkPESelected = false;
  }

  bool get areAllDeselected {
    return !(saturdayClinicClubSelected ||
        communityYouthClubSelected ||
        phoneCallPESelected ||
        homeVisitPESelected ||
        nurseAtClinicSelected ||
        schoolTalkPESelected);
  }

  String serializeToJSON() {
    var map = Map<String, bool>();
    map['saturdayClinicClubSelected'] = saturdayClinicClubSelected;
    map['communityYouthClubSelected'] = communityYouthClubSelected;
    map['phoneCallPESelected'] = phoneCallPESelected;
    map['homeVisitPESelected'] = homeVisitPESelected;
    map['nurseAtClinicSelected'] = nurseAtClinicSelected;
    map['schoolTalkPESelected'] = schoolTalkPESelected;
    return jsonEncode(map);
  }

  static SupportPreferencesSelection deserializeFromJSON(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    var obj = SupportPreferencesSelection();
    obj.saturdayClinicClubSelected = map['saturdayClinicClubSelected'] ?? false;
    obj.communityYouthClubSelected = map['communityYouthClubSelected'] ?? false;
    obj.phoneCallPESelected = map['phoneCallPESelected'] ?? false;
    obj.homeVisitPESelected = map['homeVisitPESelected'] ?? false;
    obj.nurseAtClinicSelected = map['nurseAtClinicSelected'] ?? false;
    obj.schoolTalkPESelected = map['schoolTalkPESelected'] ?? false;
    return obj;
  }

}

// Do not change the order of the enums as their index is used to store the instance in the database!
enum ARTRefillOption { CLINIC, PE_HOME_DELIVERY, VHW, TREATMENT_BUDDY, COMMUNITY_ADHERENCE_CLUB }

// Do not change the order of the enums as their index is used to store the instance in the database!
enum AdherenceReminderFrequency { DAILY, WEEKLY, MONTHLY }

// TODO: create database schema stuff
enum AdherenceReminderMessage { MESSAGE_1, MESSAGE_2 }

enum VLSuppressedMessage { MESSAGE_1, MESSAGE_2 }

enum VLUnsuppressedMessage { MESSAGE_1, MESSAGE_2 }

// Do not change the order of the enums as their index is used to store the instance in the database!
enum EACOption { NURSE_AT_CLINIC, PHONE_CALL_PE, HOME_VISIT_PE }
