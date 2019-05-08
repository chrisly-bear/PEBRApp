import 'dart:async';

import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/ARTRefill.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';

class Patient {
  static final tableName = 'Patient';

  // column names
  static final colId = 'id'; // primary key
  static final colARTNumber = 'art_number';
  static final colCreatedDate = 'created_date_utc';
  static final colIsActivated = 'is_activated';
  static final colIsVLSuppressed = 'is_vl_suppressed'; // nullable
  static final colVillage = 'village'; // nullable
  static final colDistrict = 'district'; // nullable
  static final colPhoneNumber = 'phone_number'; // nullable

  String _artNumber;
  DateTime _createdDate;
  bool _isActivated;
  bool _vlSuppressed;
  String village;
  String district;
  String phoneNumber;
  // The following are not columns in the database, just the objects for easier
  // access to the latest PreferenceAssessment/ARTRefill.
  // Will be null until the [initializePreferenceAssessmentField]/
  // [initializeARTRefillField] method was called.
  PreferenceAssessment latestPreferenceAssessment;
  ARTRefill latestARTRefill;


  // Constructors
  // ------------

  Patient(this._artNumber, this.district, this.phoneNumber, this.village) {
    this._isActivated = true;
  }

  Patient.fromMap(map) {
    this._artNumber = map[colARTNumber];
    this.createdDate = DateTime.parse(map[colCreatedDate]);
    this._isActivated = map[colIsActivated] == 1;
    if (map[colIsVLSuppressed] != null) {
      this._vlSuppressed = map[colIsVLSuppressed] == 1;
    }
    this.village = map[colVillage];
    this.district = map[colDistrict];
    this.phoneNumber = map[colPhoneNumber];
  }

  toMap() {
    var map = Map<String, dynamic>();
    map[colARTNumber] = _artNumber;
    map[colCreatedDate] = createdDate.toIso8601String();
    map[colIsActivated] = _isActivated;
    map[colIsVLSuppressed] = _vlSuppressed;
    map[colVillage] = village;
    map[colDistrict] = district;
    map[colPhoneNumber] = phoneNumber;
    return map;
  }

  @override
  String toString() {
    return '''
    _artNumber: $_artNumber,
    _createdDate: $createdDate,
    _isActivated: $_isActivated,
    _vlSuppressed: $_vlSuppressed,
    _village: $village,
    _district: $district,
    _phoneNumber: $phoneNumber
    ''';
  }

  /// Initializes the field [latestPreferenceAssessment] with the latest data from the database.
  Future<void> initializePreferenceAssessmentField() async {
    PreferenceAssessment pa = await DatabaseProvider().retrieveLatestPreferenceAssessmentForPatient(_artNumber);
    this.latestPreferenceAssessment = pa;
  }

  /// Initializes the field [latestARTRefill] with the latest data from the database.
  Future<void> initializeARTRefillField() async {
    ARTRefill artRefill = await DatabaseProvider().retrieveLatestARTRefillForPatient(_artNumber);
    this.latestARTRefill = artRefill;
  }

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  // ignore: unnecessary_getters_setters
  set createdDate(DateTime date) => _createdDate = date;

  // ignore: unnecessary_getters_setters
  DateTime get createdDate => _createdDate;

  String get artNumber => _artNumber;

  bool get vlSuppressed => _vlSuppressed;

  bool get isActivated => _isActivated;

}
