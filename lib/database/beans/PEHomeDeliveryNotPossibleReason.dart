class PEHomeDeliveryNotPossibleReason {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_Reason, int> _encoding = {
    _Reason.TOO_FAR: 1,
    _Reason.NO_TIME: 2,
    _Reason.DONT_WANT_TO: 3,
    _Reason.OTHER: 4,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_Reason, String> _description = {
    _Reason.TOO_FAR: "Participant lives far from my place",
    _Reason.NO_TIME: "I don't have time to deliver ART",
    _Reason.DONT_WANT_TO: "I don't want to deliver ART",
    _Reason.OTHER: "Other...",
  };

  _Reason _reason;

  // Constructors
  // ------------

  // make default constructor private
  PEHomeDeliveryNotPossibleReason._();

  PEHomeDeliveryNotPossibleReason.TOO_FAR() {
    _reason = _Reason.TOO_FAR;
  }

  PEHomeDeliveryNotPossibleReason.NO_TIME() {
    _reason = _Reason.NO_TIME;
  }

  PEHomeDeliveryNotPossibleReason.DONT_WANT_TO() {
    _reason = _Reason.DONT_WANT_TO;
  }

  PEHomeDeliveryNotPossibleReason.OTHER() {
    _reason = _Reason.OTHER;
  }

  static PEHomeDeliveryNotPossibleReason fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _Reason reason =
        _encoding.entries.firstWhere((MapEntry<_Reason, int> entry) {
      return entry.value == code;
    }).key;
    PEHomeDeliveryNotPossibleReason object =
        PEHomeDeliveryNotPossibleReason._();
    object._reason = reason;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is PEHomeDeliveryNotPossibleReason && o._reason == _reason;

  // override hashcode
  @override
  int get hashCode => _reason.hashCode;

  static List<PEHomeDeliveryNotPossibleReason> get allValues => [
        PEHomeDeliveryNotPossibleReason.TOO_FAR(),
        PEHomeDeliveryNotPossibleReason.NO_TIME(),
        PEHomeDeliveryNotPossibleReason.DONT_WANT_TO(),
        PEHomeDeliveryNotPossibleReason.OTHER(),
      ];

  /// Returns the text description of this reason.
  String get description => _description[_reason];

  /// Returns the code that represents this reason.
  int get code => _encoding[_reason];
}

enum _Reason { TOO_FAR, NO_TIME, DONT_WANT_TO, OTHER }
