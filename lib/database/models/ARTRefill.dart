import 'package:pebrapp/database/DatabaseExporter.dart';
import 'package:pebrapp/database/beans/ARTRefillNotDoneReason.dart';
import 'package:pebrapp/database/beans/RefillType.dart';
import 'package:pebrapp/utils/Utils.dart';

class ARTRefill implements IExcelExportable {
  static final tableName = 'ARTRefill';

  // column names
  static final colId = 'id'; // primary key
  static final colPatientART =
      'patient_art'; // foreign key to [Patient].art_number
  static final colCreatedDate = 'created_date';
  static final colRefillType = 'refill_type';
  static final colNextRefillDate = 'next_refill_date'; // nullable
  static final colNotDoneReason = 'not_done_reason'; // nullable
  static final colDateOfDeath = 'date_of_death'; // nullable
  static final colCauseOfDeath = 'cause_of_death'; // nullable
  static final colHospitalizedClinic = 'hospitalized_clinic'; // nullable
  static final colOtherClinic = 'other_clinic'; // nullable
  static final colTransferDate = 'transfer_date'; // nullable
  static final colNotTakingARTReason = 'not_taking_art_reason'; // nullable

  String patientART;
  DateTime _createdDate;
  RefillType _refillType;
  DateTime nextRefillDate;
  ARTRefillNotDoneReason notDoneReason;
  DateTime dateOfDeath;
  String causeOfDeath;
  String hospitalizedClinic;
  String otherClinic;
  DateTime transferDate;
  String notTakingARTReason;

  // Constructors
  // ------------

  ARTRefill(
    this.patientART,
    this._refillType, {
    this.nextRefillDate,
    this.notDoneReason,
    this.dateOfDeath,
    this.causeOfDeath,
    this.hospitalizedClinic,
    this.otherClinic,
    this.transferDate,
    this.notTakingARTReason,
  });

  ARTRefill.uninitialized();

  ARTRefill.fromMap(map) {
    this.patientART = map[colPatientART];
    this.createdDate = DateTime.parse(map[colCreatedDate]);
    this._refillType = RefillType.fromCode(map[colRefillType]);
    this.nextRefillDate = map[colNextRefillDate] == null
        ? null
        : DateTime.parse(map[colNextRefillDate]);
    this.notDoneReason = ARTRefillNotDoneReason.fromCode(map[colNotDoneReason]);
    this.dateOfDeath = map[colDateOfDeath] == null
        ? null
        : DateTime.parse(map[colDateOfDeath]);
    this.causeOfDeath = map[colCauseOfDeath];
    this.hospitalizedClinic = map[colHospitalizedClinic];
    this.otherClinic = map[colOtherClinic];
    this.transferDate = map[colTransferDate] == null
        ? null
        : DateTime.parse(map[colTransferDate]);
    this.notTakingARTReason = map[colNotTakingARTReason];
  }

  // Other
  // -----

  toMap() {
    var map = Map<String, dynamic>();
    map[colPatientART] = patientART;
    map[colCreatedDate] = createdDate.toIso8601String();
    map[colRefillType] = _refillType.code;
    map[colNextRefillDate] = nextRefillDate?.toIso8601String();
    map[colNotDoneReason] = notDoneReason?.code;
    map[colDateOfDeath] = dateOfDeath?.toIso8601String();
    map[colCauseOfDeath] = causeOfDeath;
    map[colHospitalizedClinic] = hospitalizedClinic;
    map[colOtherClinic] = otherClinic;
    map[colTransferDate] = transferDate?.toIso8601String();
    map[colNotTakingARTReason] = notTakingARTReason;
    return map;
  }

  static const int _numberOfColumns = 12;

  /// Column names for the header row in the excel sheet.
  // If we change the order here, make sure to change the order in the
  // [toExcelRow] method as well!
  static List<String> get excelHeaderRow {
    List<String> row = List<String>(_numberOfColumns);
    row[0] = 'DATE_CREATED';
    row[1] = 'TIME_CREATED';
    row[2] = 'DATE_NEXT';
    row[3] = 'REFILL_TYPE';
    row[4] = 'REFILL_NO';
    row[5] = 'DEATH_DATE';
    row[6] = 'DEATH_CAUSE';
    row[7] = 'HOSP';
    row[8] = 'TRANSFER_TO';
    row[9] = 'TRANSFER_DATE';
    row[10] = 'ART_STOP';
    row[11] = 'IND_ID';
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
    row[2] = formatDateIso(nextRefillDate);
    row[3] = _refillType.code;
    row[4] = notDoneReason?.code;
    row[5] = formatDateIso(dateOfDeath);
    row[6] = causeOfDeath;
    row[7] = hospitalizedClinic;
    row[8] = otherClinic;
    row[9] = formatDateIso(transferDate);
    row[10] = notTakingARTReason;
    row[11] = patientART;
    return row;
  }

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  set createdDate(DateTime date) => this._createdDate = date;

  DateTime get createdDate => this._createdDate;

  RefillType get refillType => this._refillType;
}
