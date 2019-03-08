import 'dart:async';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  static Database _database;

  // private constructor for Singleton pattern
  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();

  get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
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
    final db = await database;
    var res = await db.insert("Patient", newPatient.toMap(),
        // conflictAlgorithm: ConflictAlgorithm.ignore);
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<List<Patient>> retrievePatients() async {
    final Database db = await database;
    // query the table for all patients
    final res = await db.query(Patient.tableName);
    final list = res.isNotEmpty ? res.map((patient) => Patient.fromMap(patient)).toList() : List<Patient>();
    return list;
  }

  Future<List<Map<String, dynamic>>> getTableInfo(String tableName) async {
    final Database db = await database;
    var res = db.rawQuery("PRAGMA table_info($tableName);");
    return res;
  }

}
