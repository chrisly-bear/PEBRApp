import 'dart:async';
import 'package:pebrapp/config/SwitchConfig.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:path/path.dart';
import 'package:pebrapp/screens/SettingsScreen.dart';
import 'dart:io';
import 'package:pebrapp/utils/SwitchToolboxUtils.dart';
import 'package:pebrapp/utils/Utils.dart';

/// Exports the database as a CSV file an uploads it to SWITCH.
class DatabaseExporter {

  static const CSV_FILENAME = 'PEBRA_Data.csv';

  /// Writes database data to CSV file separated by ';' and returns that file.
  static Future<File> exportDatabaseToCSVFile() async {
    final DatabaseProvider dbp = DatabaseProvider();
    final String filepath = join(await dbp.databasesDirectoryPath, CSV_FILENAME);
    final File csvFile = File(filepath);

    final List<Patient> patientRows = await dbp.retrieveAllPatients();

    // TODO: use column names from codebook
    String csvString = 'sep=;\nART; CREATED; ACTIVATED; SUPPRESSED; VILLAGE; DISTRICT; PHONE\n';
    for (Patient p in patientRows) {
      csvString += '${p.artNumber}; ${p.createdDate}; ${p.isActivated}; ${p.vlSuppressed}; ${p.village}; ${p.district}; ${p.phoneNumber};\n';
    }

    // TODO: write CSV for other tables (PreferenceAssessment, ARTRefill, Settings...)

    await csvFile.writeAsString(csvString, flush: true);
    return csvFile;
  }

  /// Creates a CSV file of the database data and uploads the file to SWITCHtoolbox.
  static Future<void> exportDatabaseToCSVFileAndUploadToSwitch() async {
    final File csvFile = await exportDatabaseToCSVFile();
    final DateTime now = DateTime.now();
    final LoginData loginData = await loginDataFromSharedPrefs;
    final String filename = '${loginData.firstName}_${loginData.lastName}_${loginData.healthCenter}_${now.toIso8601String()}';
    await uploadFileToSWITCHtoolbox(csvFile, filename: filename, folderID: SWITCH_TOOLBOX_DATA_FOLDER_ID);
  }

}
