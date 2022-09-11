import 'dart:async';
import 'package:flutter/services.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/ARTRefill.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:path/path.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/database/models/SupportOptionDone.dart';
import 'package:pebrapp/database/models/UserData.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'dart:io';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

/// Exports the database as a CSV file an uploads it to PEBRAcloud.
class DatabaseExporter {
  static const EXCEL_FILENAME = 'PEBRA_Data.xlsx';
  static const _EXCEL_TEMPLATE_PATH = 'assets/excel/PEBRA_Data_template.xlsx';

  /// Writes database data to Excel (xlsx) file and returns that file.
  static Future<File> exportDatabaseToExcelFile() async {
    // these are the name of the sheets in the template excel file
    const String userDataSheet = 'User Data';
    const String patientSheet = 'Participant';
    const String viralLoadSheet = 'Viral Load';
    const String preferenceAssessmentSheet = 'Preference Assessment';
    const String supportOptionDoneSheet = 'Support Option Done';
    const String artRefillSheet = 'ART Refill';

    // open database
    final DatabaseProvider dbp = DatabaseProvider();
    // open excel template file
    final String filepath =
        join(await dbp.databasesDirectoryPath, EXCEL_FILENAME);
    ByteData data = await rootBundle.load(_EXCEL_TEMPLATE_PATH);
    final File excelFile = await File(filepath).writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    final List<int> bytes = excelFile.readAsBytesSync();
    final decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);

    void _writeRowsToExcel(
        String sheetName, List<String> headerRow, List<IExcelExportable> rows) {
      // make enough rows
      for (var i = 0; i < rows.length; i++) {
        decoder.insertRow(sheetName, i + 1);
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
          decoder.updateCell(sheetName, j, i + 1, row[j]);
        }
      }
    }

    final List<UserData> userDataRows = await dbp.retrieveAllUserData();
    _writeRowsToExcel(userDataSheet, UserData.excelHeaderRow, userDataRows);

    final List<Patient> patientRows = await dbp.retrieveAllPatients();
    _writeRowsToExcel(patientSheet, Patient.excelHeaderRow, patientRows);

    final List<ViralLoad> viralLoadRows = await dbp.retrieveAllViralLoads();
    _writeRowsToExcel(viralLoadSheet, ViralLoad.excelHeaderRow, viralLoadRows);

    final List<PreferenceAssessment> preferenceAssessmentRows =
        await dbp.retrieveAllPreferenceAssessments();
    _writeRowsToExcel(preferenceAssessmentSheet,
        PreferenceAssessment.excelHeaderRow, preferenceAssessmentRows);

    final List<SupportOptionDone> supportOptionDoneRows =
        await dbp.retrieveAllSupportOptionDones();
    _writeRowsToExcel(supportOptionDoneSheet, SupportOptionDone.excelHeaderRow,
        supportOptionDoneRows);

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
