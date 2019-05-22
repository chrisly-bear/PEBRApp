import 'dart:async';

import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/Gender.dart';
import 'package:pebrapp/database/beans/NoConsentReason.dart';
import 'package:pebrapp/database/beans/PhoneAvailability.dart';
import 'package:pebrapp/database/beans/SexualOrientation.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/database/models/ARTRefill.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';


class Patient {
  static final tableName = 'Patient';

  // column names
  static final colId = 'id'; // primary key
  static final colCreatedDate = 'created_date_utc';
  static final colARTNumber = 'art_number';
  static final colStickerNumber = 'sticker_number';
  static final colYearOfBirth = 'year_of_birth';
  static final colIsEligible = 'is_eligible';
  // nullables:
  static final colGender = 'gender'; // nullable
  static final colSexualOrientation = 'sexual_orientation'; // nullable
  static final colVillage = 'village'; // nullable
  static final colPhoneAvailability = 'phone_availability'; // nullable
  static final colPhoneNumber = 'phone_number'; // nullable
  static final colConsentGiven = 'consent_given'; // nullable
  static final colNoConsentReason = 'no_consent_reason'; // nullable
  static final colNoConsentReasonOther = 'no_consent_reason_other'; // nullable
  static final colIsActivated = 'is_activated'; // nullable

  DateTime _createdDate;
  String artNumber;
  String stickerNumber;
  int yearOfBirth;
  bool isEligible;
  Gender gender;
  SexualOrientation sexualOrientation;
  String village;
  PhoneAvailability phoneAvailability;
  String phoneNumber;
  bool consentGiven;
  NoConsentReason noConsentReason;
  String noConsentReasonOther;
  bool isActivated;
  // The following are not columns in the database, just the objects for easier
  // access to the latest PreferenceAssessment/ARTRefill.
  // Will be null until the [initializePreferenceAssessmentField]/
  // [initializeARTRefillField] method was called.
  List<ViralLoad> viralLoadHistory = [];
  PreferenceAssessment latestPreferenceAssessment;
  ARTRefill latestARTRefill;


  // Constructors
  // ------------

  Patient({this.artNumber, this.stickerNumber, this.yearOfBirth, this.gender,
  this.sexualOrientation, this.village, this.phoneAvailability, this.phoneNumber,
  this.consentGiven, this.isActivated});

  Patient.fromMap(map) {
    this.createdDate = DateTime.parse(map[colCreatedDate]);
    this.artNumber = map[colARTNumber];
    this.stickerNumber = map[colStickerNumber];
    this.yearOfBirth = int.parse(map[colYearOfBirth]);
    this.isEligible = map[colIsEligible] == 1;
    // nullables:
    this.gender = Gender.fromCode(map[colGender]);
    this.sexualOrientation = SexualOrientation.fromCode(map[colSexualOrientation]);
    this.village = map[colVillage];
    this.phoneAvailability = PhoneAvailability.fromCode(map[colPhoneAvailability]);
    this.phoneNumber = map[colPhoneNumber];
    if (map[colConsentGiven] != null) {
      this.consentGiven = map[colConsentGiven] == 1;
    }
    this.noConsentReason = NoConsentReason.fromCode(map[colNoConsentReason]);
    this.noConsentReasonOther = map[colNoConsentReasonOther];
    if (map[colIsActivated] != null) {
      this.isActivated = map[colIsActivated] == 1;
    }
  }

  toMap() {
    var map = Map<String, dynamic>();
    map[colCreatedDate] = createdDate.toIso8601String();
    map[colARTNumber] = artNumber;
    map[colStickerNumber] = stickerNumber;
    map[colYearOfBirth] = yearOfBirth;
    map[colIsEligible] = isEligible;
    // nullables:
    map[colGender] = gender?.code;
    map[colSexualOrientation] = sexualOrientation?.code;
    map[colVillage] = village;
    map[colPhoneAvailability] = phoneAvailability?.code;
    map[colPhoneNumber] = phoneNumber;
    map[colConsentGiven] = consentGiven;
    map[colNoConsentReason] = noConsentReason?.code;
    map[colNoConsentReasonOther] = noConsentReasonOther;
    map[colIsActivated] = isActivated;
    return map;
  }

  /// Initializes the field [viralLoadHistory] with the latest data from the database.
  Future<void> initializeViralLoadHistoryField() async {
    List<ViralLoad> history = await DatabaseProvider().retrieveAllViralLoadsForPatient(artNumber);
    this.viralLoadHistory = history;
  }

  /// Initializes the field [latestPreferenceAssessment] with the latest data from the database.
  Future<void> initializePreferenceAssessmentField() async {
    PreferenceAssessment pa = await DatabaseProvider().retrieveLatestPreferenceAssessmentForPatient(artNumber);
    this.latestPreferenceAssessment = pa;
  }

  /// Initializes the field [latestARTRefill] with the latest data from the database.
  Future<void> initializeARTRefillField() async {
    ARTRefill artRefill = await DatabaseProvider().retrieveLatestARTRefillForPatient(artNumber);
    this.latestARTRefill = artRefill;
  }

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  // ignore: unnecessary_getters_setters
  set createdDate(DateTime date) => _createdDate = date;

  // ignore: unnecessary_getters_setters
  DateTime get createdDate => _createdDate;

}
