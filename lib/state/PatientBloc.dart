import 'dart:async';
import 'dart:math';

import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';

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

  /// Trigger an [AppStateLoading] stream event, followed by
  /// [AppStatePatientData] events or an [AppStateNoData] event if there are no
  /// patients in the database.
  Future<void> sinkAllPatientsFromDatabase() async {
    final random = Random();
    _appStateStreamController.sink.add(AppStateLoading());
    final List<Patient> patientList = await DatabaseProvider()
        .retrieveLatestPatients(
            retrieveNonEligibles: false, retrieveNonConsents: false);
    if (patientList.isEmpty) {
      print('No patients in database. Putting AppStateNoData down the sink');
      _appStateStreamController.sink.add(AppStateNoData());
    }
    for (Patient p in patientList) {
      print('Putting patient ${p.artNumber} in the sink');
      _appStateStreamController.sink.add(AppStatePatientData(p));
//      await Future.delayed(Duration(milliseconds: 200 + random.nextInt(1800)));
    }
  }

  /// Trigger an [AppStatePatientData] stream event.
  Future<void> sinkNewPatientData(Patient patient,
      {Set<RequiredAction> oldRequiredActions}) async {
    print('Putting patient ${patient.artNumber} down the sink');
    _appStateStreamController.sink.add(
        AppStatePatientData(patient, oldRequiredActions: oldRequiredActions));
  }

  /// Trigger an [AppStateRequiredActionData] stream event.
  ///
  /// @param action: the action type and which patient it affects
  /// @param isDone: if the action is done (true) or still has to be done (false)
  Future<void> sinkRequiredActionData(
      RequiredAction action, bool isDone) async {
    print(
        'Putting required action done down the sink: ${action.patientART}, ${action.type}, $isDone');
    _appStateStreamController.sink
        .add(AppStateRequiredActionData(action, isDone));
  }

  /// Trigger an [AppStateSettingsRequiredActionData] stream event.
  ///
  /// @param isDone: if the action is done (true) or still has to be done (false)
  Future<void> sinkSettingsRequiredActionData(bool isDone) async {
    print('Putting settings required action done down the sink: $isDone');
    _appStateStreamController.sink
        .add(AppStateSettingsRequiredActionData(isDone));
  }

  void dispose() {
    _appStateStreamController.close();
  }
}

abstract class AppState {}

class AppStateLoading extends AppState {}

class AppStateNoData extends AppState {}

class AppStatePatientData extends AppState {
  final Patient patient;
  final Set<RequiredAction> oldRequiredActions;
  AppStatePatientData(this.patient, {this.oldRequiredActions});
}

class AppStateRequiredActionData extends AppState {
  final bool isDone;
  final RequiredAction action;
  AppStateRequiredActionData(this.action, this.isDone);
}

class AppStateSettingsRequiredActionData extends AppState {
  final bool isDone;
  AppStateSettingsRequiredActionData(this.isDone);
}
