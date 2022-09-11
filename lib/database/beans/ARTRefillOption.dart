class ARTRefillOption {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_RefillOption, int> _encoding = {
    _RefillOption.CLINIC: 1,
    _RefillOption.PE_HOME_DELIVERY: 2,
    _RefillOption.VHW: 3,
    _RefillOption.COMMUNITY_ADHERENCE_CLUB: 4,
    _RefillOption.TREATMENT_BUDDY: 5,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_RefillOption, String> _description = {
    _RefillOption.CLINIC: "At the clinic",
    _RefillOption.PE_HOME_DELIVERY: "PE (home delivery)",
    _RefillOption.VHW: "VHW (at the VHW's home)",
    _RefillOption.COMMUNITY_ADHERENCE_CLUB: "CAC (Community Adherence Club)",
    _RefillOption.TREATMENT_BUDDY: "Treatment Buddy",
  };

  static const Map<_RefillOption, String> _descriptionShort = {
    _RefillOption.CLINIC: "Clinic",
    _RefillOption.PE_HOME_DELIVERY: "PE",
    _RefillOption.VHW: "VHW",
    _RefillOption.COMMUNITY_ADHERENCE_CLUB: "CAC",
    _RefillOption.TREATMENT_BUDDY: "Treatment Buddy",
  };

  _RefillOption _option;

  // Constructors
  // ------------

  // make default constructor private
  ARTRefillOption._();

  ARTRefillOption.CLINIC() {
    _option = _RefillOption.CLINIC;
  }

  ARTRefillOption.PE_HOME_DELIVERY() {
    _option = _RefillOption.PE_HOME_DELIVERY;
  }

  ARTRefillOption.VHW() {
    _option = _RefillOption.VHW;
  }

  ARTRefillOption.COMMUNITY_ADHERENCE_CLUB() {
    _option = _RefillOption.COMMUNITY_ADHERENCE_CLUB;
  }

  ARTRefillOption.TREATMENT_BUDDY() {
    _option = _RefillOption.TREATMENT_BUDDY;
  }

  static ARTRefillOption fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _RefillOption option =
        _encoding.entries.firstWhere((MapEntry<_RefillOption, int> entry) {
      return entry.value == code;
    }).key;
    ARTRefillOption object = ARTRefillOption._();
    object._option = option;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) => o is ARTRefillOption && o._option == _option;

  // override hashcode
  @override
  int get hashCode => _option.hashCode;

  static List<ARTRefillOption> get allValues => [
        ARTRefillOption.CLINIC(),
        ARTRefillOption.PE_HOME_DELIVERY(),
        ARTRefillOption.VHW(),
        ARTRefillOption.COMMUNITY_ADHERENCE_CLUB(),
        ARTRefillOption.TREATMENT_BUDDY(),
      ];

  /// Returns the text description of this option.
  String get description => _description[_option];

  /// Returns the short text description of this option.
  String get descriptionShort => _descriptionShort[_option];

  /// Returns the code that represents this option.
  int get code => _encoding[_option];
}

enum _RefillOption {
  CLINIC,
  PE_HOME_DELIVERY,
  VHW,
  COMMUNITY_ADHERENCE_CLUB,
  TREATMENT_BUDDY
}
