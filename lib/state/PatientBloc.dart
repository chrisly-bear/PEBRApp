import 'dart:async';

import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/ARTRefill.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';

class PatientBloc {
  static PatientBloc _instance;

  static PatientBloc get instance {
    if (_instance == null) {
      _instance = PatientBloc._();
    }
    return _instance;
  }

  // private constructor
  PatientBloc._();

  // broadcast allows multiple listeners (instead of just one)
  final _appStateStreamController = StreamController<AppState>.broadcast();

  // Stream (Outputs)
  // ----------------

  Stream<AppState> get appState => _appStateStreamController.stream;

  // Event Triggers (Inputs)
  // -----------------------

  /// Trigger an [AppStateLoading] stream event, followed by either a
  /// [AppStateNoData] event or several [AppStatePatientData] events.
  Future<void> sinkAllPatientsFromDatabase() async {
    _appStateStreamController.sink.add(AppStateLoading());
    final List<Patient> patientList = await DatabaseProvider().retrieveLatestPatients();
    if (patientList.isEmpty) {
      print('No patients in database. Putting AppStateNoData down the sink');
      _appStateStreamController.sink.add(AppStateNoData());
    }
    for (Patient p in patientList) {
      print('Putting patient ${p.artNumber} in the sink');
      _appStateStreamController.sink.add(AppStatePatientData(p));
    }
  }

  /// Store a new row in the Patient table and trigger an [AppStatePatientData] stream event.
  Future<void> sinkPatientData(Patient patient) async {
    await DatabaseProvider().insertPatient(patient);
    print('Putting patient ${patient.artNumber} down the sink');
    _appStateStreamController.sink.add(AppStatePatientData(patient));
  }

  /// Store a new row in the PreferenceAssessment table and trigger an [AppStatePreferenceAssessmentData] stream event.
  Future<void> sinkPreferenceAssessmentData(PreferenceAssessment newPreferenceAssessment) async {
    await DatabaseProvider().insertPreferenceAssessment(newPreferenceAssessment);
    print('Putting preference assessment for patient ${newPreferenceAssessment.patientART} down the sink');
    _appStateStreamController.sink.add(AppStatePreferenceAssessmentData(newPreferenceAssessment));
  }

  /// Store a new row in the ARTRefill table and trigger an [AppStateARTRefillData] stream event.
  Future<void> sinkARTRefillData(ARTRefill newARTRefill) async {
    await DatabaseProvider().insertARTRefill(newARTRefill);
    print('Putting ART Refill for patient ${newARTRefill.patientART} down the sink');
    _appStateStreamController.sink.add(AppStateARTRefillData(newARTRefill));
  }

  void dispose() {
    _appStateStreamController.close();
  }
}

class AppState {}

class AppStateLoading extends AppState {}

class AppStateNoData extends AppState {}

class AppStatePatientData extends AppState {
  final Patient patient;
  AppStatePatientData(this.patient);
}

class AppStatePreferenceAssessmentData extends AppState {
  final PreferenceAssessment preferenceAssessment;
  AppStatePreferenceAssessmentData(this.preferenceAssessment);
}

class AppStateARTRefillData extends AppState {
  final ARTRefill artRefill;
  AppStateARTRefillData(this.artRefill);
}
