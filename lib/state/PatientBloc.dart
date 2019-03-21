import 'dart:async';

import 'package:pebrapp/database/DatabaseProvider.dart';
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

  /// Trigger an [AppStateLoading] stream event, followed by a [AppStatePatientListData] event.
  Future<void> sinkAllPatientsFromDatabase() async {
    _appStateStreamController.sink.add(AppStateLoading());
    final List<Patient> patientList = await DatabaseProvider().retrieveLatestPatients();
    for (Patient p in patientList) {
      print('Putting patient ${p.artNumber} in the sink');
      _appStateStreamController.sink.add(AppStatePatientData(p));
    }
  }

  /// Trigger an [AppStatePatientData] stream event.
  Future<void> sinkPatientData(Patient newPatient) async {
    await DatabaseProvider().insertPatient(newPatient);
    print('Putting patient ${newPatient.artNumber} down the sink');
    _appStateStreamController.sink.add(AppStatePatientData(newPatient));
  }

  /// Trigger an [AppStatePreferenceAssessmentData] stream event.
  Future<void> sinkPreferenceAssessmentData(PreferenceAssessment newPreferenceAssessment) async {
    await DatabaseProvider().insertPreferenceAssessment(newPreferenceAssessment);
    print('Putting preference assessment for patient ${newPreferenceAssessment.patientART} down the sink');
    _appStateStreamController.sink.add(AppStatePreferenceAssessmentData(newPreferenceAssessment));
  }

  void dispose() {
    _appStateStreamController.close();
  }
}

class AppState {}

class AppStateLoading extends AppState {}

class AppStatePatientData extends AppState {
  AppStatePatientData(this.patient);
  final Patient patient;
}

class AppStatePreferenceAssessmentData extends AppState {
  AppStatePreferenceAssessmentData(this.preferenceAssessment);
  final PreferenceAssessment preferenceAssessment;
}
