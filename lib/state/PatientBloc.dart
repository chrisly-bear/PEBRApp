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

  Stream<AppState> get appState => _appStateStreamController.stream;

  void loadPatientData() async {
    _appStateStreamController.sink.add(AppStateLoading());
    final List<Patient> patientList = await DatabaseProvider().retrieveLatestPatients();
    _appStateStreamController.sink.add(AppStatePatientListData(patientList));

    /*
    // Feeding the patients to the stream one by one leads to race conditions
    // (not all the patients are received by the StreamBuilder listener)
    for (Patient p in patientList) {
      await Future.delayed(Duration(milliseconds: 1000)); // TODO: remove this debug pause
      print('Putting patient ${p.artNumber} in the sink');
      _appStateStreamController.sink.add(AppStatePatientData(p));
    }
    */
  }

  void insertPatientData(Patient newPatient) async {
    _appStateStreamController.sink.add(AppStateLoading());
    await DatabaseProvider().insertPatient(newPatient);
    _appStateStreamController.sink.add(AppStatePatientData(newPatient));
  }

  void insertPreferenceAssessmentData(PreferenceAssessment newPreferenceAssessment) async {
    _appStateStreamController.sink.add(AppStateLoading());
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
