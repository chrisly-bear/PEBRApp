import 'package:pebrapp/config/PEBRAConfig.dart';
import 'package:pebrapp/database/DatabaseExporter.dart';
import 'package:pebrapp/database/beans/SupportOption.dart';
import 'package:pebrapp/database/beans/ViralLoadSource.dart';
import 'package:pebrapp/utils/Utils.dart';

class SupportOptionDone implements IExcelExportable {
  static final tableName = 'SupportOptionDone';

  // column names
  static final colId = 'id'; // primary key
  static final colCreatedDate = 'created_date';
  static final colPreferenceAssessmentId =
      'preference_assessment_id'; // foreign key to [PreferenceAssessment].id
  static final colSupportOption = 'support_option';
  static final colDone = 'done';

  DateTime _createdDate;
  int preferenceAssessmentId;
  SupportOption supportOption;
  bool done;

  // Constructors
  // ------------

  SupportOptionDone(
      {this.preferenceAssessmentId, this.supportOption, this.done});

  SupportOptionDone.fromMap(map) {
    this._createdDate = DateTime.parse(map[colCreatedDate]);
    this.preferenceAssessmentId = map[colPreferenceAssessmentId];
    this.supportOption = SupportOption.fromCode(map[colSupportOption]);
    this.done = map[colDone] == 1;
  }

  // Other
  // -----

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is SupportOptionDone &&
      o.preferenceAssessmentId == preferenceAssessmentId &&
      o.supportOption == supportOption;

  // override hashcode
  @override
  int get hashCode => preferenceAssessmentId.hashCode ^ supportOption.hashCode;

  toMap() {
    var map = Map<String, dynamic>();
    map[colCreatedDate] = _createdDate.toIso8601String();
    map[colPreferenceAssessmentId] = preferenceAssessmentId;
    map[colSupportOption] = supportOption.code;
    map[colDone] = done;
    return map;
  }

  static const int _numberOfColumns = 5;

  /// Column names for the header row in the excel sheet.
  // If we change the order here, make sure to change the order in the
  // [toExcelRow] method as well!
  static List<String> get excelHeaderRow {
    List<String> row = List<String>(_numberOfColumns);
    row[0] = 'DATE_CREATED';
    row[1] = 'TIME_CREATED';
    row[2] = 'PA_ID';
    row[3] = 'SUPPORT';
    row[4] = 'DONE';
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
    row[2] = preferenceAssessmentId;
    row[3] = supportOption.code;
    row[4] = done;
    return row;
  }

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  // ignore: unnecessary_getters_setters
  set createdDate(DateTime date) => _createdDate = date;

  // ignore: unnecessary_getters_setters
  DateTime get createdDate => _createdDate;
}
