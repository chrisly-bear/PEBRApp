import 'dart:async';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:path/path.dart';
import 'dart:io';

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
      // TODO: write all variables
      csvString += '${p.artNumber}; ${p.createdDate};\n';
    }

    // TODO: write CSV for other tables (PreferenceAssessment, ARTRefill, Settings...)

    await csvFile.writeAsString(csvString, flush: true);
    return csvFile;
  }

}
