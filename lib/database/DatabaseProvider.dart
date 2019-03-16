import 'dart:async';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Access to the SQFLite database.
/// Get an instance either via `DatabaseProvider.instance` or via the singleton constructor `DatabaseProvider()`.
class DatabaseProvider {
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
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  _onCreate(Database db, int version) async {
    await db.execute("""
        CREATE TABLE ${Patient.tableName} (
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
        CREATE TABLE ${PreferenceAssessment.tableName} (
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

  Future<void> insertPatient(Patient newPatient) async {
    final Database db = await _databaseInstance;
    final res = await db.insert(Patient.tableName, newPatient.toMap());
    return res;
  }

  Future<List<String>> retrievePatientsART() async {
    final Database db = await _databaseInstance;
    final res = await db.rawQuery("SELECT ${Patient.colARTNumber} FROM ${Patient.tableName}");
    return res.isNotEmpty ? res.map((entry) => entry[Patient.colARTNumber] as String).toList() : List<String>();
  }

  Future<List<Patient>> retrievePatients() async {
    final Database db = await _databaseInstance;
    // query the table for all patients
    final res = await db.query(Patient.tableName);
    final list = res.isNotEmpty ? res.map((patient) => Patient.fromMap(patient)).toList() : List<Patient>();
    return list;
  }

  Future<List<Map<String, dynamic>>> getTableInfo(String tableName) async {
    final Database db = await _databaseInstance;
    var res = db.rawQuery("PRAGMA table_info($tableName);");
    return res;
  }

  Future<void> insertPreferenceAssessment(PreferenceAssessment newPreferenceAssessment) async {
    final Database db = await _databaseInstance;
    final res = await db.insert(PreferenceAssessment.tableName, newPreferenceAssessment.toMap());
    return res;
  }

}
