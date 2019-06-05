import 'dart:async';
import 'package:flutter/services.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/ARTRefill.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:path/path.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/database/models/UserData.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
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
    const String userDataSheet = 'User Data';
    const String patientSheet = 'Patient';
    const String viralLoadSheet = 'Viral Load';
    const String preferenceAssessmentSheet = 'Preference Assessment';
    const String artRefillSheet = 'ART Refill';

    // open database
    final DatabaseProvider dbp = DatabaseProvider();
    // open excel template file
    final String filepath = join(await dbp.databasesDirectoryPath, EXCEL_FILENAME);
    ByteData data = await rootBundle.load(_EXCEL_TEMPLATE_PATH);
    final File excelFile = await File(filepath).writeAsBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    final List<int> bytes = excelFile.readAsBytesSync();
    final decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);

    void _writeRowsToExcel(String sheetName, List<String> headerRow, List<IExcelExportable> rows) {
      // make enough rows
      for (var i = 0; i < rows.length; i++) {
        decoder.insertRow(sheetName, i+1);
      }

      // make enough columns
      for (var i = 1; i < headerRow.length; i++) {
        decoder.insertColumn(sheetName, i);
      }

      // write header row
      for (var i = 0; i < headerRow.length; i++) {
        decoder.updateCell(sheetName, i, 0, headerRow[i]);
      }

      // write rows
      for (var i = 0; i < rows.length; i++) {
        List<dynamic> row = rows[i].toExcelRow();
        // write all columns of current row
        for (var j = 0; j < headerRow.length; j++) {
          decoder.updateCell(sheetName, j, i+1, row[j]);
        }
      }
    }

    // TODO: uncomment after you have updated the excel template
//    final List<UserData> userDataRows = await dbp.retrieveAllUserData();
//    _writeRowsToExcel(userDataSheet, UserData.excelHeaderRow, userDataRows);

    final List<Patient> patientRows = await dbp.retrieveAllPatients();
    _writeRowsToExcel(patientSheet, Patient.excelHeaderRow, patientRows);

    final List<ViralLoad> viralLoadRows = await dbp.retrieveAllViralLoads();
    _writeRowsToExcel(viralLoadSheet, ViralLoad.excelHeaderRow, viralLoadRows);

    final List<PreferenceAssessment> preferenceAssessmentRows = await dbp.retrieveAllPreferenceAssessments();
    _writeRowsToExcel(preferenceAssessmentSheet, PreferenceAssessment.excelHeaderRow, preferenceAssessmentRows);

    final List<ARTRefill> artRefillRows = await dbp.retrieveAllARTRefills();
    _writeRowsToExcel(artRefillSheet, ARTRefill.excelHeaderRow, artRefillRows);

    // store changes to file
    excelFile.writeAsBytesSync(decoder.encode());
    return excelFile;
  }

}

/// Interface which makes a class exportable to an excel file.
abstract class IExcelExportable {
  List<dynamic> toExcelRow();
}
