import 'dart:convert';

class SupportPreferencesSelection {

  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_SupportPreference, int> _encoding = {
    _SupportPreference.NURSE_CLINIC: 1,
    _SupportPreference.SATURDAY_CLINIC_CLUB: 2,
    _SupportPreference.COMMUNITY_YOUTH_CLUB: 3,
    _SupportPreference.PHONE_CALL_PE: 4,
    _SupportPreference.HOME_VISIT_PE: 5,
    _SupportPreference.SCHOOL_VISIT_PE: 6,
    _SupportPreference.PITSO_VISIT_PE: 7,
    _SupportPreference.CONDOM_DEMO: 8,
    _SupportPreference.CONTRACEPTIVES_INFO: 9,
    _SupportPreference.VMMC_INFO: 10,
    _SupportPreference.YOUNG_MOTHERS_GROUP: 11,
    _SupportPreference.FEMALE_WORTH_GROUP: 12,
    _SupportPreference.LEGAL_AID_INFO: 13,
    _SupportPreference.TUNE_ME_ORG: 14,
    _SupportPreference.NTLAFATSO_FOUNDATION: 15,
  };

  // These are the descriptions that will be displayed in the UI.
  static String get NURSE_CLINIC_DESCRIPTION => "By the nurse at the clinic";
  static String get SATURDAY_CLINIC_CLUB_DESCRIPTION => "Saturday Clinic Club (SCC)";
  static String get COMMUNITY_YOUTH_CLUB_DESCRIPTION => "Community Youth Club (CYC)";
  static String get PHONE_CALL_PE_DESCRIPTION => "Phone Call by PE";
  static String get HOME_VISIT_PE_DESCRIPTION => "Home-visit by PE";
  static String get SCHOOL_VISIT_PE_DESCRIPTION => "School visit and health talk by PE";
  static String get PITSO_VISIT_PE_DESCRIPTION => "Pitso visit and health talk by PE";
  static String get CONDOM_DEMO_DESCRIPTION => "Condom demonstration";
  static String get CONTRACEPTIVES_INFO_DESCRIPTION => "More information about contraceptives";
  static String get VMMC_INFO_DESCRIPTION => "More information about VMMC";
  static String get YOUNG_MOTHERS_GROUP_DESCRIPTION => "Linkage to young mothers group (DREAMS or Mothers-to-Mothers)";
  static String get FEMALE_WORTH_GROUP_DESCRIPTION => "For females: Linkage to a female WORTH group (Social Asset Building Model)";
  static String get LEGAL_AID_INFO_DESCRIPTION => "Legal aid information";
  static String get TUNE_ME_ORG_DESCRIPTION => "Show me tuneme.org (teenage topics)";
  static String get NTLAFATSO_FOUNDATION_DESCRIPTION => "Show me Ntlafatso Foundation Facebook (HIV stigma/discrimination topics)";
  static String get NONE_DESCRIPTION => "No support wished";

  Set<_SupportPreference> _selection = Set();


  // Constructors
  // ------------

  String serializeToJSON() {
    final selectionAsList = _selection.map((_SupportPreference pref) => _encoding[pref]).toList();
    selectionAsList.sort((int a, int b) => a > b ? 1 : -1);
    return jsonEncode(selectionAsList);
  }

  static SupportPreferencesSelection deserializeFromJSON(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    var obj = SupportPreferencesSelection();
    obj._selection = list.map((dynamic code) {
      final _SupportPreference preference = _encoding.entries.firstWhere((MapEntry<_SupportPreference, int> entry) {
        return entry.value == code as int;
      }).key;
      return preference;
    }).toSet();
    return obj;
  }


  // Public API
  // ----------

  void deselectAll() {
    _selection.clear();
  }

  bool get areAllDeselected => _selection.isEmpty;

  set NURSE_CLINIC_selected(bool selected) {
    selected
      ? _selection.add(_SupportPreference.NURSE_CLINIC)
      : _selection.remove(_SupportPreference.NURSE_CLINIC);
  }

  set SATURDAY_CLINIC_CLUB_selected(bool selected) {
    selected
        ? _selection.add(_SupportPreference.SATURDAY_CLINIC_CLUB)
        : _selection.remove(_SupportPreference.SATURDAY_CLINIC_CLUB);
  }

  set COMMUNITY_YOUTH_CLUB_selected(bool selected) {
    selected
        ? _selection.add(_SupportPreference.COMMUNITY_YOUTH_CLUB)
        : _selection.remove(_SupportPreference.COMMUNITY_YOUTH_CLUB);
  }

  set PHONE_CALL_PE_selected(bool selected) {
    selected
        ? _selection.add(_SupportPreference.PHONE_CALL_PE)
        : _selection.remove(_SupportPreference.PHONE_CALL_PE);
  }

  set HOME_VISIT_PE_selected(bool selected) {
    selected
        ? _selection.add(_SupportPreference.HOME_VISIT_PE)
        : _selection.remove(_SupportPreference.HOME_VISIT_PE);
  }

