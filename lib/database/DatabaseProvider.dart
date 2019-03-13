import 'dart:async';
import 'package:pebrapp/database/models/Patient.dart';
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
        )""");
        // TODO: set colLatestPreferenceAssessment as foreign key to `PreferenceAssessment` table
  }

  Future<void> insertPatient(Patient newPatient) async {
    final Database db = await _databaseInstance;
    final res = await db.insert("Patient", newPatient.toMap());
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

}
