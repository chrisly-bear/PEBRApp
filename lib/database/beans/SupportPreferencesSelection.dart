import 'dart:convert';
import 'package:pebrapp/database/beans/SupportOption.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';

class SupportPreferencesSelection {
  // Class Variables
  // ---------------

  Set<SupportOption> _selection = {};

  // Constructors
  // ------------

  SupportPreferencesSelection();

  SupportPreferencesSelection.fromLastAssessment(PreferenceAssessment pa) {
    if (pa != null) {
      final SupportPreferencesSelection lastSelection = pa.supportPreferences;
      NURSE_CLINIC_selected =
          lastSelection.NURSE_CLINIC_selected && !pa.NURSE_CLINIC_done;
      SATURDAY_CLINIC_CLUB_selected =
          lastSelection.SATURDAY_CLINIC_CLUB_selected &&
              pa.saturdayClinicClubAvailable &&
              !pa.SATURDAY_CLINIC_CLUB_done;
      COMMUNITY_YOUTH_CLUB_selected =
          lastSelection.COMMUNITY_YOUTH_CLUB_selected &&
              pa.communityYouthClubAvailable &&
              !pa.COMMUNITY_YOUTH_CLUB_done;
      PHONE_CALL_PE_selected =
          lastSelection.PHONE_CALL_PE_selected && !pa.PHONE_CALL_PE_done;
      HOME_VISIT_PE_selected = lastSelection.HOME_VISIT_PE_selected &&
          pa.homeVisitPEPossible &&
          !pa.HOME_VISIT_PE_done;
      SCHOOL_VISIT_PE_selected = lastSelection.SCHOOL_VISIT_PE_selected &&
          pa.schoolVisitPEPossible &&
          !pa.SCHOOL_VISIT_PE_done;
      PITSO_VISIT_PE_selected = lastSelection.PITSO_VISIT_PE_selected &&
          pa.pitsoPEPossible &&
          !pa.PITSO_VISIT_PE_done;
      CONDOM_DEMO_selected =
          lastSelection.CONDOM_DEMO_selected && !pa.CONDOM_DEMO_done;
      CONTRACEPTIVES_INFO_selected =
          lastSelection.CONTRACEPTIVES_INFO_selected &&
              !pa.CONTRACEPTIVES_INFO_done;
      VMMC_INFO_selected =
          lastSelection.VMMC_INFO_selected && !pa.VMMC_INFO_done;
      YOUNG_MOTHERS_GROUP_selected =
          lastSelection.YOUNG_MOTHERS_GROUP_selected &&
              pa.youngMothersAvailable &&
              !pa.YOUNG_MOTHERS_GROUP_done;
      FEMALE_WORTH_GROUP_selected = lastSelection.FEMALE_WORTH_GROUP_selected &&
          pa.femaleWorthAvailable &&
          !pa.FEMALE_WORTH_GROUP_done;
      LEGAL_AID_INFO_selected =
          lastSelection.LEGAL_AID_INFO_selected && !pa.LEGAL_AID_INFO_done;
    }
  }

  String toExcelString() {
    String excelString = '';
    final List<int> selectionAsList =
        _selection.map((SupportOption option) => option.code).toList();
    selectionAsList.sort((int a, int b) => a > b ? 1 : -1);
    if (selectionAsList.isEmpty) {
      selectionAsList.add(SupportOption.NONE().code);
    }
    selectionAsList.forEach((int code) => excelString += '$code, ');
    return excelString.substring(0, excelString.length - 2);
  }

  String serializeToJSON() {
    final List<int> selectionAsList =
        _selection.map((SupportOption option) => option.code).toList();
    selectionAsList.sort((int a, int b) => a > b ? 1 : -1);
    return jsonEncode(selectionAsList);
  }

  static SupportPreferencesSelection deserializeFromJSON(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    var obj = SupportPreferencesSelection();
    obj._selection = list.map((dynamic code) {
      final SupportOption option = SupportOption.fromCode(code);
      return option;
    }).toSet();
    return obj;
  }

  // Public API
  // ----------

  void deselectAll() {
    _selection.clear();
  }

  bool get areAllDeselected => _selection.length == 0;

  set NURSE_CLINIC_selected(bool selected) {
    selected
        ? _selection.add(SupportOption.NURSE_CLINIC())
        : _selection.remove(SupportOption.NURSE_CLINIC());
  }