  set SCHOOL_VISIT_PE_selected(bool selected) {
    selected
        ? _selection.add(_SupportPreference.SCHOOL_VISIT_PE)
        : _selection.remove(_SupportPreference.SCHOOL_VISIT_PE);
  }

  set PITSO_VISIT_PE_selected(bool selected) {
    selected
        ? _selection.add(_SupportPreference.PITSO_VISIT_PE)
        : _selection.remove(_SupportPreference.PITSO_VISIT_PE);
  }

  set CONDOM_DEMO_selected(bool selected) {
    selected
        ? _selection.add(_SupportPreference.CONDOM_DEMO)
        : _selection.remove(_SupportPreference.CONDOM_DEMO);
  }

  set CONTRACEPTIVES_INFO_selected(bool selected) {
    selected
        ? _selection.add(_SupportPreference.CONTRACEPTIVES_INFO)
        : _selection.remove(_SupportPreference.CONTRACEPTIVES_INFO);
  }

  set VMMC_INFO_selected(bool selected) {
    selected
        ? _selection.add(_SupportPreference.VMMC_INFO)
        : _selection.remove(_SupportPreference.VMMC_INFO);
  }

  set YOUNG_MOTHERS_GROUP_selected(bool selected) {
    selected
        ? _selection.add(_SupportPreference.YOUNG_MOTHERS_GROUP)
        : _selection.remove(_SupportPreference.YOUNG_MOTHERS_GROUP);
  }

  set FEMALE_WORTH_GROUP_selected(bool selected) {
    selected
        ? _selection.add(_SupportPreference.FEMALE_WORTH_GROUP)
        : _selection.remove(_SupportPreference.FEMALE_WORTH_GROUP);
  }

  set LEGAL_AID_INFO_selected(bool selected) {
    selected
        ? _selection.add(_SupportPreference.LEGAL_AID_INFO)
        : _selection.remove(_SupportPreference.LEGAL_AID_INFO);
  }

  set TUNE_ME_ORG_selected(bool selected) {
    selected
        ? _selection.add(_SupportPreference.TUNE_ME_ORG)
        : _selection.remove(_SupportPreference.TUNE_ME_ORG);
  }

  set NTLAFATSO_FOUNDATION_selected(bool selected) {
    selected
        ? _selection.add(_SupportPreference.NTLAFATSO_FOUNDATION)
        : _selection.remove(_SupportPreference.NTLAFATSO_FOUNDATION);
  }


  bool get NURSE_CLINIC_selected => _selection.contains(_SupportPreference.NURSE_CLINIC);

  bool get SATURDAY_CLINIC_CLUB_selected => _selection.contains(_SupportPreference.SATURDAY_CLINIC_CLUB);

  bool get COMMUNITY_YOUTH_CLUB_selected => _selection.contains(_SupportPreference.COMMUNITY_YOUTH_CLUB);

  bool get PHONE_CALL_PE_selected => _selection.contains(_SupportPreference.PHONE_CALL_PE);

  bool get HOME_VISIT_PE_selected => _selection.contains(_SupportPreference.HOME_VISIT_PE);

  bool get SCHOOL_VISIT_PE_selected => _selection.contains(_SupportPreference.SCHOOL_VISIT_PE);

  bool get PITSO_VISIT_PE_selected => _selection.contains(_SupportPreference.PITSO_VISIT_PE);

  bool get CONDOM_DEMO_selected => _selection.contains(_SupportPreference.CONDOM_DEMO);

  bool get CONTRACEPTIVES_INFO_selected => _selection.contains(_SupportPreference.CONTRACEPTIVES_INFO);

  bool get VMMC_INFO_selected => _selection.contains(_SupportPreference.VMMC_INFO);

  bool get YOUNG_MOTHERS_GROUP_selected => _selection.contains(_SupportPreference.YOUNG_MOTHERS_GROUP);

  bool get FEMALE_WORTH_GROUP_selected => _selection.contains(_SupportPreference.FEMALE_WORTH_GROUP);

  bool get LEGAL_AID_INFO_selected => _selection.contains(_SupportPreference.LEGAL_AID_INFO);

  bool get TUNE_ME_ORG_selected => _selection.contains(_SupportPreference.TUNE_ME_ORG);

  bool get NTLAFATSO_FOUNDATION_selected => _selection.contains(_SupportPreference.NTLAFATSO_FOUNDATION);

}

enum _SupportPreference {
  NURSE_CLINIC,
  SATURDAY_CLINIC_CLUB,
  COMMUNITY_YOUTH_CLUB,
  PHONE_CALL_PE,
  HOME_VISIT_PE,
  SCHOOL_VISIT_PE,
  PITSO_VISIT_PE,
  CONDOM_DEMO,
  CONTRACEPTIVES_INFO,
  VMMC_INFO,
  YOUNG_MOTHERS_GROUP,
  FEMALE_WORTH_GROUP,
  LEGAL_AID_INFO,
  TUNE_ME_ORG,
  NTLAFATSO_FOUNDATION,
}
