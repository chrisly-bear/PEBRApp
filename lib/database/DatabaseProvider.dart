import 'dart:async';
import 'package:pebrapp/config/SwitchConfig.dart';
import 'package:pebrapp/database/DatabaseExporter.dart';
import 'package:pebrapp/database/beans/RefillType.dart';
import 'package:pebrapp/database/beans/ViralLoadSource.dart';
import 'package:pebrapp/database/models/ARTRefill.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/UserData.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/exceptions/NoLoginDataException.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:pebrapp/utils/SwitchToolboxUtils.dart';

/// Access to the SQFLite database.
/// Get an instance either via `DatabaseProvider.instance` or via the singleton constructor `DatabaseProvider()`.
class DatabaseProvider {
  // Increase the _DB_VERSION number if you made changes to the database schema.
  // An increase will call the [_onUpgrade] method.
  static const int _DB_VERSION = 43;
  // Do not access the _database directly (it might be null), instead use the
  // _databaseInstance getter which will initialize the database if it is
  // uninitialized
  static Database _database;
  static const String _dbFilename = "PEBRApp.db";
  static final DatabaseProvider _instance = DatabaseProvider._();

  // private constructor for Singleton pattern
  DatabaseProvider._();
  factory DatabaseProvider() {
    return _instance;
  }

  
  // Private Methods
  // ---------------

  get _databaseInstance async {
    if (_database == null) {
      // if _database is null we instantiate it
      await _initDB();
    }
    return _database;
  }

  Future<File> get _databaseFile async {
    return File(await databaseFilePath);
  }

  _initDB() async {
    String path = await databaseFilePath;
    print('opening database at $path');
    _database = await openDatabase(path, version: _DB_VERSION, onCreate: _onCreate, onUpgrade: _onUpgrade, onDowngrade: _onDowngrade);
  }

