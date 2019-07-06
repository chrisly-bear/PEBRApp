import 'dart:async';

import 'package:pebrapp/database/DatabaseExporter.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/Gender.dart';
import 'package:pebrapp/database/beans/NoConsentReason.dart';
import 'package:pebrapp/database/beans/PhoneAvailability.dart';
import 'package:pebrapp/database/beans/SexualOrientation.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/database/models/ARTRefill.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/utils/Utils.dart';


class Patient implements IExcelExportable {
  static final tableName = 'Patient';

  // column names
  static final colId = 'id'; // primary key
  static final colCreatedDate = 'created_date';
  static final colEnrollmentDate = 'enrollment_date';
  static final colARTNumber = 'art_number';
  static final colYearOfBirth = 'year_of_birth';
  static final colIsEligible = 'is_eligible';
  // nullables:
  static final colStickerNumber = 'sticker_number';
  static final colIsVLBaselineAvailable = 'is_vl_baseline_available';
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
  DateTime enrollmentDate;
  String artNumber;
  int yearOfBirth;
  bool isEligible;
  String stickerNumber;
  bool isVLBaselineAvailable;
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
  List<ViralLoad> viralLoads = [];
  PreferenceAssessment latestPreferenceAssessment;
  ARTRefill latestARTRefill; // stores the latest ART refill (done or not done)
  ARTRefill latestDoneARTRefill; // stores the latest ART refill that was done
  Set<RequiredAction> requiredActions = {};
  Set<RequiredAction> visibleRequiredActionsAtInitialization = {};


  // Constructors
  // ------------

  Patient({this.enrollmentDate, this.artNumber, this.stickerNumber,
    this.yearOfBirth, this.isEligible, this.isVLBaselineAvailable, this.gender,
    this.sexualOrientation, this.village, this.phoneAvailability,
    this.phoneNumber, this.consentGiven, this.noConsentReason,
    this.noConsentReasonOther, this.isActivated});

