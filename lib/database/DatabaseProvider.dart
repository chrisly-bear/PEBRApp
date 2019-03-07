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
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE ${Patient.tableName} ("
        "${Patient.colId} INTEGER PRIMARY KEY,"
        // "${Patient.colId} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${Patient.colARTNumber} TEXT,"
        "${Patient.colCreatedDate} INTEGER,"
        "${Patient.colIsActivated} BIT"
        "${Patient.colIsVLSuppressed} BIT"
        "${Patient.colVillage} TEXT"
        "${Patient.colDistrict} TEXT"
        "${Patient.colPhoneNumber} TEXT"
        "${Patient.colLatestPreferenceAssessment} INTEGER" // TODO: set as foreign key to `PreferenceAssessment` table
        ")");
  }

  insertPatient(Patient newPatient) async {
    final db = await database;
    var res = await db.insert("Patient", newPatient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return res;
  }

  retrievePatients() async {
    final Database db = await database;
    // query the table for all patients
    final res = await db.query(Patient.tableName);
    final list = res.isNotEmpty ? res.map((patient) => Patient.fromMap(patient)).toList() : [];
    return list;
  }

}