  /// Gets called if the database does not exist.
  FutureOr<void> _onCreate(Database db, int version) async {
    print('Creating database with version $version');
    await db.execute("""
        CREATE TABLE IF NOT EXISTS ${Patient.tableName} (
          ${Patient.colId} INTEGER PRIMARY KEY,
          ${Patient.colCreatedDate} TEXT NOT NULL,
          ${Patient.colEnrollmentDate} TEXT NOT NULL,
          ${Patient.colARTNumber} TEXT NOT NULL,
          ${Patient.colYearOfBirth} TEXT NOT NULL,
          ${Patient.colIsEligible} BIT NOT NULL,
          ${Patient.colStickerNumber} TEXT,
          ${Patient.colIsVLBaselineAvailable} BIT,
          ${Patient.colGender} INTEGER,
          ${Patient.colSexualOrientation} INTEGER,
          ${Patient.colVillage} TEXT,
          ${Patient.colPhoneAvailability} INTEGER,
          ${Patient.colPhoneNumber} TEXT,
          ${Patient.colConsentGiven} BIT,
          ${Patient.colNoConsentReason} INTEGER,
          ${Patient.colNoConsentReasonOther} TEXT,
          ${Patient.colIsActivated} BIT
        );
        """);
    await db.execute("""
        CREATE TABLE IF NOT EXISTS ${PreferenceAssessment.tableName} (
          ${PreferenceAssessment.colId} INTEGER PRIMARY KEY,
          ${PreferenceAssessment.colPatientART} TEXT NOT NULL,
          ${PreferenceAssessment.colCreatedDate} TEXT NOT NULL,
          ${PreferenceAssessment.colARTRefillOption1} INTEGER NOT NULL,
          ${PreferenceAssessment.colARTRefillOption2} INTEGER,
          ${PreferenceAssessment.colARTRefillOption3} INTEGER,
          ${PreferenceAssessment.colARTRefillOption4} INTEGER,
          ${PreferenceAssessment.colARTRefillOption5} INTEGER,
          ${PreferenceAssessment.colARTRefillPENotPossibleReason} INTEGER,
          ${PreferenceAssessment.colARTRefillPENotPossibleReasonOther} TEXT,
          ${PreferenceAssessment.colARTRefillVHWName} TEXT,
          ${PreferenceAssessment.colARTRefillVHWVillage} TEXT,
          ${PreferenceAssessment.colARTRefillVHWPhoneNumber} TEXT,
          ${PreferenceAssessment.colARTRefillTreatmentBuddyART} TEXT,
          ${PreferenceAssessment.colARTRefillTreatmentBuddyVillage} TEXT,
          ${PreferenceAssessment.colARTRefillTreatmentBuddyPhoneNumber} TEXT,
          ${PreferenceAssessment.colARTSupplyAmount} INTEGER NOT NULL,
          ${PreferenceAssessment.colPatientPhoneAvailable} BIT NOT NULL,
          ${PreferenceAssessment.colAdherenceReminderEnabled} BIT,
          ${PreferenceAssessment.colAdherenceReminderFrequency} INTEGER,
          ${PreferenceAssessment.colAdherenceReminderTime} TEXT,
          ${PreferenceAssessment.colAdherenceReminderMessage} INTEGER,
          ${PreferenceAssessment.colARTRefillReminderEnabled} BIT,
          ${PreferenceAssessment.colARTRefillReminderDaysBefore} STRING,
          ${PreferenceAssessment.colARTRefillReminderMessage} INTEGER,
          ${PreferenceAssessment.colVLNotificationEnabled} BIT,
          ${PreferenceAssessment.colVLNotificationMessageSuppressed} INTEGER,
          ${PreferenceAssessment.colVLNotificationMessageUnsuppressed} INTEGER,
          ${PreferenceAssessment.colSupportPreferences} TEXT,
          ${PreferenceAssessment.colSaturdayClinicClubAvailable} BIT,
          ${PreferenceAssessment.colCommunityYouthClubAvailable} BIT,
          ${PreferenceAssessment.colHomeVisitPEPossible} BIT,
          ${PreferenceAssessment.colHomeVisitPENotPossibleReason} INTEGER,
          ${PreferenceAssessment.colHomeVisitPENotPossibleReasonOther} TEXT,
          ${PreferenceAssessment.colSchoolVisitPEPossible} BIT,
          ${PreferenceAssessment.colSchool} TEXT,
          ${PreferenceAssessment.colSchoolVisitPENotPossibleReason} INTEGER,
          ${PreferenceAssessment.colSchoolVisitPENotPossibleReasonOther} TEXT,
          ${PreferenceAssessment.colPitsoPEPossible} BIT,
          ${PreferenceAssessment.colPitsoPENotPossibleReason} INTEGER,
          ${PreferenceAssessment.colPitsoPENotPossibleReasonOther} TEXT,
          ${PreferenceAssessment.colMoreInfoContraceptives} TEXT,
          ${PreferenceAssessment.colMoreInfoVMMC} TEXT,
          ${PreferenceAssessment.colYoungMothersAvailable} BIT,
          ${PreferenceAssessment.colFemaleWorthAvailable} BIT,
          ${PreferenceAssessment.colLegalAidSmartphoneAvailable} BIT,
          ${PreferenceAssessment.colPsychosocialShareSomethingAnswer} INTEGER NOT NULL,
          ${PreferenceAssessment.colPsychosocialShareSomethingContent} TEXT,
          ${PreferenceAssessment.colPsychosocialHowDoing} TEXT,
          ${PreferenceAssessment.colUnsuppressedSafeEnvironmentAnswer} INTEGER,
          ${PreferenceAssessment.colUnsuppressedWhyNotSafe} TEXT
        );
        """);
    await db.execute("""
        CREATE TABLE IF NOT EXISTS ${ARTRefill.tableName} (
          ${ARTRefill.colId} INTEGER PRIMARY KEY,
          ${ARTRefill.colPatientART} TEXT NOT NULL,
          ${ARTRefill.colCreatedDate} TEXT NOT NULL,
          ${ARTRefill.colRefillType} INTEGER NOT NULL,
          ${ARTRefill.colNextRefillDate} TEXT,
          ${ARTRefill.colNotDoneReason} INTEGER,
          ${ARTRefill.colDateOfDeath} TEXT,
          ${ARTRefill.colCauseOfDeath} TEXT,
          ${ARTRefill.colHospitalizedClinic} TEXT,
          ${ARTRefill.colOtherClinic} TEXT,
          ${ARTRefill.colTransferDate} TEXT,
          ${ARTRefill.colNotTakingARTReason} TEXT
        );
        """);
    await db.execute("""
        CREATE TABLE IF NOT EXISTS ${ViralLoad.tableName} (
          ${ViralLoad.colId} INTEGER PRIMARY KEY,
          ${ViralLoad.colPatientART} TEXT NOT NULL,
          ${ViralLoad.colCreatedDate} TEXT NOT NULL,
          ${ViralLoad.colViralLoadSource} INTEGER NOT NULL,
          ${ViralLoad.colViralLoadIsBaseline} BIT NOT NULL,
          ${ViralLoad.colDateOfBloodDraw} TEXT NOT NULL,
          ${ViralLoad.colViralLoad} INTEGER NOT NULL,
          ${ViralLoad.colLabNumber} TEXT,
          ${ViralLoad.colDiscrepancy} BIT
        );
        """);
    await db.execute("""
        CREATE TABLE IF NOT EXISTS ${UserData.tableName} (
          ${UserData.colId} INTEGER PRIMARY KEY,
          ${UserData.colCreatedDate} TEXT NOT NULL,
          ${UserData.colFirstName} TEXT NOT NULL,
          ${UserData.colLastName} TEXT NOT NULL,
          ${UserData.colUsername} TEXT NOT NULL,
          ${UserData.colPhoneNumber} TEXT NOT NULL,
          ${UserData.colHealthCenter} INTEGER NOT NULL,
          ${UserData.colIsActive} BIT NOT NULL,
          ${UserData.colDeactivatedDate} TEXT
        );
        """);
    // RequiredAction table:
    // Each [RequiredAction.type] can only occur once per patient. The unique
    // constraint enforces that and allows us to insert actions redundantly.
    await db.execute("""
        CREATE TABLE IF NOT EXISTS ${RequiredAction.tableName} (
          ${RequiredAction.colId} INTEGER PRIMARY KEY,
          ${RequiredAction.colCreatedDate} TEXT NOT NULL,
          ${RequiredAction.colPatientART} TEXT NOT NULL,
          ${RequiredAction.colType} INTEGER NOT NULL,
          ${RequiredAction.colDueDate} TEXT NOT NULL,
          UNIQUE(${RequiredAction.colPatientART}, ${RequiredAction.colType}) ON CONFLICT IGNORE
        );
        """);
    // TODO: set colLatestPreferenceAssessment as foreign key to `PreferenceAssessment` table
    //       set colPatientART as foreign key to `Patient` table
  }

