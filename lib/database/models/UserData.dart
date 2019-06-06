
import 'package:pebrapp/database/DatabaseExporter.dart';
import 'package:pebrapp/database/beans/HealthCenter.dart';
import 'package:pebrapp/utils/Utils.dart';

class UserData implements IExcelExportable {
  static final tableName = 'UserData';

  // column names
  static final colId = 'id'; // primary key
  static final colCreatedDate = 'created_date_utc';
  static final colFirstName = 'first_name'; // foreign key to [Patient].art_number
  static final colLastName = 'last_name';
  static final colUsername = 'username';
  static final colPhoneNumber = 'phone_number';
  static final colHealthCenter = 'health_center';
  static final colIsActive = 'is_active';
  static final colDeactivatedDate = 'deactivated_date_utc'; // nullable

  DateTime _createdDate;
  String firstName;
  String lastName;
  String username;
  String phoneNumber;
  HealthCenter healthCenter;
  bool isActive;
  DateTime _deactivatedDate;

  // Constructors
  // ------------

  UserData({this.firstName, this.lastName, this.username, this.phoneNumber, this.healthCenter, this.isActive});

  UserData.fromMap(map) {
    this._createdDate = DateTime.parse(map[colCreatedDate]);
    this.firstName = map[colFirstName];
    this.lastName = map[colLastName];
    this.username = map[colUsername];
    this.phoneNumber = map[colPhoneNumber];
    this.healthCenter = HealthCenter.fromCode(map[colHealthCenter]);
    this.isActive = map[colIsActive] == 1;
    this.deactivatedDate = map[colDeactivatedDate] == null ? null : DateTime.parse(map[colDeactivatedDate]);
  }


  // Other
  // -----

  toMap() {
    var map = Map<String, dynamic>();
    map[colCreatedDate] = _createdDate.toIso8601String();
    map[colFirstName] = firstName;
    map[colLastName] = lastName;
    map[colUsername] = username;
    map[colPhoneNumber] = phoneNumber;
    map[colHealthCenter] = healthCenter.code;
    map[colIsActive] = isActive;
    map[colDeactivatedDate] = _deactivatedDate?.toIso8601String();
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
    row[2] = 'FIRST_NAME_PE';
    row[3] = 'LAST_NAME_PE';
    row[4] = 'USERNAME_PE';
    row[5] = 'CELL_PE';
    row[6] = 'CLUSTER';
    row[7] = 'DISTRICT';
    row[8] = 'ARM';
    row[9] = 'ACTIVE';
    row[10] = 'DATE_DEACTIVATED';
    row[11] = 'TIME_DEACTIVATED';
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
    row[2] = firstName;
    row[3] = lastName;
    row[4] = username;
    row[5] = phoneNumber;
    row[6] = healthCenter.description;
    row[7] = healthCenter.district;
    row[8] = healthCenter.studyArm;
    row[9] = isActive;
    row[10] = formatDateIso(_deactivatedDate);
    row[11] = formatTimeIso(_deactivatedDate);
    return row;
  }

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  // ignore: unnecessary_getters_setters
  set createdDate(DateTime date) => _createdDate = date;

  // ignore: unnecessary_getters_setters
  DateTime get createdDate => _createdDate;

  /// Do not set the deactivatedDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  // ignore: unnecessary_getters_setters
  set deactivatedDate(DateTime date) => _deactivatedDate = date;

  // ignore: unnecessary_getters_setters
  DateTime get deactivatedDate => _deactivatedDate;

}
