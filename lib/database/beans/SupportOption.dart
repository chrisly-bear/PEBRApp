class SupportOption {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_SupportOption, int> _encoding = {
    _SupportOption.NURSE_CLINIC: 1,
    _SupportOption.SATURDAY_CLINIC_CLUB: 2,
    _SupportOption.COMMUNITY_YOUTH_CLUB: 3,
    _SupportOption.PHONE_CALL_PE: 4,
    _SupportOption.HOME_VISIT_PE: 5,
    _SupportOption.SCHOOL_VISIT_PE: 6,
    _SupportOption.PITSO_VISIT_PE: 7,
    _SupportOption.CONDOM_DEMO: 8,
    _SupportOption.CONTRACEPTIVES_INFO: 9,
    _SupportOption.VMMC_INFO: 10,
    _SupportOption.YOUNG_MOTHERS_GROUP: 11,
    _SupportOption.FEMALE_WORTH_GROUP: 12,
    _SupportOption.LEGAL_AID_INFO: 13,
    _SupportOption.NONE: 14,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_SupportOption, String> _description = {
    _SupportOption.NURSE_CLINIC: "By the nurse at the clinic",
    _SupportOption.SATURDAY_CLINIC_CLUB: "Saturday Clinic Club (SCC)",
    _SupportOption.COMMUNITY_YOUTH_CLUB: "Community Youth Club (CYC)",
    _SupportOption.PHONE_CALL_PE: "Phone Call by PE",
    _SupportOption.HOME_VISIT_PE: "Home-visit by PE",
    _SupportOption.SCHOOL_VISIT_PE: "School visit and health talk by PE",
    _SupportOption.PITSO_VISIT_PE: "Pitso visit and health talk by PE",
    _SupportOption.CONDOM_DEMO: "Condom demonstration",
    _SupportOption.CONTRACEPTIVES_INFO: "More information about contraceptives",
    _SupportOption.VMMC_INFO: "More information about VMMC",
    _SupportOption.YOUNG_MOTHERS_GROUP:
        "Linkage to young mothers group (DREAMS or Mothers-to-Mothers)",
    _SupportOption.FEMALE_WORTH_GROUP:
        "Linkage to a female WORTH group (Social Asset Building Model)",
    _SupportOption.LEGAL_AID_INFO:
        "More information about gender-based violence / legal aid",
    _SupportOption.NONE: "No support wished",
  };

  _SupportOption _option;

  // Constructors
  // ------------

  // make default constructor private
  SupportOption._();

  SupportOption.NURSE_CLINIC() {
    _option = _SupportOption.NURSE_CLINIC;
  }

  SupportOption.SATURDAY_CLINIC_CLUB() {
    _option = _SupportOption.SATURDAY_CLINIC_CLUB;
  }

  SupportOption.COMMUNITY_YOUTH_CLUB() {
    _option = _SupportOption.COMMUNITY_YOUTH_CLUB;
  }

  SupportOption.PHONE_CALL_PE() {
    _option = _SupportOption.PHONE_CALL_PE;
  }

  SupportOption.HOME_VISIT_PE() {
    _option = _SupportOption.HOME_VISIT_PE;
  }

  SupportOption.SCHOOL_VISIT_PE() {
    _option = _SupportOption.SCHOOL_VISIT_PE;
  }

  SupportOption.PITSO_VISIT_PE() {
    _option = _SupportOption.PITSO_VISIT_PE;
  }

  SupportOption.CONDOM_DEMO() {
    _option = _SupportOption.CONDOM_DEMO;
  }

  SupportOption.CONTRACEPTIVES_INFO() {
    _option = _SupportOption.CONTRACEPTIVES_INFO;
  }

  SupportOption.VMMC_INFO() {
    _option = _SupportOption.VMMC_INFO;
  }

  SupportOption.YOUNG_MOTHERS_GROUP() {
    _option = _SupportOption.YOUNG_MOTHERS_GROUP;
  }

  SupportOption.FEMALE_WORTH_GROUP() {
    _option = _SupportOption.FEMALE_WORTH_GROUP;
  }

  SupportOption.LEGAL_AID_INFO() {
    _option = _SupportOption.LEGAL_AID_INFO;
  }

  SupportOption.NONE() {
    _option = _SupportOption.NONE;
  }

  static SupportOption fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _SupportOption option =
        _encoding.entries.firstWhere((MapEntry<_SupportOption, int> entry) {
      return entry.value == code;
    }).key;
    SupportOption object = SupportOption._();
    object._option = option;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) => o is SupportOption && o._option == _option;

  // override hashcode
  @override
  int get hashCode => _option.hashCode;

  static List<SupportOption> get allValues => [
        SupportOption.NURSE_CLINIC(),
        SupportOption.SATURDAY_CLINIC_CLUB(),
        SupportOption.COMMUNITY_YOUTH_CLUB(),
        SupportOption.PHONE_CALL_PE(),
        SupportOption.HOME_VISIT_PE(),
        SupportOption.SCHOOL_VISIT_PE(),
        SupportOption.PITSO_VISIT_PE(),
        SupportOption.CONDOM_DEMO(),
        SupportOption.CONTRACEPTIVES_INFO(),
        SupportOption.VMMC_INFO(),
        SupportOption.YOUNG_MOTHERS_GROUP(),
        SupportOption.FEMALE_WORTH_GROUP(),
        SupportOption.LEGAL_AID_INFO(),
        SupportOption.NONE(),
      ];

  /// Returns the text description of this message.
  String get description => _description[_option];

  /// Returns the code that represents this message.
  int get code => _encoding[_option];
}

enum _SupportOption {
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
  NONE,
}
