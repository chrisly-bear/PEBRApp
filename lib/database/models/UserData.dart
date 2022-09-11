import 'dart:io';

import 'package:path/path.dart';
import 'package:pebrapp/database/DatabaseExporter.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/HealthCenter.dart';
import 'package:pebrapp/utils/Utils.dart';

class UserData implements IExcelExportable {
  static final tableName = 'UserData';

  // column names
  static final colId = 'id'; // primary key
  static final colCreatedDate = 'created_date';
  static final colFirstName =
      'first_name'; // foreign key to [Patient].art_number
  static final colLastName = 'last_name';
  static final colUsername = 'username';
  static final colPhoneNumber = 'phone_number';
  static final colPhoneNumberUploadRequired = 'phone_number_upload_required';
  static final colHealthCenter = 'health_center';
  static final colIsActive = 'is_active';
  static final colDeactivatedDate = 'deactivated_date'; // nullable

  DateTime _createdDate;
  String firstName;
  String lastName;
  String username;
  String phoneNumber;
  bool phoneNumberUploadRequired;
  HealthCenter healthCenter;
  bool isActive;
  DateTime _deactivatedDate;

  // Constructors
  // ------------

  UserData(
      {this.firstName,
      this.lastName,
      this.username,
      this.phoneNumber,
      this.healthCenter,
      this.isActive});

  UserData.fromMap(map) {
    this._createdDate = DateTime.parse(map[colCreatedDate]);
    this.firstName = map[colFirstName];
    this.lastName = map[colLastName];
    this.username = map[colUsername];
    this.phoneNumber = map[colPhoneNumber];
    this.phoneNumberUploadRequired = map[colPhoneNumberUploadRequired] == 1;
    this.healthCenter = HealthCenter.fromCode(map[colHealthCenter]);
    this.isActive = map[colIsActive] == 1;
    this.deactivatedDate = map[colDeactivatedDate] == null
        ? null
        : DateTime.parse(map[colDeactivatedDate]);
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
    map[colPhoneNumberUploadRequired] = phoneNumberUploadRequired;
    map[colHealthCenter] = healthCenter.code;
    map[colIsActive] = isActive;
    map[colDeactivatedDate] = _deactivatedDate?.toIso8601String();
    return map;
  }

  static const int _numberOfColumns = 13;

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
    row[6] = 'CELL_PE_SYNCED';
    row[7] = 'CLUSTER';
    row[8] = 'DISTRICT';
    row[9] = 'ARM';
    row[10] = 'ACTIVE';
    row[11] = 'DATE_DEACTIVATED';
    row[12] = 'TIME_DEACTIVATED';
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
    row[6] = !phoneNumberUploadRequired;
    row[7] = healthCenter.description;
    row[8] = healthCenter.district;
    row[9] = healthCenter.studyArm;
    row[10] = isActive;
    row[11] = formatDateIso(_deactivatedDate);
    row[12] = formatTimeIso(_deactivatedDate);
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

  /// Throws FileSystemException if no password file is present on the device.
  Future<String> get pinCodeHash async {
    final String filepath =
        join(await DatabaseProvider().databasesDirectoryPath, 'PEBRA-password');
    final File passwordFile = File(filepath);
    return await passwordFile.readAsString();
  }
}
