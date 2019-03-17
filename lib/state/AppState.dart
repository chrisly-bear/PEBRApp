import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';

class AppState {
  bool isLoading = true;
  Map<Patient, PreferenceAssessment> patientsPreferenceAssessmentJoined = Map<Patient, PreferenceAssessment>();

  List<Patient> get patients { return patientsPreferenceAssessmentJoined.keys.toList(); }
}
