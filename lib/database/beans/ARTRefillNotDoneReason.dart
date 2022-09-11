class ARTRefillNotDoneReason {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_Reason, int> _encoding = {
    _Reason.PATIENT_DIED: 1,
    _Reason.PATIENT_HOSPITALIZED: 2,
    _Reason.ART_FROM_OTHER_CLINIC_LESOTHO: 3,
    _Reason.ART_FROM_OTHER_CLINIC_SA: 4,
    _Reason.NOT_TAKING_ART_ANYMORE: 5,
    _Reason.STOCK_OUT_OR_FAILED_DELIVERY: 6,
    _Reason.NO_INFORMATION: 7,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_Reason, String> _description = {
    _Reason.PATIENT_DIED: "Participant Died",
    _Reason.PATIENT_HOSPITALIZED: "Participant is Hospitalized",
    _Reason.ART_FROM_OTHER_CLINIC_LESOTHO:
        "Participant gets ART from another clinic in Lesotho",
    _Reason.ART_FROM_OTHER_CLINIC_SA:
        "Participant gets ART from another clinic in South Africa",
    _Reason.NOT_TAKING_ART_ANYMORE: "Participant does not take ART anymore",
    _Reason.STOCK_OUT_OR_FAILED_DELIVERY:
        "ART stock out or PE or VHW failed to deliver ART to participant",
    _Reason.NO_INFORMATION: "No information found about the participant at all",
  };

  _Reason _reason;

  // Constructors
  // ------------

  // make default constructor private
  ARTRefillNotDoneReason._();

  ARTRefillNotDoneReason.PATIENT_DIED() {
    _reason = _Reason.PATIENT_DIED;
  }

  ARTRefillNotDoneReason.PATIENT_HOSPITALIZED() {
    _reason = _Reason.PATIENT_HOSPITALIZED;
  }

  ARTRefillNotDoneReason.ART_FROM_OTHER_CLINIC_LESOTHO() {
    _reason = _Reason.ART_FROM_OTHER_CLINIC_LESOTHO;
  }

  ARTRefillNotDoneReason.ART_FROM_OTHER_CLINIC_SA() {
    _reason = _Reason.ART_FROM_OTHER_CLINIC_SA;
  }

  ARTRefillNotDoneReason.NOT_TAKING_ART_ANYMORE() {
    _reason = _Reason.NOT_TAKING_ART_ANYMORE;
  }

  ARTRefillNotDoneReason.STOCK_OUT_OR_FAILED_DELIVERY() {
    _reason = _Reason.STOCK_OUT_OR_FAILED_DELIVERY;
  }

  ARTRefillNotDoneReason.NO_INFORMATION() {
    _reason = _Reason.NO_INFORMATION;
  }

  static ARTRefillNotDoneReason fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _Reason reason =
        _encoding.entries.firstWhere((MapEntry<_Reason, int> entry) {
      return entry.value == code;
    }).key;
    ARTRefillNotDoneReason object = ARTRefillNotDoneReason._();
    object._reason = reason;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) => o is ARTRefillNotDoneReason && o._reason == _reason;

  // override hashcode
  @override
  int get hashCode => _reason.hashCode;

  static List<ARTRefillNotDoneReason> get allValues => [
        ARTRefillNotDoneReason.PATIENT_DIED(),
        ARTRefillNotDoneReason.PATIENT_HOSPITALIZED(),
        ARTRefillNotDoneReason.ART_FROM_OTHER_CLINIC_LESOTHO(),
        ARTRefillNotDoneReason.ART_FROM_OTHER_CLINIC_SA(),
        ARTRefillNotDoneReason.NOT_TAKING_ART_ANYMORE(),
        ARTRefillNotDoneReason.STOCK_OUT_OR_FAILED_DELIVERY(),
        ARTRefillNotDoneReason.NO_INFORMATION(),
      ];

  /// Returns the text description of this reason.
  String get description => _description[_reason];

  /// Returns the code that represents this reason.
  int get code => _encoding[_reason];
}

enum _Reason {
  PATIENT_DIED,
  PATIENT_HOSPITALIZED,
  ART_FROM_OTHER_CLINIC_LESOTHO,
  ART_FROM_OTHER_CLINIC_SA,
  NOT_TAKING_ART_ANYMORE,
  STOCK_OUT_OR_FAILED_DELIVERY,
  NO_INFORMATION
}
