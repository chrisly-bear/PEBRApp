import 'dart:async';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Access to the SQFLite database.
/// Get an instance either via `DatabaseProvider.instance` or via the singleton constructor `DatabaseProvider()`.
class DatabaseProvider {
  // Increase the _DB_VERSION number if you made changes to the database schema.
  // An increase will call the [_onUpgrade] method.
  static const int _DB_VERSION = 1;
  static Database _database;

  // private constructor for Singleton pattern
  DatabaseProvider._();

  static final DatabaseProvider instance = DatabaseProvider._();

  factory DatabaseProvider() {
    return instance;
  }

  get _databaseInstance async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await _initDB();
    return _database;
  }

  _initDB() async {
    String path = join(await getDatabasesPath(), "PEBRApp.db");
    print('DATABASE PATH: $path');
    return await openDatabase(path, version: _DB_VERSION, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    print('Creating database with version $version');
    await db.execute("""
        CREATE TABLE IF NOT EXISTS ${Patient.tableName} (
          ${Patient.colId} INTEGER PRIMARY KEY,
          ${Patient.colARTNumber} TEXT NOT NULL,
          ${Patient.colCreatedDate} INTEGER NOT NULL,
          ${Patient.colIsActivated} BIT NOT NULL,
          ${Patient.colIsVLSuppressed} BIT,
          ${Patient.colVillage} TEXT,
          ${Patient.colDistrict} TEXT,
          ${Patient.colPhoneNumber} TEXT,
          ${Patient.colLatestPreferenceAssessment} INTEGER
        );
        """);
    await db.execute("""
        CREATE TABLE IF NOT EXISTS ${PreferenceAssessment.tableName} (
          ${PreferenceAssessment.colId} INTEGER PRIMARY KEY,
          ${PreferenceAssessment.colPatientART} TEXT NOT NULL, 
          ${PreferenceAssessment.colCreatedDate} INTEGER NOT NULL,
          ${PreferenceAssessment.colARTRefillOption1} INTEGER NOT NULL,
          ${PreferenceAssessment.colARTRefillOption2} INTEGER,
          ${PreferenceAssessment.colARTRefillOption3} INTEGER,
          ${PreferenceAssessment.colARTRefillOption4} INTEGER,
          ${PreferenceAssessment.colARTRefillPersonName} TEXT,
          ${PreferenceAssessment.colARTRefillPersonPhoneNumber} TEXT,
          ${PreferenceAssessment.colPhoneAvailable} BIT NOT NULL,
          ${PreferenceAssessment.colPatientPhoneNumber} TEXT,
          ${PreferenceAssessment.colAdherenceReminderEnabled} BIT,
          ${PreferenceAssessment.colAdherenceReminderFrequency} INTEGER,
          ${PreferenceAssessment.colAdherenceReminderTime} TEXT,
          ${PreferenceAssessment.colAdherenceReminderMessage} TEXT,
          ${PreferenceAssessment.colVLNotificationEnabled} BIT,
          ${PreferenceAssessment.colVLNotificationMessageSuppressed} TEXT,
          ${PreferenceAssessment.colVLNotificationMessageUnsuppressed} TEXT,
          ${PreferenceAssessment.colPEPhoneNumber} TEXT,
          ${PreferenceAssessment.colSupportPreferences} TEXT
        );
        """);
        // TODO: set colLatestPreferenceAssessment as foreign key to `PreferenceAssessment` table
        //       set colPatientART as foreign key to `Patient` table
  }

  
  // Private Methods
  // ---------------

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) {
    print('Upgrading database from version $oldVersion to version $newVersion');
    // make sure any new tables, which don't exist yet, are created
    return _onCreate(db, newVersion);
  }


  // Public Methods
  // --------------

  Future<void> insertPatient(Patient newPatient) async {
    final Database db = await _databaseInstance;
    newPatient.createdDate = DateTime.now().toUtc();
    final res = await db.insert(Patient.tableName, newPatient.toMap());
    return res;
  }

  /// Retrieves a list of all patient ART numbers in the database.
  Future<List<String>> retrievePatientsART() async {
    final Database db = await _databaseInstance;
    final res = await db.rawQuery("SELECT DISTINCT ${Patient.colARTNumber} FROM ${Patient.tableName}");
    return res.isNotEmpty ? res.map((entry) => entry[Patient.colARTNumber] as String).toList() : List<String>();
  }

  /// Retrieves only the latest patients from the database, i.e. the ones with the latest changes.
  ///
  /// SQL Query:
  /// SELECT Patient.* FROM Patient INNER JOIN (
  ///	  SELECT id, MAX(created_date) FROM Patient GROUP BY art_number
  ///	) latest ON Patient.id == latest.id
  Future<List<Patient>> retrieveLatestPatients() async {
    final Database db = await _databaseInstance;
    final res = await db.rawQuery("""
    SELECT ${Patient.tableName}.* FROM ${Patient.tableName} INNER JOIN (
	    SELECT ${Patient.colId}, MAX(${Patient.colCreatedDate}) FROM ${Patient.tableName} GROUP BY ${Patient.colARTNumber}
	  ) latest ON ${Patient.tableName}.${Patient.colId} == latest.${Patient.colId}
    """);
    List<Patient> list = List<Patient>();
    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        Patient p = Patient.fromMap(map);
        await p.initializePreferenceAssessmentField();
        list.add(p);
      }
    }
    return list;
  }

  Future<void> insertPreferenceAssessment(PreferenceAssessment newPreferenceAssessment) async {
    final Database db = await _databaseInstance;
    newPreferenceAssessment.createdDate = DateTime.now().toUtc();
    final res = await db.insert(PreferenceAssessment.tableName, newPreferenceAssessment.toMap());
    return res;
  }

  Future<PreferenceAssessment> retrieveLatestPreferenceAssessmentForPatient(String patientART) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(
        PreferenceAssessment.tableName,
        where: '${PreferenceAssessment.colPatientART} = ?',
        whereArgs: [patientART],
        orderBy: PreferenceAssessment.colCreatedDate
    );
    if (res.length > 0) {
      return PreferenceAssessment.fromMap(res.first);
    }
    return null;
  }


  // Debug methods (should be removed/disabled for final release)
  // ------------------------------------------------------------
  // TODO: remove/disable these functions for the final release

  /// Retrieves all patients from the database, including duplicates created when editing a patient.
  Future<List<Patient>> retrieveAllPatients() async {
    final Database db = await _databaseInstance;
    // query the table for all patients
    final res = await db.query(Patient.tableName);
    List<Patient> list = List<Patient>();
    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        Patient p = Patient.fromMap(map);
        await p.initializePreferenceAssessmentField();
        list.add(p);
      }
    }
    return list;
  }

  /// Retrieves a table's column names.
  Future<List<Map<String, dynamic>>> getTableInfo(String tableName) async {
    final Database db = await _databaseInstance;
    var res = db.rawQuery("PRAGMA table_info($tableName);");
    return res;
  }

  /// Deletes a patient from the Patient table and its corresponding entries from the PreferenceAssessment table.
  Future<int> deletePatient(Patient deletePatient) async {
    final Database db = await _databaseInstance;
    final String artNumber = deletePatient.artNumber;
    final int rowsDeletedPatientTable = await db.delete(Patient.tableName, where: '${Patient.colARTNumber} = ?', whereArgs: [artNumber]);
    final int rowsDeletedPreferenceAssessmentTable = await db.delete(PreferenceAssessment.tableName, where: '${PreferenceAssessment.colPatientART} = ?', whereArgs: [artNumber]);
    return rowsDeletedPatientTable + rowsDeletedPreferenceAssessmentTable;
  }

}
