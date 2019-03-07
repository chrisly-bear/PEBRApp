class Patient {
  static final tableName = 'Patient';

  static final colId = 'id';
  static final colARTNumber = 'art_number';
  static final colCreatedDate = 'created_date';
  static final colIsActivated = 'is_activated';
  static final colIsVLSuppressed = 'is_vl_suppressed';
  static final colVillage = 'village';
  static final colDistrict = 'district';
  static final colPhoneNumber = 'phone_number';
  static final colLatestPreferenceAssessment = 'latest_preference_assessment';

  int _id; // primary key
  String _artNumber;
  DateTime _createdDate;
  bool _isActivated;
  bool _vlSuppressed;
  String _village;
  String _district;
  String _phoneNumber;
  int _latestPreferenceAssessment; // foreign key to [PreferenceAssessment] model

  Patient(this._artNumber, this._district, this._phoneNumber, this._village) {
    this._createdDate = new DateTime.now();
    this._isActivated = true;
  }

  Patient.fromMap(map) {
    this._artNumber = map[colARTNumber];
    this._createdDate =
        DateTime.fromMillisecondsSinceEpoch(map[colCreatedDate]);
    this._isActivated = map[colIsActivated] == 1;
    this._vlSuppressed = map[colIsVLSuppressed] == 1;
    this._village = map[colVillage];
    this._district = map[colDistrict];
    this._phoneNumber = map[colPhoneNumber];
    this._latestPreferenceAssessment = map[colLatestPreferenceAssessment];
  }

  toMap() {
    var map = {};
    map[colARTNumber] = _artNumber;
    map[colCreatedDate] = _createdDate.millisecondsSinceEpoch;
    // TODO: try storing it directly as bool (remove the conditionals)
    map[colIsActivated] = _isActivated ? 1 : 0;
    // TODO: try storing it directly as bool (remove the conditionals)
    map[colIsVLSuppressed] = _vlSuppressed ? 1 : 0;
    map[colVillage] = _village;
    map[colDistrict] = _district;
    map[colPhoneNumber] = _phoneNumber;
    map[colLatestPreferenceAssessment] = _latestPreferenceAssessment;
    if (_id != null) {
      map[colId] = _id;
    }
    return map;
  }
}
