import 'package:flutter_test/flutter_test.dart';
import 'package:pebrapp/database/beans/ViralLoadSource.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/utils/Utils.dart';

void main() {
  group('missing baselines', () {
    test('database baseline missing, manual baseline exists', () async {
      final List<ViralLoad> viralLoads = [
        ViralLoad(
          // manual baseline
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // manual additional 1
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 6, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // manual additional 2
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'ADDITIONAL2',
          dateOfBloodDraw: DateTime(1999, 5, 1),
          viralLoad: 0,
          failed: false,
        ),
      ];
      final Patient patient = Patient(enrollmentDate: DateTime(2000, 1, 1));
      patient.viralLoads = viralLoads;
      final bool discrepancy =
          await checkForViralLoadDiscrepancies(patient, testingEnabled: true);
      expect(discrepancy, true);
    });

    test('database baseline exists, manual baseline missing', () async {
      final List<ViralLoad> viralLoads = [
        ViralLoad(
          // database baseline
          source: ViralLoadSource.DATABASE(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // database additional 1
          source: ViralLoadSource.DATABASE(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 6, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // database additional 2
          source: ViralLoadSource.DATABASE(),
          labNumber: 'ADDITIONAL2',
          dateOfBloodDraw: DateTime(1999, 5, 1),
          viralLoad: 0,
          failed: false,
        ),
      ];
      final Patient patient = Patient(enrollmentDate: DateTime(2000, 1, 1));
      patient.viralLoads = viralLoads;
      final bool discrepancy =
          await checkForViralLoadDiscrepancies(patient, testingEnabled: true);
      expect(discrepancy, true);
    });

    test('database and manual baseline missing', () async {
      final List<ViralLoad> viralLoads = [];
      final Patient patient = Patient(enrollmentDate: DateTime(2000, 1, 1));
      patient.viralLoads = viralLoads;
      final bool discrepancy =
          await checkForViralLoadDiscrepancies(patient, testingEnabled: true);
      expect(discrepancy, false);
    });
  });

  group('failed baselines', () {
    test('database baseline failed, manual baseline exists', () async {
      final List<ViralLoad> viralLoads = [
        ViralLoad(
          // database would-be baseline
          source: ViralLoadSource.DATABASE(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: true,
        ),
        ViralLoad(
          // manual baseline
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // manual additional 1
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 6, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // manual additional 2
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'ADDITIONAL2',
          dateOfBloodDraw: DateTime(1999, 5, 1),
          viralLoad: 0,
          failed: false,
        ),
      ];
      final Patient patient = Patient(enrollmentDate: DateTime(2000, 1, 1));
      patient.viralLoads = viralLoads;
      final bool discrepancy =
          await checkForViralLoadDiscrepancies(patient, testingEnabled: true);
      expect(discrepancy, true);
    });

    test('database baseline exists, manual baseline failed', () async {
      final List<ViralLoad> viralLoads = [
        ViralLoad(
          // manual would-be baseline
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: true,
        ),
        ViralLoad(
          // database baseline
          source: ViralLoadSource.DATABASE(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // database additional 1
          source: ViralLoadSource.DATABASE(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 6, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // database additional 2
          source: ViralLoadSource.DATABASE(),
          labNumber: 'ADDITIONAL2',
          dateOfBloodDraw: DateTime(1999, 5, 1),
          viralLoad: 0,
          failed: false,
        ),
      ];
      final Patient patient = Patient(enrollmentDate: DateTime(2000, 1, 1));
      patient.viralLoads = viralLoads;
      final bool discrepancy =
          await checkForViralLoadDiscrepancies(patient, testingEnabled: true);
      expect(discrepancy, true);
    });

    test('database and manual baseline failed', () async {
      final List<ViralLoad> viralLoads = [
        ViralLoad(
          // manual would-be baseline
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: true,
        ),
        ViralLoad(
          // database would-be baseline
          source: ViralLoadSource.DATABASE(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: true,
        ),
      ];
      final Patient patient = Patient(enrollmentDate: DateTime(2000, 1, 1));
      patient.viralLoads = viralLoads;
      final bool discrepancy =
          await checkForViralLoadDiscrepancies(patient, testingEnabled: true);
      expect(discrepancy, false);
    });

    test('database and manual baselines failed, but others exist', () async {
      final List<ViralLoad> viralLoads = [
        ViralLoad(
          // database would-be baseline
          source: ViralLoadSource.DATABASE(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: true,
        ),
        ViralLoad(
          // database additional 1 -> actual baseline
          source: ViralLoadSource.DATABASE(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 6, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // database additional 2
          source: ViralLoadSource.DATABASE(),
          labNumber: 'ADDITIONAL2',
          dateOfBloodDraw: DateTime(1999, 5, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // manual would-be baseline
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: true,
        ),
        ViralLoad(
          // manual additional 1 -> actual baseline
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 6, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // manual additional 2
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'ADDITIONAL2',
          dateOfBloodDraw: DateTime(1999, 5, 1),
          viralLoad: 0,
          failed: false,
        ),
      ];
      final Patient patient = Patient(enrollmentDate: DateTime(2000, 1, 1));
      patient.viralLoads = viralLoads;
      final bool discrepancy =
          await checkForViralLoadDiscrepancies(patient, testingEnabled: true);
      expect(discrepancy, false);
    });
  });

  group('baselines after enrollment date', () {
    test('database baseline after enrollment date, manual baseline exists',
        () async {
      final List<ViralLoad> viralLoads = [
        ViralLoad(
          // database would-be baseline
          source: ViralLoadSource.DATABASE(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(2000, 1, 2),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // manual baseline
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // manual additional 1
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 6, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // manual additional 2
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'ADDITIONAL2',
          dateOfBloodDraw: DateTime(1999, 5, 1),
          viralLoad: 0,
          failed: false,
        ),
      ];
      final Patient patient = Patient(enrollmentDate: DateTime(2000, 1, 1));
      patient.viralLoads = viralLoads;
      final bool discrepancy =
          await checkForViralLoadDiscrepancies(patient, testingEnabled: true);
      expect(discrepancy, true);
    });

    test('database baseline exists, manual baseline after enrollment date',
        () async {
      final List<ViralLoad> viralLoads = [
        ViralLoad(
          // manual would-be baseline
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(2000, 1, 2),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // database baseline
          source: ViralLoadSource.DATABASE(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // database additional 1
          source: ViralLoadSource.DATABASE(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 6, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // database additional 2
          source: ViralLoadSource.DATABASE(),
          labNumber: 'ADDITIONAL2',
          dateOfBloodDraw: DateTime(1999, 5, 1),
          viralLoad: 0,
          failed: false,
        ),
      ];
      final Patient patient = Patient(enrollmentDate: DateTime(2000, 1, 1));
      patient.viralLoads = viralLoads;
      final bool discrepancy =
          await checkForViralLoadDiscrepancies(patient, testingEnabled: true);
      expect(discrepancy, true);
    });

    test('database and manual baseline after enrollment date', () async {
      final List<ViralLoad> viralLoads = [
        ViralLoad(
          // manual would-be baseline
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(2000, 1, 2),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // database would-be baseline
          source: ViralLoadSource.DATABASE(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(2000, 1, 2),
          viralLoad: 0,
          failed: false,
        ),
      ];
      final Patient patient = Patient(enrollmentDate: DateTime(2000, 1, 1));
      patient.viralLoads = viralLoads;
      final bool discrepancy =
          await checkForViralLoadDiscrepancies(patient, testingEnabled: true);
      expect(discrepancy, false);
    });

    test('database and manual baseline after enrollment date, but others exist',
        () async {
      final List<ViralLoad> viralLoads = [
        ViralLoad(
          // manual would-be baseline
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(2000, 1, 2),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // database would-be baseline
          source: ViralLoadSource.DATABASE(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(2000, 1, 2),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // manual additional 1 -> actual baseline
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // database additional 1 -> actual baseline
          source: ViralLoadSource.DATABASE(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: false,
        ),
      ];
      final Patient patient = Patient(enrollmentDate: DateTime(2000, 1, 1));
      patient.viralLoads = viralLoads;
      final bool discrepancy =
          await checkForViralLoadDiscrepancies(patient, testingEnabled: true);
      expect(discrepancy, false);
    });
  });

  group('match but different values', () {
    test('different viral load', () async {
      final List<ViralLoad> viralLoads = [
        ViralLoad(
          // manual baseline
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 100,
          failed: false,
        ),
        ViralLoad(
          // manual additional 1
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 6, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // database baseline
          source: ViralLoadSource.DATABASE(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 200,
          failed: false,
        ),
        ViralLoad(
          // database additional 1
          source: ViralLoadSource.DATABASE(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 6, 1),
          viralLoad: 0,
          failed: false,
        ),
      ];
      final Patient patient = Patient(enrollmentDate: DateTime(2000, 1, 1));
      patient.viralLoads = viralLoads;
      final bool discrepancy =
          await checkForViralLoadDiscrepancies(patient, testingEnabled: true);
      expect(discrepancy, true);
    });

    test('different lab number', () async {
      final List<ViralLoad> viralLoads = [
        ViralLoad(
          // manual baseline
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'BASELINE-X',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // manual additional 1
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 6, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // database baseline
          source: ViralLoadSource.DATABASE(),
          labNumber: 'BASELINE-Y',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // database additional 1
          source: ViralLoadSource.DATABASE(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 6, 1),
          viralLoad: 0,
          failed: false,
        ),
      ];
      final Patient patient = Patient(enrollmentDate: DateTime(2000, 1, 1));
      patient.viralLoads = viralLoads;
      final bool discrepancy =
          await checkForViralLoadDiscrepancies(patient, testingEnabled: true);
      expect(discrepancy, true);
    });

    test('different date of blood draw (manual before database)', () async {
      final List<ViralLoad> viralLoads = [
        ViralLoad(
          // manual baseline
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // manual additional 1
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 6, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // database baseline
          source: ViralLoadSource.DATABASE(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 2),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // database additional 1
          source: ViralLoadSource.DATABASE(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 6, 1),
          viralLoad: 0,
          failed: false,
        ),
      ];
      final Patient patient = Patient(enrollmentDate: DateTime(2000, 1, 1));
      patient.viralLoads = viralLoads;
      final bool discrepancy =
          await checkForViralLoadDiscrepancies(patient, testingEnabled: true);
      expect(discrepancy, true);
    });

    test('different date of blood draw (database before manual)', () async {
      final List<ViralLoad> viralLoads = [
        ViralLoad(
          // database baseline
          source: ViralLoadSource.DATABASE(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // database additional 1
          source: ViralLoadSource.DATABASE(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 6, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // manual baseline
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 2),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // manual additional 1
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 6, 1),
          viralLoad: 0,
          failed: false,
        ),
      ];
      final Patient patient = Patient(enrollmentDate: DateTime(2000, 1, 1));
      patient.viralLoads = viralLoads;
      final bool discrepancy =
          await checkForViralLoadDiscrepancies(patient, testingEnabled: true);
      expect(discrepancy, true);
    });
  });

  group(('no discrepancies'), () {
    test('complete match', () async {
      final List<ViralLoad> viralLoads = [
        ViralLoad(
          // manual baseline
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // manual additional 1
          source: ViralLoadSource.MANUAL_INPUT(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 6, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // database baseline
          source: ViralLoadSource.DATABASE(),
          labNumber: 'BASELINE',
          dateOfBloodDraw: DateTime(1999, 7, 1),
          viralLoad: 0,
          failed: false,
        ),
        ViralLoad(
          // database additional 1
          source: ViralLoadSource.DATABASE(),
          labNumber: 'ADDITIONAL1',
          dateOfBloodDraw: DateTime(1999, 6, 1),
          viralLoad: 0,
          failed: false,
        ),
      ];
      final Patient patient = Patient(enrollmentDate: DateTime(2000, 1, 1));
      patient.viralLoads = viralLoads;
      final bool discrepancy =
          await checkForViralLoadDiscrepancies(patient, testingEnabled: true);
      expect(discrepancy, false);
    });
  });
}
