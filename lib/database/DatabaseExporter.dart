import 'dart:async';
import 'package:flutter/services.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

/// Exports the database as a CSV file an uploads it to SWITCH.
class DatabaseExporter {

  static const CSV_FILENAME = 'PEBRA_Data.csv';
  static const EXCEL_FILENAME = 'PEBRA_Data.xlsx';
  static const _EXCEL_TEMPLATE_PATH = 'assets/excel/PEBRA_Data_template.xlsx';

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

  /// Writes database data to Excel (xlsx) file and returns that file.
  static Future<File> exportDatabaseToExcelFile() async {

    // these are the name of the sheets in the template excel file
    const String patientSheet = 'Patient';
    const String viralLoadSheet = 'Viral Load';
    const String preferenceAssessmentSheet = 'Preference Assessment';
    const String artRefillSheet = 'ART Refill';

    final DatabaseProvider dbp = DatabaseProvider();
    final String filepath = join(await dbp.databasesDirectoryPath, EXCEL_FILENAME);
    ByteData data = await rootBundle.load(_EXCEL_TEMPLATE_PATH);
    final File excelFile = await File(filepath).writeAsBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    final List<int> bytes = excelFile.readAsBytesSync();
    final decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);

    final List<Patient> patientRows = await dbp.retrieveAllPatients();

    final int rowsRequired = patientRows.length;
    final int colsRequired = 14; // depends on how many attributes/columns the table has
    for (var i = 1; i <= rowsRequired; i++) {
      decoder.insertRow(patientSheet, i);
    }
    for (var i = 1; i <= colsRequired; i++) {
      decoder.insertColumn(patientSheet, i);
    }

    // TODO: use column names from codebook
    decoder.updateCell(patientSheet, 0, 0, 'createdDate');
    decoder.updateCell(patientSheet, 1, 0, 'artNumber');
    decoder.updateCell(patientSheet, 2, 0, 'stickerNumber');
    decoder.updateCell(patientSheet, 3, 0, 'yearOfBirth');
    decoder.updateCell(patientSheet, 4, 0, 'isEligible');
    // nullables:
    decoder.updateCell(patientSheet, 5, 0, 'gender');
    decoder.updateCell(patientSheet, 6, 0, 'sexualOrientation');
    decoder.updateCell(patientSheet, 7, 0, 'village');
    decoder.updateCell(patientSheet, 8, 0, 'phoneAvailability');
    decoder.updateCell(patientSheet, 9, 0, 'phoneNumber');
    decoder.updateCell(patientSheet, 10, 0, 'consentGiven');
    decoder.updateCell(patientSheet, 11, 0, 'noConsentReason');
    decoder.updateCell(patientSheet, 12, 0, 'noConsentReasonOther');
    decoder.updateCell(patientSheet, 13, 0, 'isActivated');

    for (var i = 0; i < patientRows.length; i++) {
      Patient p = patientRows.elementAt(i);
      // TODO: write all variables
      decoder.updateCell(patientSheet, 0, i+1, p.createdDate);
      decoder.updateCell(patientSheet, 1, i+1, p.artNumber);
      decoder.updateCell(patientSheet, 2, i+1, p.stickerNumber);
      decoder.updateCell(patientSheet, 3, i+1, p.yearOfBirth);
      decoder.updateCell(patientSheet, 4, i+1, p.isEligible);
      // nullables:
      decoder.updateCell(patientSheet, 5, i+1, p.gender?.code);
      decoder.updateCell(patientSheet, 6, i+1, p.sexualOrientation?.code);
      decoder.updateCell(patientSheet, 7, i+1, p.village);
      decoder.updateCell(patientSheet, 8, i+1, p.phoneAvailability?.code);
      decoder.updateCell(patientSheet, 9, i+1, p.phoneNumber);
      decoder.updateCell(patientSheet, 10, i+1, p.consentGiven);
      decoder.updateCell(patientSheet, 11, i+1, p.noConsentReason);
      decoder.updateCell(patientSheet, 12, i+1, p.noConsentReasonOther);
      decoder.updateCell(patientSheet, 13, i+1, p.isActivated);
    }

    // TODO: write Sheets for other tables (PreferenceAssessment, ARTRefill, Settings...)

    // store changes to file
    excelFile.writeAsBytesSync(decoder.encode());
    return excelFile;
  }

}