  Patient.fromMap(map) {
    this.createdDate = DateTime.parse(map[colCreatedDate]);
    this.enrollmentDate = DateTime.parse(map[colEnrollmentDate]);
    this.artNumber = map[colARTNumber];
    this.yearOfBirth = int.parse(map[colYearOfBirth]);
    this.isEligible = map[colIsEligible] == 1;
    // nullables:
    this.stickerNumber = map[colStickerNumber];
    if (map[colIsVLBaselineAvailable] != null) {
      this.isVLBaselineAvailable = map[colIsVLBaselineAvailable] == 1;
    }
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


  // Other
  // -----

  toMap() {
    var map = Map<String, dynamic>();
    map[colCreatedDate] = createdDate.toIso8601String();
    map[colEnrollmentDate] = enrollmentDate.toIso8601String();
    map[colARTNumber] = artNumber;
    map[colStickerNumber] = stickerNumber;
    map[colYearOfBirth] = yearOfBirth;
    map[colIsEligible] = isEligible;
    // nullables:
    map[colIsVLBaselineAvailable] = isVLBaselineAvailable;
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

  static const int _numberOfColumns = 18;

  /// Column names for the header row in the excel sheet.
  // If we change the order here, make sure to change the order in the
  // [toExcelRow] method as well!
  static List<String> get excelHeaderRow {
    List<String> row = List<String>(_numberOfColumns);
    row[0] = 'DATE_CREATED';
    row[1] = 'TIME_CREATED';
    row[2] = 'DATE_ENROL';
    row[3] = 'TIME_ENROL';
    row[4] = 'IND_ID';
    row[5] = 'BIRTH_YEAR';
    row[6] = 'CONSENT';
    row[7] = 'CONSENT_NO';
    row[8] = 'CONSENT_OTHER';
    row[9] = 'GENDER';
    row[10] = 'SEX_ORIENT';
    row[11] = 'STICKER_ID';
    row[12] = 'VILLAGE';
    row[13] = 'CELL_GIVEN';
    row[14] = 'CELL';
    row[15] = 'VL_BASELINE_AVAILABLE';
    row[16] = 'ACTIVATED';
    row[17] = 'ELIGIBLE';
    return row;
  }

  /// Turns this object into a row that can be written to the excel sheet.
  // If we change the order here, make sure to change the order in the
  // [excelHeaderRow] method as well!
  @override
  List<dynamic> toExcelRow() {
    List<dynamic> row = List<dynamic>(_numberOfColumns);
    row[0] = formatDateIso(_createdDate);
    row[1] = formatTimeIso(_createdDate);
    row[2] = formatDateIso(enrollmentDate);
    row[3] = formatTimeIso(enrollmentDate);
    row[4] = artNumber;
    row[5] = yearOfBirth;
    row[6] = consentGiven;
    row[7] = noConsentReason?.code;
    row[8] = noConsentReasonOther;
    row[9] = gender?.code;
    row[10] = sexualOrientation?.code;
    row[11] = stickerNumber;
    row[12] = village;
    row[13] = phoneAvailability?.code;
    row[14] = phoneNumber;
    row[15] = isVLBaselineAvailable;
    row[16] = isActivated;
    row[17] = isEligible;
    return row;
  }

  /// Initializes the field [viralLoads] with the latest data from the database.
  Future<void> initializeViralLoadsField() async {
    this.viralLoads = await DatabaseProvider().retrieveViralLoadsForPatient(artNumber);
  }

  /// Initializes the field [latestPreferenceAssessment] with the latest data from the database.
  Future<void> initializePreferenceAssessmentField() async {
    PreferenceAssessment pa = await DatabaseProvider().retrieveLatestPreferenceAssessmentForPatient(artNumber);
    this.latestPreferenceAssessment = pa;
  }

  /// Initializes the fields [latestARTRefill] and [latestDoneARTRefill] with
  /// the latest data from the database.
  Future<void> initializeARTRefillField() async {
    ARTRefill artRefill = await DatabaseProvider().retrieveLatestARTRefillForPatient(artNumber);
    this.latestARTRefill = artRefill;
    ARTRefill doneARTRefill = await DatabaseProvider().retrieveLatestDoneARTRefillForPatient(artNumber);
    this.latestDoneARTRefill = doneARTRefill;
  }

  /// Initializes the field [requiredActions] with the latest data from the database.
  ///
  /// Before calling this, [initializeARTRefillField],
  /// [initializePreferenceAssessmentField], [initializeViralLoadsField] should
  /// be called, otherwise actions are required because the fields are not
  /// initialized (null).
  Future<void> initializeRequiredActionsField() async {
    // get required actions stored in database
    final Set<RequiredAction> actions = await DatabaseProvider().retrieveRequiredActionsForPatient(artNumber);
    final DateTime now = DateTime.now();
    // calculate if ART refill is required
    final DateTime dueDateART = latestDoneARTRefill?.nextRefillDate ?? enrollmentDate;
    if (now.isAfter(dueDateART)) {
      RequiredAction artRefillRequired = RequiredAction(artNumber, RequiredActionType.REFILL_REQUIRED, dueDateART);
      actions.add(artRefillRequired);
    }
    // calculate if preference assessment is required
    final DateTime dueDatePA = calculateNextAssessment(latestPreferenceAssessment?.createdDate, isSuppressed(this)) ?? enrollmentDate;
    if (now.isAfter(dueDatePA)) {
      RequiredAction assessmentRequired = RequiredAction(artNumber, RequiredActionType.ASSESSMENT_REQUIRED, dueDatePA);
      actions.add(assessmentRequired);
    }
    this.requiredActions = actions;
    this.visibleRequiredActionsAtInitialization = visibleRequiredActions;
  }

  /// Returns the viral load with the latest blood draw date.
  ///
  /// Might return null if no viral loads are available for this patient or the
  /// viral load fields have not been initialized by calling
  /// [initializeViralLoadsField].
  ViralLoad get mostRecentViralLoad {
    ViralLoad mostRecent;
    for (ViralLoad vl in viralLoads) {
      if (mostRecent == null || !vl.dateOfBloodDraw.isBefore(mostRecent.dateOfBloodDraw)) {
        mostRecent = vl;
      }
    }
    return mostRecent;
  }

  /// Sets fields to null if they are not used. E.g. sets [phoneNumber] to null
  /// if [phoneAvailability] is not YES.
  void checkLogicAndResetUnusedFields() {
    if (!this.isEligible) {
      this.gender = null;
      this.sexualOrientation = null;
      this.village = null;
      this.phoneAvailability = null;
      this.phoneNumber = null;
      this.consentGiven = null;
      this.noConsentReason = null;
      this.noConsentReasonOther = null;
      this.isActivated = null;
    }
    if (this.consentGiven != null && !this.consentGiven) {
      this.gender = null;
      this.sexualOrientation = null;
      this.village = null;
      this.phoneAvailability = null;
      this.phoneNumber = null;
      this.isActivated = null;
      if (this.noConsentReason != NoConsentReason.OTHER()) {
        this.noConsentReasonOther = null;
      }
    }
    if (this.phoneAvailability != null && this.phoneAvailability != PhoneAvailability.YES()) {
      this.phoneNumber = null;
    }
    if (this.consentGiven != null && this.consentGiven) {
      this.noConsentReason = null;
      this.noConsentReasonOther = null;
    }
  }

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  // ignore: unnecessary_getters_setters
  set createdDate(DateTime date) => _createdDate = date;

  // ignore: unnecessary_getters_setters
  DateTime get createdDate => _createdDate;

  /// Filters out endpoint survey actions that are not due yet.
  Set<RequiredAction> get visibleRequiredActions {
    Set<RequiredAction> visibleRequiredActions = {};
    visibleRequiredActions.addAll(requiredActions);
    visibleRequiredActions.removeWhere((RequiredAction a) {
      final bool isEndpointSurveyAndDue = isEndpointSurveyDue(this.enrollmentDate, a.type);
      if (isEndpointSurveyAndDue != null && !isEndpointSurveyAndDue) {
        // endpoint survey not due yet, remove from visible required actions
        return true;
      }
      return false;
    });
    return visibleRequiredActions;
  }

}
