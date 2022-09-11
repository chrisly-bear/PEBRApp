class NoConsentReason {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_Reason, int> _encoding = {
    _Reason.NO_TIME: 1,
    _Reason.NO_INTEREST: 2,
    _Reason.MISTRUST: 3,
    _Reason.OTHER: 4,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_Reason, String> _description = {
    _Reason.NO_TIME: 'No time',
    _Reason.NO_INTEREST: 'No interest to participate',
    _Reason.MISTRUST: 'Mistrust',
    _Reason.OTHER: 'Other...',
  };

  _Reason _reason;

  // Constructors
  // ------------

  // make default constructor private
  NoConsentReason._();

  NoConsentReason.NO_TIME() {
    _reason = _Reason.NO_TIME;
  }

  NoConsentReason.NO_INTEREST() {
    _reason = _Reason.NO_INTEREST;
  }

  NoConsentReason.MISTRUST() {
    _reason = _Reason.MISTRUST;
  }

  NoConsentReason.OTHER() {
    _reason = _Reason.OTHER;
  }

  static NoConsentReason fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _Reason reason =
        _encoding.entries.firstWhere((MapEntry<_Reason, int> entry) {
      return entry.value == code;
    }).key;
    NoConsentReason object = NoConsentReason._();
    object._reason = reason;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) => o is NoConsentReason && o._reason == _reason;

  // override hashcode
  @override
  int get hashCode => _reason.hashCode;

  static List<NoConsentReason> get allValues => [
        NoConsentReason.NO_TIME(),
        NoConsentReason.NO_INTEREST(),
        NoConsentReason.MISTRUST(),
        NoConsentReason.OTHER(),
      ];

  /// Returns the text description of this reason.
  String get description => _description[_reason];

  /// Returns the code that represents this reason.
  int get code => _encoding[_reason];
}

enum _Reason { NO_TIME, NO_INTEREST, MISTRUST, OTHER }
