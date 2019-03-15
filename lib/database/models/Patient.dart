class Patient {
  static final tableName = 'Patient';

  // column names
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
  bool _vlSuppressed; // nullable
  String _village; // nullable
  String _district; // nullable
  String _phoneNumber; // nullable
  int _latestPreferenceAssessment; // foreign key to [PreferenceAssessment].id, nullable

  Patient(this._artNumber, this._district, this._phoneNumber, this._village) {
    this._createdDate = new DateTime.now();
    this._isActivated = true;
  }

  Patient.fromMap(map) {
    this._id = map[colId];
    this._artNumber = map[colARTNumber];
    this._createdDate = DateTime.fromMillisecondsSinceEpoch(map[colCreatedDate]);
    this._isActivated = map[colIsActivated] == 1;
    if (map[colIsVLSuppressed] != null) {
      this._vlSuppressed = map[colIsVLSuppressed] == 1;
    }
    this._village = map[colVillage];
    this._district = map[colDistrict];
    this._phoneNumber = map[colPhoneNumber];
    this._latestPreferenceAssessment = map[colLatestPreferenceAssessment];
  }

  toMap() {
    var map = Map<String, dynamic>();
    map[colARTNumber] = _artNumber;
    map[colCreatedDate] = _createdDate.millisecondsSinceEpoch;
    map[colIsActivated] = _isActivated;
    map[colIsVLSuppressed] = _vlSuppressed;
    map[colVillage] = _village;
    map[colDistrict] = _district;
    map[colPhoneNumber] = _phoneNumber;
    map[colLatestPreferenceAssessment] = _latestPreferenceAssessment;
    map[colId] = _id;
    return map;
  }

  @override
  String toString() {
    return '''
    _id: $_id,
    _artNumber: $_artNumber,
    _createdDate: $_createdDate,
    _isActivated: $_isActivated,
    _vlSuppressed: $_vlSuppressed,
    _village: $_village,
    _district: $_district,
    _phoneNumber: $_phoneNumber,
    _latestPreferenceAssessment: $_latestPreferenceAssessment
    ''';
  }

  String get artNumber => _artNumber;

  int get latestPreferenceAssessment => _latestPreferenceAssessment;

  String get phoneNumber => _phoneNumber;

  String get district => _district;

  String get village => _village;

  bool get vlSuppressed => _vlSuppressed;

  bool get isActivated => _isActivated;

  DateTime get createdDate => _createdDate;

}
