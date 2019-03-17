import 'dart:convert';

class PreferenceAssessment {
  static final tableName = 'PreferenceAssessment';

  // column names
  static final colId = 'id';
  static final colPatientART = 'patient_art';
  static final colCreatedDate = 'created_date';
  static final colARTRefillOption1 = 'art_refill_option_1';
  static final colARTRefillOption2 = 'art_refill_option_2';
  static final colARTRefillOption3 = 'art_refill_option_3';
  static final colARTRefillOption4 = 'art_refill_option_4';
  static final colARTRefillPersonName = 'art_refill_person_name';
  static final colARTRefillPersonPhoneNumber = 'art_refill_person_phone_number';
  static final colPhoneAvailable = 'phone_available';
  static final colPatientPhoneNumber = 'patient_phone_number';
  static final colAdherenceReminderEnabled = 'adherence_reminder_enabled';
  static final colAdherenceReminderFrequency = 'adherence_reminder_frequency';
  static final colAdherenceReminderTime = 'adherence_reminder_time';
  static final colAdherenceReminderMessage = 'adherence_reminder_message';
  static final colVLNotificationEnabled = 'vl_notification_enabled';
  static final colVLNotificationMessageSuppressed = 'vl_notification_message_suppressed';
  static final colVLNotificationMessageUnsuppressed = 'vl_notification_message_unsuppressed';
  static final colPEPhoneNumber = 'pe_phone_number';
  static final colSupportPreferences = 'support_preferences';

  int _id; // primary key
  String patientART; // foreign key to [Patient].art_number
  DateTime createdDate;
  ARTRefillOption artRefillOption1;
  ARTRefillOption artRefillOption2; // nullable
  ARTRefillOption artRefillOption3; // nullable
  ARTRefillOption artRefillOption4; // nullable
  String artRefillPersonName; // nullable
  String artRefillPersonPhoneNumber; // nullable
  bool phoneAvailable;
  String patientPhoneNumber; // nullable
  bool adherenceReminderEnabled; // nullable
  AdherenceReminderFrequency adherenceReminderFrequency; // nullable
  String adherenceReminderTime; // nullable
  String adherenceReminderMessage; // nullable
  bool vlNotificationEnabled; // nullable
  String vlNotificationMessageSuppressed; // nullable
  String vlNotificationMessageUnsuppressed; // nullable
  String pePhoneNumber; // nullable
  SupportPreferencesSelection supportPreferences = SupportPreferencesSelection();

  PreferenceAssessment(
      this.patientART,
      this.artRefillOption1,
      this.phoneAvailable,
      this.supportPreferences,
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
    this._id = map[colId];
    this.patientART = map[colPatientART];
    this.createdDate = DateTime.fromMillisecondsSinceEpoch(map[colCreatedDate]);
    this.artRefillOption1 = map[colARTRefillOption1];
    this.artRefillOption2 = map[colARTRefillOption2];
    this.artRefillOption3 = map[colARTRefillOption3];
    this.artRefillOption4 = map[colARTRefillOption4];
    this.artRefillPersonName = map[colARTRefillPersonName];
    this.artRefillPersonPhoneNumber = map[colARTRefillPersonPhoneNumber];
    if (map[colPhoneAvailable] != null) {
      this.phoneAvailable = map[colPhoneAvailable] == 1;
    }
    this.patientPhoneNumber = map[colPatientPhoneNumber];
    if (map[colAdherenceReminderEnabled] != null) {
      this.adherenceReminderEnabled = map[colAdherenceReminderEnabled] == 1;
    }
    this.adherenceReminderFrequency = map[colAdherenceReminderFrequency];
    this.adherenceReminderTime = map[colAdherenceReminderTime];
    this.adherenceReminderMessage = map[colAdherenceReminderMessage];
    if (map[colVLNotificationEnabled] != null) {
      this.vlNotificationEnabled = map[colVLNotificationEnabled] == 1;
    }
    this.vlNotificationMessageSuppressed = map[colVLNotificationMessageSuppressed];
    this.vlNotificationMessageUnsuppressed = map[colVLNotificationMessageUnsuppressed];
    this.pePhoneNumber = map[colPEPhoneNumber];
    this.supportPreferences = SupportPreferencesSelection.deserializeFromJSON(map[colSupportPreferences]);
  }

  toMap() {
    var map = Map<String, dynamic>();
    map[colId] = _id;
    map[colPatientART] = patientART;
    map[colCreatedDate] = createdDate.millisecondsSinceEpoch;
    map[colARTRefillOption1] = artRefillOption1;
    map[colARTRefillOption2] = artRefillOption2;
    map[colARTRefillOption3] = artRefillOption3;
    map[colARTRefillOption4] = artRefillOption4;
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
    return map;
  }

}

class SupportPreferencesSelection {
  bool saturdayClinicClubSelected = false;
  bool communityYouthClubSelected = false;
  bool phoneCallPESelected = false;
  bool homeVisitPESelected = false;
  bool nurseAtClinicSelected = false;

  void deselectAll() {
    saturdayClinicClubSelected = false;
    communityYouthClubSelected = false;
    phoneCallPESelected = false;
    homeVisitPESelected = false;
    nurseAtClinicSelected = false;
  }

  bool get areAllDeselected {
    return !(saturdayClinicClubSelected ||
        communityYouthClubSelected ||
        phoneCallPESelected ||
        homeVisitPESelected ||
        nurseAtClinicSelected);
  }

  String serializeToJSON() {
    var map = Map<String, bool>();
    map['saturdayClinicClubSelected'] = saturdayClinicClubSelected;
    map['communityYouthClubSelected'] = communityYouthClubSelected;
    map['phoneCallPESelected'] = phoneCallPESelected;
    map['homeVisitPESelected'] = homeVisitPESelected;
    map['nurseAtClinicSelected'] = nurseAtClinicSelected;
    return jsonEncode(map);
  }

  static SupportPreferencesSelection deserializeFromJSON(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    var obj = SupportPreferencesSelection();
    obj.saturdayClinicClubSelected = map['saturdayClinicClubSelected'];
    obj.communityYouthClubSelected = map['communityYouthClubSelected'];
    obj.phoneCallPESelected = map['phoneCallPESelected'];
    obj.homeVisitPESelected = map['homeVisitPESelected'];
    obj.nurseAtClinicSelected = map['nurseAtClinicSelected'];
    return obj;
  }

}

enum ARTRefillOption { CLINIC, PE_HOME_DELIVERY, VHW, TREATMENT_BUDDY, COMMUNITY_ADHERENCE_CLUB }

enum AdherenceReminderFrequency { DAILY, WEEKLY, MONTHLY }

enum SupportPreference { SATURDAY_CLINIC_CLUB, COMMUNITY_YOUTH_CLUB, PHONE_CALL_PE, HOME_VISIT_PE, NURSE_AT_CLINIC }
