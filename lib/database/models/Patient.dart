import 'dart:async';

import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';

class Patient {
  static final tableName = 'Patient';

  // column names
  static final colId = 'id'; // primary key
  static final colARTNumber = 'art_number';
  static final colCreatedDate = 'created_date';
  static final colIsActivated = 'is_activated';
  static final colIsVLSuppressed = 'is_vl_suppressed'; // nullable
  static final colVillage = 'village'; // nullable
  static final colDistrict = 'district'; // nullable
  static final colPhoneNumber = 'phone_number'; // nullable
  static final colLatestPreferenceAssessment = 'latest_preference_assessment'; // foreign key to [PreferenceAssessment].id, nullable

  String _artNumber;
  DateTime _createdDate;
  bool _isActivated;
  bool _vlSuppressed;
  String village;
  String district;
  String phoneNumber;
  int _latestPreferenceAssessmentId;
  // The following is not a column in the database, just the object for easier access to the latest PreferenceAssessment.
  // Will be null until the [initializePreferenceAssessmentField] method was called.
  PreferenceAssessment _latestPreferenceAssessment;

  // Constructors

  Patient(this._artNumber, this.district, this.phoneNumber, this.village) {
    this._createdDate = new DateTime.now();
    this._isActivated = true;
  }

  Patient.fromMap(map) {
    this._artNumber = map[colARTNumber];
    this._createdDate = DateTime.fromMillisecondsSinceEpoch(map[colCreatedDate]);
    this._isActivated = map[colIsActivated] == 1;
    if (map[colIsVLSuppressed] != null) {
      this._vlSuppressed = map[colIsVLSuppressed] == 1;
    }
    this.village = map[colVillage];
    this.district = map[colDistrict];
    this.phoneNumber = map[colPhoneNumber];
    this._latestPreferenceAssessmentId = map[colLatestPreferenceAssessment];
  }

  toMap() {
    var map = Map<String, dynamic>();
    map[colARTNumber] = _artNumber;
    map[colCreatedDate] = _createdDate.millisecondsSinceEpoch;
    map[colIsActivated] = _isActivated;
    map[colIsVLSuppressed] = _vlSuppressed;
    map[colVillage] = village;
    map[colDistrict] = district;
    map[colPhoneNumber] = phoneNumber;
    map[colLatestPreferenceAssessment] = _latestPreferenceAssessmentId;
    return map;
  }

  @override
  String toString() {
    return '''
    _artNumber: $_artNumber,
    _createdDate: $_createdDate,
    _isActivated: $_isActivated,
    _vlSuppressed: $_vlSuppressed,
    _village: $village,
    _district: $district,
    _phoneNumber: $phoneNumber,
    _latestPreferenceAssessment: $_latestPreferenceAssessmentId
    ''';
  }

  /// Initializes the field [latestPreferenceAssessment] with the latest data from the database.
  Future<void> initializePreferenceAssessmentField() async {
    PreferenceAssessment pa = await DatabaseProvider().retrieveLatestPreferenceAssessmentForPatient(_artNumber);
    this._latestPreferenceAssessment = pa;
    this._latestPreferenceAssessmentId = pa?.id;
  }

  String get artNumber => _artNumber;

  PreferenceAssessment get latestPreferenceAssessment => _latestPreferenceAssessment;

  bool get vlSuppressed => _vlSuppressed;

  bool get isActivated => _isActivated;

  DateTime get createdDate => _createdDate;

}
