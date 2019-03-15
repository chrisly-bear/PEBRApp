
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
  String _patientART; // foreign key to [Patient].art_number
  DateTime _createdDate;
  ARTRefillOption _artRefillOption1;
  ARTRefillOption _artRefillOption2; // nullable
  ARTRefillOption _artRefillOption3; // nullable
  ARTRefillOption _artRefillOption4; // nullable
  String _artRefillPersonName; // nullable
  String _artRefillPersonPhoneNumber; // nullable
  bool _phoneAvailable;
  String _patientPhoneNumber; // nullable
  bool _adherenceReminderEnabled; // nullable
  AdherenceReminderFrequency _adherenceReminderFrequency; // nullable
  String _adherenceReminderTime; // nullable
  String _adherenceReminderMessage; // nullable
  bool _vlNotificationEnabled; // nullable
  String _vlNotificationMessageSuppressed; // nullable
  String _vlNotificationMessageUnsuppressed; // nullable
  String _pePhoneNumber; // nullable
  List<SupportPreference> _supportPreferences;

  PreferenceAssessment() {
    this._createdDate = DateTime.now();
  }

  PreferenceAssessment.fromMap(map) {
    this._id = map[colId];
    this._patientART = map[colPatientART];
    this._createdDate = DateTime.fromMillisecondsSinceEpoch(map[colCreatedDate]);
    this._artRefillOption1 = map[colARTRefillOption1];
    this._artRefillOption2 = map[colARTRefillOption2];
    this._artRefillOption3 = map[colARTRefillOption3];
    this._artRefillOption4 = map[colARTRefillOption4];
    this._artRefillPersonName = map[colARTRefillPersonName];
    this._artRefillPersonPhoneNumber = map[colARTRefillPersonPhoneNumber];
    if (map[colPhoneAvailable] != null) {
      this._phoneAvailable = map[colPhoneAvailable] == 1;
    }
    this._patientPhoneNumber = map[colPatientPhoneNumber];
    if (map[colAdherenceReminderEnabled] != null) {
      this._adherenceReminderEnabled = map[colAdherenceReminderEnabled] == 1;
    }
    this._adherenceReminderFrequency = map[colAdherenceReminderFrequency];
    this._adherenceReminderTime = map[colAdherenceReminderTime];
    this._adherenceReminderMessage = map[colAdherenceReminderMessage];
    if (map[colVLNotificationEnabled] != null) {
      this._vlNotificationEnabled = map[colVLNotificationEnabled] == 1;
    }
    this._vlNotificationMessageSuppressed = map[colVLNotificationMessageSuppressed];
    this._vlNotificationMessageUnsuppressed = map[colVLNotificationMessageUnsuppressed];
    this._pePhoneNumber = map[colPEPhoneNumber];
    this._supportPreferences = _parseSupportPreferences(map[colSupportPreferences]);
  }

  toMap() {
    var map = {};
    map[colPatientART] = _patientART;
    map[colCreatedDate] = _createdDate.millisecondsSinceEpoch;
    if (_id != null) {
      map[colId] = _id;
    }
    return map;
  }

  List<SupportPreference> _parseSupportPreferences(String string) {
    // TODO: implement
    return null;
  }

}

enum ARTRefillOption { CLINIC, PE_HOME_DELIVERY, VHW, TREATMENT_BUDDY, COMMUNITY_ADHERENCE_CLUB }

enum AdherenceReminderFrequency { DAILY, WEEKLY, MONTHLY }

enum SupportPreference { SATURDAY_CLINIC_CLUB, COMMUNITY_YOUTH_CLUB, PHONE_CALL_PE, HOME_VISIT_PE, NURSE_AT_CLINIC }
