
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
  ARTRefillOption _artRefillOption2;
  ARTRefillOption _artRefillOption3;
  ARTRefillOption _artRefillOption4;
  String _artRefillPersonName;
  String _artRefillPersonPhoneNumber;
  bool _phoneAvailable;
  String _patientPhoneNumber;
  bool _adherenceReminderEnabled;
  AdherenceReminderFrequency _adherenceReminderFrequency;
  String _adherenceReminderTime;
  String _adherenceReminderMessage;
  bool _vlNotificationEnabled;
  String _vlNotificationMessageSuppressed;
  String _vlNotificationMessageUnsuppressed;
  String _pePhoneNumber;
  List<SupportPreference> _supportPreferences;

  PreferenceAssessment() {
    this._createdDate = DateTime.now();
  }

  PreferenceAssessment.fromMap(map) {
    this._id = map[colId];
    this._patientART = map[colPatientART];
    this._createdDate = DateTime.fromMillisecondsSinceEpoch(map[colCreatedDate]);
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

}

enum ARTRefillOption { CLINIC, PE_HOME_DELIVERY, VHW, TREATMENT_BUDDY, COMMUNITY_ADHERENCE_CLUB }

enum AdherenceReminderFrequency { DAILY, WEEKLY, MONTHLY }

enum SupportPreference { SATURDAY_CLINIC_CLUB, COMMUNITY_YOUTH_CLUB, PHONE_CALL_PE, HOME_VISIT_PE, NURSE_AT_CLINIC }