  set SATURDAY_CLINIC_CLUB_selected(bool selected) {
    selected
        ? _selection.add(SupportOption.SATURDAY_CLINIC_CLUB())
        : _selection.remove(SupportOption.SATURDAY_CLINIC_CLUB());
  }

  set COMMUNITY_YOUTH_CLUB_selected(bool selected) {
    selected
        ? _selection.add(SupportOption.COMMUNITY_YOUTH_CLUB())
        : _selection.remove(SupportOption.COMMUNITY_YOUTH_CLUB());
  }

  set PHONE_CALL_PE_selected(bool selected) {
    selected
        ? _selection.add(SupportOption.PHONE_CALL_PE())
        : _selection.remove(SupportOption.PHONE_CALL_PE());
  }

  set HOME_VISIT_PE_selected(bool selected) {
    selected
        ? _selection.add(SupportOption.HOME_VISIT_PE())
        : _selection.remove(SupportOption.HOME_VISIT_PE());
  }

  set SCHOOL_VISIT_PE_selected(bool selected) {
    selected
        ? _selection.add(SupportOption.SCHOOL_VISIT_PE())
        : _selection.remove(SupportOption.SCHOOL_VISIT_PE());
  }

  set PITSO_VISIT_PE_selected(bool selected) {
    selected
        ? _selection.add(SupportOption.PITSO_VISIT_PE())
        : _selection.remove(SupportOption.PITSO_VISIT_PE());
  }

  set CONDOM_DEMO_selected(bool selected) {
    selected
        ? _selection.add(SupportOption.CONDOM_DEMO())
        : _selection.remove(SupportOption.CONDOM_DEMO());
  }

  set CONTRACEPTIVES_INFO_selected(bool selected) {
    selected
        ? _selection.add(SupportOption.CONTRACEPTIVES_INFO())
        : _selection.remove(SupportOption.CONTRACEPTIVES_INFO());
  }

  set VMMC_INFO_selected(bool selected) {
    selected
        ? _selection.add(SupportOption.VMMC_INFO())
        : _selection.remove(SupportOption.VMMC_INFO());
  }

  set YOUNG_MOTHERS_GROUP_selected(bool selected) {
    selected
        ? _selection.add(SupportOption.YOUNG_MOTHERS_GROUP())
        : _selection.remove(SupportOption.YOUNG_MOTHERS_GROUP());
  }

  set FEMALE_WORTH_GROUP_selected(bool selected) {
    selected
        ? _selection.add(SupportOption.FEMALE_WORTH_GROUP())
        : _selection.remove(SupportOption.FEMALE_WORTH_GROUP());
  }

  set LEGAL_AID_INFO_selected(bool selected) {
    selected
        ? _selection.add(SupportOption.LEGAL_AID_INFO())
        : _selection.remove(SupportOption.LEGAL_AID_INFO());
  }

  bool get NURSE_CLINIC_selected =>
      _selection.contains(SupportOption.NURSE_CLINIC());

  bool get SATURDAY_CLINIC_CLUB_selected =>
      _selection.contains(SupportOption.SATURDAY_CLINIC_CLUB());

  bool get COMMUNITY_YOUTH_CLUB_selected =>
      _selection.contains(SupportOption.COMMUNITY_YOUTH_CLUB());

  bool get PHONE_CALL_PE_selected =>
      _selection.contains(SupportOption.PHONE_CALL_PE());

  bool get HOME_VISIT_PE_selected =>
      _selection.contains(SupportOption.HOME_VISIT_PE());

  bool get SCHOOL_VISIT_PE_selected =>
      _selection.contains(SupportOption.SCHOOL_VISIT_PE());

  bool get PITSO_VISIT_PE_selected =>
      _selection.contains(SupportOption.PITSO_VISIT_PE());

  bool get CONDOM_DEMO_selected =>
      _selection.contains(SupportOption.CONDOM_DEMO());

  bool get CONTRACEPTIVES_INFO_selected =>
      _selection.contains(SupportOption.CONTRACEPTIVES_INFO());

  bool get VMMC_INFO_selected => _selection.contains(SupportOption.VMMC_INFO());

  bool get YOUNG_MOTHERS_GROUP_selected =>
      _selection.contains(SupportOption.YOUNG_MOTHERS_GROUP());

  bool get FEMALE_WORTH_GROUP_selected =>
      _selection.contains(SupportOption.FEMALE_WORTH_GROUP());

  bool get LEGAL_AID_INFO_selected =>
      _selection.contains(SupportOption.LEGAL_AID_INFO());
}
