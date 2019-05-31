import 'dart:async';

import 'package:pebrapp/config/PEBRAConfig.dart';
import 'package:pebrapp/database/DatabaseExporter.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/Gender.dart';
import 'package:pebrapp/database/beans/SexualOrientation.dart';
import 'package:pebrapp/database/beans/ViralLoadSource.dart';
import 'package:pebrapp/database/models/ARTRefill.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/utils/Utils.dart';

class ViralLoad implements IExcelExportable {
  static final tableName = 'ViralLoad';

  // column names
  static final colId = 'id'; // primary key
  static final colCreatedDate = 'created_date_utc';
  static final colPatientART = 'patient_art'; // foreign key to [Patient].art_number
  static final colViralLoadSource = 'entry_source';
  static final colViralLoadIsBaseline = 'is_baseline';
  static final colDateOfBloodDraw = 'date_blood_draw_utc';
  static final colLabNumber = 'lab_number';
  static final colIsLowerThanDetectable = 'is_lower_than_detectable';
  static final colViralLoad = 'viral_load'; // nullable

  DateTime _createdDate;
  String patientART;
  ViralLoadSource source;
  bool isBaseline;
  DateTime dateOfBloodDraw;
  String labNumber;
  bool isLowerThanDetectable;
  int viralLoad;

  // Constructors
  // ------------

  ViralLoad({this.patientART, this.source, this.isBaseline, this.dateOfBloodDraw, this.labNumber, this.isLowerThanDetectable, this.viralLoad});

  ViralLoad.fromMap(map) {
    this.patientART = map[colPatientART];
    this._createdDate = DateTime.parse(map[colCreatedDate]);
    this.source = ViralLoadSource.fromCode(map[colViralLoadSource]);
    this.isBaseline = map[colViralLoadIsBaseline] == 1;
    this.dateOfBloodDraw = DateTime.parse(map[colDateOfBloodDraw]);
    this.labNumber = map[colLabNumber];
    this.isLowerThanDetectable = map[colIsLowerThanDetectable] == 1;
    // nullables:
    this.viralLoad = map[colViralLoad];
  }


  // Other
  // -----

  toMap() {
    var map = Map<String, dynamic>();
    map[colPatientART] = patientART;
    map[colCreatedDate] = _createdDate.toIso8601String();
    map[colViralLoadSource] = source.code;
    map[colViralLoadIsBaseline] = isBaseline;
    map[colDateOfBloodDraw] = dateOfBloodDraw.toIso8601String();
    map[colLabNumber] = labNumber;
    map[colIsLowerThanDetectable] = isLowerThanDetectable;
    // nullables:
    map[colViralLoad] = viralLoad;
    return map;
  }

  static const int _numberOfColumns = 11;

  /// Column names for the header row in the excel sheet.
  // If we change the order here, make sure to change the order in the
  // [toExcelRow] method as well!
  static List<String> get excelHeaderRow {
    List<String> row = List<String>(_numberOfColumns);
    row[0] = 'DATE_CREATED';
    row[1] = 'TIME_CREATED';
    row[2] = 'VL_DATE';
    row[3] = 'VL_TIME';
    row[4] = 'IND_ID';
    row[5] = 'VL_LTDL';
    row[6] = 'VL_RESULT';
    row[7] = 'VL_LNO';
    row[8] = 'VL_DISCREPANCY';
    row[9] = 'VL_IS_BASELINE';
    row[10] = 'VL_SOURCE';
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
    row[2] = formatDateIso(dateOfBloodDraw);
    row[3] = formatTimeIso(dateOfBloodDraw);
    row[4] = patientART;
    row[5] = isLowerThanDetectable;
    row[6] = viralLoad;
    row[7] = labNumber;
    row[8] = null; // TODO
    row[9] = isBaseline;
    row[10] = source?.code;
    return row;
  }


  /// Sets fields to null if they are not used. E.g. sets [viralLoad] to null
  /// if [isLowerThanDetectable] is true.
  void checkLogicAndResetUnusedFields() {
    if (this.isLowerThanDetectable) {
      this.viralLoad = null;
    }
  }

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  // ignore: unnecessary_getters_setters
  set createdDate(DateTime date) => _createdDate = date;

  // ignore: unnecessary_getters_setters
  DateTime get createdDate => _createdDate;

  /// Returns true if this viral load counts as suppressed, false if
  /// unsuppressed, and null if viral load is not defined (e.g. because it was
  /// lower than the detectable limit).
  bool get isSuppressed => viralLoad == null ? null : viralLoad < VL_SUPPRESSED_THRESHOLD;

}
