import 'dart:convert';
import 'package:pebrapp/database/beans/SupportOption.dart';

class SupportPreferencesSelection {

  // Class Variables
  // ---------------

  Set<SupportOption> _selection = Set();


  // Constructors
  // ------------

  String serializeToJSON() {
    final selectionAsList = _selection.map((SupportOption option) => option.code).toList();
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
    _selection.add(SupportOption.NONE());
  }

  bool get areAllDeselected => _selection.length == 1 && _selection.first == SupportOption.NONE();

  /// Returns true if no options are selected that have an icon.
  bool get areAllWithIconDeselected => (!NURSE_CLINIC_selected
      && !SATURDAY_CLINIC_CLUB_selected  && !COMMUNITY_YOUTH_CLUB_selected
      && !PHONE_CALL_PE_selected && !HOME_VISIT_PE_selected
      && !SCHOOL_VISIT_PE_selected && !PITSO_VISIT_PE_selected);

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


  bool get NURSE_CLINIC_selected => _selection.contains(SupportOption.NURSE_CLINIC());

  bool get SATURDAY_CLINIC_CLUB_selected => _selection.contains(SupportOption.SATURDAY_CLINIC_CLUB());

  bool get COMMUNITY_YOUTH_CLUB_selected => _selection.contains(SupportOption.COMMUNITY_YOUTH_CLUB());

  bool get PHONE_CALL_PE_selected => _selection.contains(SupportOption.PHONE_CALL_PE());

  bool get HOME_VISIT_PE_selected => _selection.contains(SupportOption.HOME_VISIT_PE());

  bool get SCHOOL_VISIT_PE_selected => _selection.contains(SupportOption.SCHOOL_VISIT_PE());

  bool get PITSO_VISIT_PE_selected => _selection.contains(SupportOption.PITSO_VISIT_PE());

  bool get CONDOM_DEMO_selected => _selection.contains(SupportOption.CONDOM_DEMO());

  bool get CONTRACEPTIVES_INFO_selected => _selection.contains(SupportOption.CONTRACEPTIVES_INFO());

  bool get VMMC_INFO_selected => _selection.contains(SupportOption.VMMC_INFO());

  bool get YOUNG_MOTHERS_GROUP_selected => _selection.contains(SupportOption.YOUNG_MOTHERS_GROUP());

  bool get FEMALE_WORTH_GROUP_selected => _selection.contains(SupportOption.FEMALE_WORTH_GROUP());

  bool get LEGAL_AID_INFO_selected => _selection.contains(SupportOption.LEGAL_AID_INFO());

}