  /// Gets called if the defined database version is higher than the current
  /// database version on the device.
  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {

    print('Upgrading database from version $oldVersion to version $newVersion');
    if (oldVersion < 2) {
      print('Upgrading to database version 2...');

      // helper method
      _convertDatesFromIntToString(String tablename) async {
        List<Map<String, dynamic>> rows = await db.query(tablename, columns: ['id', 'created_date']);
        Batch batch = db.batch();
        for (Map<String, dynamic> row in rows) {
          int id = row['id'];
          int createdDateInMilliseconds = row['created_date'];
          String createdDateAsUTCString = DateTime.fromMillisecondsSinceEpoch(createdDateInMilliseconds).toUtc().toIso8601String();
          batch.update(
            tablename,
            {'created_date_utc': createdDateAsUTCString},
            where: 'id == ?',
            whereArgs: [id],
          );
          await batch.commit(noResult: true);
        }
      }

      // 1 - add new column 'created_date_utc'
      Batch batch = db.batch();
      batch.execute("ALTER TABLE Patient RENAME TO Patient_tmp;");
      batch.execute("ALTER TABLE Patient_tmp ADD created_date_utc TEXT NOT NULL DEFAULT '';");
      batch.execute("ALTER TABLE PreferenceAssessment RENAME TO PreferenceAssessment_tmp;");
      batch.execute("ALTER TABLE PreferenceAssessment_tmp ADD created_date_utc TEXT NOT NULL DEFAULT '';");
      await batch.commit(noResult: true);

      // 2 - change date representation to UTC String and store it in the new column
      await _convertDatesFromIntToString('Patient_tmp');
      await _convertDatesFromIntToString('PreferenceAssessment_tmp');

      // 3 - copy values from Patient_tmp to Patient
      // and from PreferenceAssessment_tmp to PreferenceAssessment
      batch = db.batch();
      batch.execute("""
        CREATE TABLE Patient (
          id INTEGER PRIMARY KEY,
          art_number TEXT NOT NULL,
          created_date_utc TEXT NOT NULL,
          is_activated BIT NOT NULL,
          is_vl_suppressed BIT,
          village TEXT,
          district TEXT,
          phone_number TEXT,
          latest_preference_assessment INTEGER
        );
      """);
      batch.execute("""
        INSERT INTO Patient
        SELECT id, art_number, created_date_utc, is_activated, is_vl_suppressed,
          village, district, phone_number, latest_preference_assessment
        FROM Patient_tmp;
      """);
      batch.execute("DROP TABLE Patient_tmp;");

      batch.execute("""
        CREATE TABLE PreferenceAssessment (
          id INTEGER PRIMARY KEY,
          patient_art TEXT NOT NULL, 
          created_date_utc TEXT NOT NULL,
          art_refill_option_1 INTEGER NOT NULL,
          art_refill_option_2 INTEGER,
          art_refill_option_3 INTEGER,
          art_refill_option_4 INTEGER,
          art_refill_person_name TEXT,
          art_refill_person_phone_number TEXT,
          phone_available BIT NOT NULL,
          patient_phone_number TEXT,
          adherence_reminder_enabled BIT,
          adherence_reminder_frequency INTEGER,
          adherence_reminder_time TEXT,
          adherence_reminder_message TEXT,
          vl_notification_enabled BIT,
          vl_notification_message_suppressed TEXT,
          vl_notification_message_unsuppressed TEXT,
          pe_phone_number TEXT,
          support_preferences TEXT
        );
      """);
      batch.execute("""
        INSERT INTO PreferenceAssessment
        SELECT id, patient_art, created_date_utc, art_refill_option_1,
          art_refill_option_2, art_refill_option_3, art_refill_option_4,
          art_refill_person_name, art_refill_person_phone_number,
          phone_available, patient_phone_number, adherence_reminder_enabled,
          adherence_reminder_frequency, adherence_reminder_time,
          adherence_reminder_message, vl_notification_enabled,
          vl_notification_message_suppressed,
          vl_notification_message_unsuppressed, pe_phone_number,
          support_preferences
        FROM PreferenceAssessment_tmp;
      """);
      batch.execute("DROP TABLE PreferenceAssessment_tmp;");

      await batch.commit(noResult: true);
    }
    if (oldVersion < 3) {
      print('Upgrading to database version 3...');
      // Add the column 'eac_option'. Since this is a NOT NULL column we have to
      // provide a default value (we chose 0). This means that all preference
      // assessments done under previous database versions (< 3) will have the
      // "Nurse at Clinic" EAC option selected.
      await db.execute("ALTER TABLE PreferenceAssessment ADD eac_option INTEGER NOT NULL DEFAULT 0;");
    }
    if (oldVersion < 6) {
      print('Upgrading to database version 6...');
      print('UPGRADE NOT IMPLEMENTED, DATA WILL BE RESET!');
      await db.execute("DROP TABLE Patient;");
      await db.execute("DROP TABLE PreferenceAssessment;");
      await _onCreate(db, 6);
    }
    if (oldVersion < 7) {
      print('Upgrading to database version 7...');
      await db.execute("""
        CREATE TABLE ARTRefill (
          id INTEGER PRIMARY KEY,
          patient_art TEXT NOT NULL,
          created_date_utc TEXT NOT NULL,
          refill_type INTEGER NOT NULL,
          next_refill_date_utc TEXT,
          not_done_reason INTEGER,
          other_clinic_lesotho TEXT,
          other_clinic_south_africa TEXT,
          not_taking_art_reason TEXT
        );
        """);
    }
    if (oldVersion < 8) {
      print('Upgrading to database version 8...');
      // We want to remove the column 'latest_preference_assessment' in the
      // Patient table. But SQLite does not support removing of columns (we
      // would have to create a new table, copy all data and drop the old
      // table). For simplicity (and because the app is not released at this
      // point) we just drop all data and create the tables anew.
      print('UPGRADE NOT IMPLEMENTED, DATA WILL BE RESET!');
      await db.execute("DROP TABLE Patient;");
      await db.execute("DROP TABLE PreferenceAssessment;");
      await db.execute("DROP TABLE ARTRefill;");
      await _onCreate(db, 8);
    }
    if (oldVersion < 9) {
      print('Upgrading to database version 9...');
      print('UPGRADE NOT IMPLEMENTED, DATA WILL BE RESET!');
      await db.execute("DROP TABLE Patient;");
      await db.execute("DROP TABLE PreferenceAssessment;");
      await db.execute("DROP TABLE ARTRefill;");
      await _onCreate(db, 9);
    }
    if (oldVersion < 10) {
      print('Upgrading to database version 10...');
      print('UPGRADE NOT IMPLEMENTED, VIRAL LOAD DATA WILL BE RESET!');
      await db.execute("DROP TABLE ViralLoad;");
      await _onCreate(db, 10);
    }
    if (oldVersion < 11) {
      print('Upgrading to database version 11...');
      print('UPGRADE NOT IMPLEMENTED, ART REFILL DATA WILL BE RESET!');
      await db.execute("DROP TABLE ARTRefill;");
      await _onCreate(db, 11);
    }
    if (oldVersion < 17) {
      print('Upgrading to database version 17...');
      print('UPGRADE NOT IMPLEMENTED, PREFERENCE ASSESSMENT DATA WILL BE RESET!');
      await db.execute("DROP TABLE PreferenceAssessment;");
      await _onCreate(db, 17);
    }
    if (oldVersion < 18) {
      print('Upgrading to database version 18...');
      // Add new column 'enrollment_date_utc' with default value of 1970-01-01.
      await db.execute("ALTER TABLE Patient ADD enrollment_date_utc TEXT NOT NULL DEFAULT '1970-01-01T00:00:00.000Z';");
    }
    if (oldVersion < 19) {
      print('Upgrading to database version 19...');
      // Add new column 'is_vl_baseline_available' with default value of false (0).
      await db.execute("ALTER TABLE Patient ADD is_vl_baseline_available BIT NOT NULL DEFAULT 0;");
    }
    if (oldVersion < 21) {
      print('Upgrading to database version 21...');
      print('UPGRADE NOT IMPLEMENTED, ART REFILL DATA WILL BE RESET!');
      await db.execute("DROP TABLE ARTRefill;");
      await _onCreate(db, 21);
    }
    if (oldVersion < 28) {
      print('Upgrading to database version 28...');
      print('UPGRADE NOT IMPLEMENTED, PREFERENCE ASSESSMENT DATA WILL BE RESET!');
      await db.execute("DROP TABLE PreferenceAssessment;");
      await _onCreate(db, 28);
    }
    if (oldVersion < 29) {
      print('Upgrading to database version 29...');
      print('UPGRADE NOT IMPLEMENTED, VIRAL LOAD DATA WILL BE RESET!');
      await db.execute("DROP TABLE ViralLoad;");
      await _onCreate(db, 29);
    }
    if (oldVersion < 30) {
      print('Upgrading to database version 30...');
      // create table UserData
      await db.execute("""
        CREATE TABLE UserData (
          id INTEGER PRIMARY KEY,
          created_date_utc TEXT NOT NULL,
          first_name TEXT NOT NULL,
          last_name TEXT NOT NULL,
          username TEXT NOT NULL,
          phone_number TEXT NOT NULL,
          health_center INTEGER NOT NULL,
          is_active BIT NOT NULL,
          deactivated_date_utc TEXT
        );
        """);
    }
    if (oldVersion < 31) {
      print('Upgrading to database version 31...');
      print('UPGRADE NOT IMPLEMENTED, PREFERENCE ASSESSMENT DATA WILL BE RESET!');
      await db.execute("DROP TABLE PreferenceAssessment;");
      await _onCreate(db, 31);
    }
    if (oldVersion < 32) {
      print('Upgrading to database version 32...');
      print('UPGRADE NOT IMPLEMENTED, PATIENT RELATED DATA WILL BE RESET!');
      await db.execute("DROP TABLE IF EXISTS Patient;");
      await db.execute("DROP TABLE IF EXISTS PreferenceAssessment;");
      await db.execute("DROP TABLE IF EXISTS ARTRefill;");
      await db.execute("DROP TABLE IF EXISTS ViralLoad;");
      await _onCreate(db, 32);
    }
    if (oldVersion < 33) {
      print('Upgrading to database version 33...');
      await db.execute("""
        CREATE TABLE IF NOT EXISTS RequiredAction (
          id INTEGER PRIMARY KEY,
          created_date_utc TEXT NOT NULL,
          patient_art TEXT NOT NULL,
          action_type INTEGER NOT NULL,
          UNIQUE(patient_art, action_type) ON CONFLICT IGNORE
        );
        """);
    }
    if (oldVersion < 34) {
      print('Upgrading to database version 34...');
      await db.execute("ALTER TABLE RequiredAction ADD due_date TEXT NOT NULL DEFAULT '1970-01-01T00:00:00.000Z';");
    }
    if (oldVersion < 37) {
      print('Upgrading to database version 37...');
      print('UPGRADE NOT IMPLEMENTED, DATA WILL BE RESET!');
      await db.execute("DROP TABLE IF EXISTS Patient;");
      await db.execute("DROP TABLE IF EXISTS PreferenceAssessment;");
      await db.execute("DROP TABLE IF EXISTS ARTRefill;");
      await db.execute("DROP TABLE IF EXISTS ViralLoad;");
      await db.execute("DROP TABLE IF EXISTS RequiredAction;");
      await _onCreate(db, 37);
    }
    if (oldVersion < 38 && _DB_VERSION >= 38) {
      print('Upgrading to database version 38...');
      print('UPGRADE NOT IMPLEMENTED, USER DATA WILL BE RESET! YOU WILL HAVE TO'
          'CREATE A NEW ACCOUNT OR YOU WILL GET STUCK IN A LOGIN LOOP.');
      await db.execute("DROP TABLE IF EXISTS UserData;"); // Removing the UserData table will result in a login loop -> user has to create a new account
      await _onCreate(db, 38);
      showFlushbar('Please create a new account to continue using the app.', title: 'App Upgraded', error: true);
    }
    if (oldVersion < 39 && _DB_VERSION >= 39) {
      print('Upgrading to database version 39...');
      await db.execute("ALTER TABLE PreferenceAssessment ADD patient_phone_available BIT NOT NULL DEFAULT 1;");
    }
    if (oldVersion < 41 && _DB_VERSION >= 41) {
      print('Upgrading to database version 41...');
      print('UPGRADE NOT IMPLEMENTED, PREFERENCE ASSESSMENT DATA WILL BE RESET!');
      await db.execute("DROP TABLE IF EXISTS PreferenceAssessment;");
      await _onCreate(db, 41);
    }
    if (oldVersion < 43 && _DB_VERSION >= 43) {
      print('Upgrading to database version 43...');
      print('UPGRADE NOT IMPLEMENTED, VIRAL LOAD DATA WILL BE RESET!');
      await db.execute("DROP TABLE IF EXISTS ViralLoad;");
      await _onCreate(db, 43);
    }
  }

