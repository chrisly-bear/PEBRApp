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
  void loadPatientData() async {
    _appStateStreamController.sink.add(AppStateLoading());
    final List<Patient> patientList = await DatabaseProvider().retrieveLatestPatients();

    // (1) send entire list
//    _appStateStreamController.sink.add(AppStatePatientListData(patientList));

    // (2) send patient by patient
    // Feeding the patients to the stream one by one leads to race conditions
    // (not all the patients are received by the StreamBuilder listener)
    for (Patient p in patientList) {
//      await Future.delayed(Duration(milliseconds: 1000)); // TODO: remove this debug pause
      print('Putting patient ${p.artNumber} in the sink');
      _appStateStreamController.sink.add(AppStatePatientData(p));
    }
  }

  /// Trigger an [AppStatePatientData] stream event.
  void insertPatientData(Patient newPatient) async {
    await DatabaseProvider().insertPatient(newPatient);
    print('Putting patient ${newPatient.artNumber} down the sink');
    _appStateStreamController.sink.add(AppStatePatientData(newPatient));
  }

  /// Trigger an [AppStatePreferenceAssessmentData] stream event.
  void insertPreferenceAssessmentData(PreferenceAssessment newPreferenceAssessment) async {
    await DatabaseProvider().insertPreferenceAssessment(newPreferenceAssessment);
    _appStateStreamController.sink.add(AppStatePreferenceAssessmentData(newPreferenceAssessment));
  }

  void dispose() {
    _appStateStreamController.close();
  }
}

class AppState {}

class AppStateLoading extends AppState {}

class AppStatePatientListData extends AppState {
  AppStatePatientListData(this.patientList);
  final List<Patient> patientList;
}

class AppStatePatientData extends AppState {
  AppStatePatientData(this.patient);
  final Patient patient;
}

class AppStatePreferenceAssessmentData extends AppState {
  AppStatePreferenceAssessmentData(this.preferenceAssessment);
  final PreferenceAssessment preferenceAssessment;
}
