
import 'package:pebrapp/config/PEBRAConfig.dart';
import 'package:pebrapp/database/DatabaseExporter.dart';
import 'package:pebrapp/database/beans/ViralLoadSource.dart';
import 'package:pebrapp/utils/Utils.dart';

class ViralLoad implements IExcelExportable {
  static final tableName = 'ViralLoad';

  // column names
  static final colId = 'id'; // primary key
  static final colCreatedDate = 'created_date';
  static final colPatientART = 'patient_art'; // foreign key to [Patient].art_number
  static final colViralLoadSource = 'source';
  static final colViralLoadIsBaseline = 'is_baseline';
  static final colDateOfBloodDraw = 'date_blood_draw';
  static final colLabNumber = 'lab_number';
  static final colIsLowerThanDetectable = 'is_lower_than_detectable';
  static final colViralLoad = 'viral_load'; // nullable
  static final colDiscrepancy = 'discrepancy'; // nullable

  DateTime _createdDate;
  String patientART;
  ViralLoadSource source;
  bool isBaseline;
  DateTime dateOfBloodDraw;
  String labNumber;
  bool isLowerThanDetectable;
  int viralLoad;
  bool discrepancy;

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
    if (map[colDiscrepancy] != null) {
      this.discrepancy = map[colDiscrepancy] == 1;
    }
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
    map[colDiscrepancy] = discrepancy;
    return map;
  }

  static const int _numberOfColumns = 10;

  /// Column names for the header row in the excel sheet.
  // If we change the order here, make sure to change the order in the
  // [toExcelRow] method as well!
  static List<String> get excelHeaderRow {
    List<String> row = List<String>(_numberOfColumns);
    row[0] = 'DATE_CREATED';
    row[1] = 'TIME_CREATED';
    row[2] = 'VL_DATE';
    row[3] = 'IND_ID';
    row[4] = 'VL_LTDL';
    row[5] = 'VL_RESULT';
    row[6] = 'VL_LNO';
    row[7] = 'VL_DISCREPANCY';
    row[8] = 'VL_IS_BASELINE';
    row[9] = 'VL_SOURCE';
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
    row[3] = patientART;
    row[4] = isLowerThanDetectable;
    row[5] = viralLoad;
    row[6] = labNumber;
    row[7] = discrepancy;
    row[8] = isBaseline;
    row[9] = source?.code;
    return row;
  }


  /// Sets fields to null if they are not used. E.g. sets [viralLoad] to null
  /// if [isLowerThanDetectable] is true.
  void checkLogicAndResetUnusedFields() {
    if (this.isLowerThanDetectable) {
      this.viralLoad = null;
    }

    // Only baseline viral load data can have discrepancy, because follow up
    // viral loads only come from the VL database so there's nothing to compare
    // them to, thus there can't be any discrepancy.
    //
    // Only viral load data from the VL database can have discrepancy,
    // because the baseline result is always entered manually first so there's
    // never a discrepancy for manually entered baseline viral loads.
    if (!this.isBaseline || this.source != ViralLoadSource.DATABASE()) {
      this.discrepancy = null;
    }
  }

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  // ignore: unnecessary_getters_setters
  set createdDate(DateTime date) => _createdDate = date;

  // ignore: unnecessary_getters_setters
  DateTime get createdDate => _createdDate;

  /// Returns true if this viral load counts as suppressed (which also the case
  /// if it is lower than detectable limit), false if unsuppressed, and null if
  /// viral load is not defined (which should actually never be the case).
  bool get isSuppressed {
    if (isLowerThanDetectable) {
      return true;
    }
    // if not lower than detectable limit, then viralLoad should not be null
    return viralLoad == null ? null : viralLoad < VL_SUPPRESSED_THRESHOLD;
  }

}