  FutureOr<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    print('Downgrading database from version $oldVersion to version $newVersion');
    print('NOT IMPLEMENTED, DATA WILL BE RESET!');
    await db.execute("DROP TABLE IF EXISTS Patient;");
    await db.execute("DROP TABLE IF EXISTS PreferenceAssessment;");
    await db.execute("DROP TABLE IF EXISTS ARTRefill;");
    await db.execute("DROP TABLE IF EXISTS ViralLoad;");
    await db.execute("DROP TABLE IF EXISTS RequiredAction;");
    await db.execute("DROP TABLE IF EXISTS UserData;"); // Removing the UserData table will result in a login loop -> user has to create a new account
    await _onCreate(db, newVersion);
    showFlushbar('Please create a new account to continue using the app.', title: 'App Downgraded', error: true);
  }


  // Public Methods
  // --------------

  /// Get the full file system path of the sql lite database file,
  /// e.g., /data/user/0/org.pebrapp.pebrapp/databases/PEBRApp.db
  Future<String> get databaseFilePath async {
    return join(await databasesDirectoryPath, _dbFilename);
  }

  /// Get the system path of the directory where the sql lite databases
  /// are stored, e.g., /data/user/0/org.pebrapp.pebrapp/databases
  Future<String> get databasesDirectoryPath async {
    return getDatabasesPath();
  }

  /// Erases all data from the database.
  Future<void> resetDatabase() async {
    // close database
    final Database db = await _databaseInstance;
    await db.close();
    // delete database file
    final File dbFile = await _databaseFile;
    await dbFile.delete();
    // initialize new empty database
    await _initDB();
  }

  Future<File> _createFileWithContent(String filename, String content) async {
    final String filepath = join(await databasesDirectoryPath, filename);
    final file = File(filepath);
    return file.writeAsString(content, flush: true);
  }

  /// Backs up the SQLite database file and exports the data as Excel file to SWITCH.
  /// Use this if no previous backup for this user exists yet. This creates
  /// version 1 of the backup documents on SWITCHtoolbox.
  /// 
  /// Throws `NoLoginDataException` if the loginData object is null.
  ///
  /// Throws `SWITCHLoginFailedException` if the login to SWITCHtoolbox fails.
  ///
  /// Throws `SocketException` if there is no internet connection or SWITCH cannot be reached.
  Future<void> createFirstBackupOnSWITCH(UserData loginData, String pinCodeHash) async {
    if (loginData == null) {
      throw NoLoginDataException();
    }
    // store the user data in the database before creating the first backup
    insertUserData(loginData);
    final File dbFile = await _databaseFile;
    final File excelFile = await DatabaseExporter.exportDatabaseToExcelFile();
    final File passwordFile = await _createFileWithContent('PEBRA-password', pinCodeHash);
    // upload SQLite, password file, and Excel file
    final String filename = '${loginData.username}_${loginData.firstName}_${loginData.lastName}';
    await uploadFileToSWITCHtoolbox(dbFile, filename: filename, folderID: SWITCH_TOOLBOX_BACKUP_FOLDER_ID);
    await uploadFileToSWITCHtoolbox(passwordFile, filename: loginData.username, folderID: SWITCH_TOOLBOX_PASSWORD_FOLDER_ID);
    await uploadFileToSWITCHtoolbox(excelFile, filename: filename, folderID: SWITCH_TOOLBOX_DATA_FOLDER_ID);
    await storeLatestBackupInSharedPrefs();
  }

  /// Backs up the SQLite database file and exports the data as Excel file to SWITCH.
  /// Use this only if a previous backup for this user exists. This creates a
  /// new version of the document on SWITCHtoolbox.
  ///
  /// Throws `NoLoginDataException` if the loginData object is null.
  ///
  /// Throws `SWITCHLoginFailedException` if the login to SWITCHtoolbox fails.
  ///
  /// Throws `DocumentNotFoundException` if no matching backup was found.
  ///
  /// Throws `SocketException` if there is no internet connection or SWITCH cannot be reached.
  Future<void> createAdditionalBackupOnSWITCH(UserData loginData) async {
    if (loginData == null) {
      throw NoLoginDataException();
    }
    final File dbFile = await _databaseFile;
    final File excelFile = await DatabaseExporter.exportDatabaseToExcelFile();
    // update SQLite and Excel file with new version
    final String docName = '${loginData.username}_${loginData.firstName}_${loginData.lastName}';
    await updateFileOnSWITCHtoolbox(dbFile, docName, folderId: SWITCH_TOOLBOX_BACKUP_FOLDER_ID);
    await updateFileOnSWITCHtoolbox(excelFile, docName, folderId: SWITCH_TOOLBOX_DATA_FOLDER_ID);
    await storeLatestBackupInSharedPrefs();
  }

  Future<void> restoreFromFile(File backup) async {
    // close database
    final Database db = await _databaseInstance;
    await db.close();
    // move new database file into place
    final String dbFilePath = await databaseFilePath;
    await backup.copy(dbFilePath);
    // load new database
    await _initDB();
    // remove backup file
    await backup.delete();
  }

  Future<void> insertPatient(Patient newPatient) async {
    final Database db = await _databaseInstance;
    newPatient.createdDate = DateTime.now().toUtc();
    final res = await db.insert(Patient.tableName, newPatient.toMap());
    return res;
  }
  
  Future<void> insertViralLoad(ViralLoad viralLoad) async {
    final Database db = await _databaseInstance;
    viralLoad.createdDate = DateTime.now().toUtc();
    final res = await db.insert(ViralLoad.tableName, viralLoad.toMap());
    return res;
  }

  /// Retrieves a list of all patient ART numbers in the database.
  ///
  /// retrieveNonEligibles: whether patients that are marked as 'not eligible'
  /// should also be retrieved (default: true).
  ///
  /// retrieveNonConsents: whether patients that have not given consent should
  /// also be retrieved (default: true).
  Future<List<String>> retrievePatientsART({retrieveNonEligibles: true, retrieveNonConsents: true}) async {
    final Database db = await _databaseInstance;
    List<Map<String, dynamic>> res;
    if (!retrieveNonEligibles && !retrieveNonConsents) {
      // don't retrieve non-eligible and don't retrieve non-consent patients
      res = await db.rawQuery(
          "SELECT DISTINCT ${Patient.colARTNumber} FROM ${Patient.tableName} WHERE ${Patient.colIsEligible}=1 AND ${Patient.colConsentGiven}=1");
    } else if (!retrieveNonConsents) {
      // don't retrieve non-consent patients
      res = await db.rawQuery(
          "SELECT DISTINCT ${Patient.colARTNumber} FROM ${Patient.tableName} WHERE ${Patient.colConsentGiven}=1");
    } else if (!retrieveNonEligibles) {
      // don't retrieve non-eligible patients
      res = await db.rawQuery(
          "SELECT DISTINCT ${Patient.colARTNumber} FROM ${Patient.tableName} WHERE ${Patient.colIsEligible}=1");
    } else {
      // retrieve all
      res = await db.rawQuery(
          "SELECT DISTINCT ${Patient.colARTNumber} FROM ${Patient.tableName}");
    }
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
        await p.initializeViralLoadFields();
        await p.initializePreferenceAssessmentField();
        await p.initializeARTRefillField();
        await p.initializeRequiredActionsField();
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

  Future<void> insertUserData(UserData userData) async {
    final Database db = await _databaseInstance;
    userData.createdDate = DateTime.now().toUtc();
    final res = await db.insert(UserData.tableName, userData.toMap());
    return res;
  }

  Future<void> insertRequiredAction(RequiredAction action) async {
    final Database db = await _databaseInstance;
    action.createdDate = DateTime.now().toUtc();
    final res = await db.insert(RequiredAction.tableName, action.toMap());
    return res;
  }

  Future<void> removeRequiredAction(String patientART, RequiredActionType type) async {
    final Database db = await _databaseInstance;
    final int rowsDeleted = await db.delete(
      RequiredAction.tableName,
      where: "${RequiredAction.colPatientART} = ? AND ${RequiredAction.colType} = ?",
      whereArgs: [patientART, type.index],
    );
  }

  /// Sets the 'is_active' column to false (0) for the latest active user.
  Future<void> deactivateCurrentUser() async {
    final Database db = await _databaseInstance;
    final UserData latestUser = await retrieveLatestUserData();
    if (latestUser != null) {
      final map = {
        UserData.colIsActive: 0,
        UserData.colDeactivatedDate: DateTime.now().toUtc().toIso8601String(),
      };
      db.update(
        UserData.tableName,
        map,
        where: '${UserData.colUsername} = ?',
        whereArgs: [latestUser.username],
      );
    }
  }

  Future<List<ViralLoad>> retrieveViralLoadFollowUpsForPatient(String patientART) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(
        ViralLoad.tableName,
        where: '${ViralLoad.colPatientART} = ? AND ${ViralLoad.colViralLoadIsBaseline} = 0',
        whereArgs: [patientART],
        orderBy: '${ViralLoad.colDateOfBloodDraw}, ${ViralLoad.colCreatedDate}',
    );
    if (res.length > 0) {
      return res.map((Map<dynamic, dynamic> map) => ViralLoad.fromMap(map)).toList();
    }
    return [];
  }

  Future<ViralLoad> retrieveViralLoadBaselineManualForPatient(String patientART) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(
      ViralLoad.tableName,
      where: '${ViralLoad.colPatientART} = ? AND ${ViralLoad.colViralLoadIsBaseline} = 1 AND ${ViralLoad.colViralLoadSource} = ?',
      whereArgs: [patientART, ViralLoadSource.MANUAL_INPUT().code],
    );
    assert (res.length < 2); // there should only be one baseline result per patient
    if (res.length > 0) {
      return res.map((Map<dynamic, dynamic> map) => ViralLoad.fromMap(map)).toList().first;
    }
    return null;
  }

  Future<ViralLoad> retrieveViralLoadBaselineDatabaseForPatient(String patientART) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(
      ViralLoad.tableName,
      where: '${ViralLoad.colPatientART} = ? AND ${ViralLoad.colViralLoadIsBaseline} = 1 AND ${ViralLoad.colViralLoadSource} = ?',
      whereArgs: [patientART, ViralLoadSource.DATABASE().code],
    );
    assert (res.length < 2); // there should only be one baseline result per patient
    if (res.length > 0) {
      return res.map((Map<dynamic, dynamic> map) => ViralLoad.fromMap(map)).toList().first;
    }
    return null;
  }

  Future<PreferenceAssessment> retrieveLatestPreferenceAssessmentForPatient(String patientART) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(
        PreferenceAssessment.tableName,
        where: '${PreferenceAssessment.colPatientART} = ?',
        whereArgs: [patientART],
        orderBy: '${PreferenceAssessment.colCreatedDate} DESC'
    );
    if (res.length > 0) {
      return PreferenceAssessment.fromMap(res.first);
    }
    return null;
  }

  /// Only retrieves latest active user data.
  Future<UserData> retrieveLatestUserData() async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(
        UserData.tableName,
        where: '${UserData.colIsActive} = 1',
        orderBy: '${UserData.colCreatedDate} DESC'
    );
    if (res.length > 0) {
      return UserData.fromMap(res.first);
    }
    return null;
  }

  Future<void> insertARTRefill(ARTRefill newARTRefill) async {
    final Database db = await _databaseInstance;
    newARTRefill.createdDate = DateTime.now().toUtc();
    final res = await db.insert(ARTRefill.tableName, newARTRefill.toMap());
    return res;
  }

  Future<ARTRefill> retrieveLatestARTRefillForPatient(String patientART) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(
        ARTRefill.tableName,
        where: '${ARTRefill.colPatientART} = ?',
        whereArgs: [patientART],
        orderBy: '${ARTRefill.colCreatedDate} DESC'
    );
    if (res.length > 0) {
      return ARTRefill.fromMap(res.first);
    }
    return null;
  }

  Future<ARTRefill> retrieveLatestDoneARTRefillForPatient(String patientART) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(
        ARTRefill.tableName,
        where: '${ARTRefill.colPatientART} = ? AND ${ARTRefill.colRefillType} != ?',
        whereArgs: [patientART, RefillType.NOT_DONE().code],
        orderBy: '${ARTRefill.colCreatedDate} DESC'
    );
    if (res.length > 0) {
      return ARTRefill.fromMap(res.first);
    }
    return null;
  }

  Future<Set<RequiredAction>> retrieveRequiredActionsForPatient(String patientART) async {
    final Database db = await _databaseInstance;
    final List<Map> res = await db.query(
        RequiredAction.tableName,
        where: '${RequiredAction.colPatientART} = ?',
        whereArgs: [patientART],
    );
    final Set<RequiredAction> set = {};
    for (Map map in res) {
      set.add(RequiredAction.fromMap(map));
    }
    return set;
  }

  /// Retrieves all patient rows from the database, including all edits.
  Future<List<Patient>> retrieveAllPatients() async {
    final Database db = await _databaseInstance;
    // query the table for all patients
    final res = await db.query(Patient.tableName);
    List<Patient> list = List<Patient>();
    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        Patient p = Patient.fromMap(map);
        list.add(p);
      }
    }
    return list;
  }

  /// Retrieves all viral load rows from the database, including all edits.
  Future<List<ViralLoad>> retrieveAllViralLoads() async {
    final Database db = await _databaseInstance;
    final res = await db.query(ViralLoad.tableName);
    List<ViralLoad> list = List<ViralLoad>();
    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        ViralLoad v = ViralLoad.fromMap(map);
        list.add(v);
      }
    }
    return list;
  }

  /// Retrieves all preference assessment rows from the database, including all
  /// edits.
  Future<List<PreferenceAssessment>> retrieveAllPreferenceAssessments() async {
    final Database db = await _databaseInstance;
    final res = await db.query(PreferenceAssessment.tableName);
    List<PreferenceAssessment> list = List<PreferenceAssessment>();
    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        PreferenceAssessment pa = PreferenceAssessment.fromMap(map);
        list.add(pa);
      }
    }
    return list;
  }

  /// Retrieves all ART refill rows from the database, including all edits.
  Future<List<ARTRefill>> retrieveAllARTRefills() async {
    final Database db = await _databaseInstance;
    final res = await db.query(ARTRefill.tableName);
    List<ARTRefill> list = List<ARTRefill>();
    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        ARTRefill r = ARTRefill.fromMap(map);
        list.add(r);
      }
    }
    return list;
  }

  /// Retrieves all user data rows from the database, including all edits.
  Future<List<UserData>> retrieveAllUserData() async {
    final Database db = await _databaseInstance;
    final res = await db.query(UserData.tableName);
    List<UserData> list = List<UserData>();
    if (res.isNotEmpty) {
      for (Map<String, dynamic> map in res) {
        UserData u = UserData.fromMap(map);
        list.add(u);
      }
    }
    return list;
  }

  // Debug methods (should be removed/disabled for final release)
  // ------------------------------------------------------------
  // TODO: remove/disable these functions for the final release

  /// Retrieves a table's column names.
  Future<List<Map<String, dynamic>>> getTableInfo(String tableName) async {
    final Database db = await _databaseInstance;
    var res = db.rawQuery("PRAGMA table_info($tableName);");
    return res;
  }

  /// Deletes a patient from the Patient table and its corresponding entries from all other tables.
  Future<int> deletePatient(Patient deletePatient) async {
    final Database db = await _databaseInstance;
    final String artNumber = deletePatient.artNumber;
    final int rowsDeletedPatientTable = await db.delete(Patient.tableName, where: '${Patient.colARTNumber} = ?', whereArgs: [artNumber]);
    final int rowsDeletedViralLoadTable = await db.delete(ViralLoad.tableName, where: '${ViralLoad.colPatientART} = ?', whereArgs: [artNumber]);
    final int rowsDeletedPreferenceAssessmentTable = await db.delete(PreferenceAssessment.tableName, where: '${PreferenceAssessment.colPatientART} = ?', whereArgs: [artNumber]);
    final int rowsDeletedARTRefillTable = await db.delete(ARTRefill.tableName, where: '${ARTRefill.colPatientART} = ?', whereArgs: [artNumber]);
    final int rowsDeletedRequiredActionTable = await db.delete(RequiredAction.tableName, where: '${RequiredAction.colPatientART} = ?', whereArgs: [artNumber]);
    return rowsDeletedPatientTable + rowsDeletedViralLoadTable + rowsDeletedPreferenceAssessmentTable + rowsDeletedARTRefillTable + rowsDeletedRequiredActionTable;
  }

}
