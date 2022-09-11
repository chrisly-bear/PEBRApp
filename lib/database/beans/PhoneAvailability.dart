class PhoneAvailability {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_PhoneAvailability, int> _encoding = {
    _PhoneAvailability.YES: 1,
    _PhoneAvailability.NO_NO_PHONE: 2,
    _PhoneAvailability.NO_ONLY_SA_PHONE: 3,
    _PhoneAvailability.NO_NO_RECEIVE: 4,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_PhoneAvailability, String> _description = {
    _PhoneAvailability.YES: 'Yes',
    _PhoneAvailability.NO_NO_PHONE: 'No, no phone',
    _PhoneAvailability.NO_ONLY_SA_PHONE:
        'No, only phone with South African number',
    _PhoneAvailability.NO_NO_RECEIVE:
        'No, I don\'t want to receive any confidential information on my phone',
  };

  _PhoneAvailability _availability;

  // Constructors
  // ------------

  // make default constructor private
  PhoneAvailability._();

  PhoneAvailability.YES() {
    _availability = _PhoneAvailability.YES;
  }

  PhoneAvailability.NO_NO_PHONE() {
    _availability = _PhoneAvailability.NO_NO_PHONE;
  }

  PhoneAvailability.NO_ONLY_SA_PHONE() {
    _availability = _PhoneAvailability.NO_ONLY_SA_PHONE;
  }

  PhoneAvailability.NO_NO_RECEIVE() {
    _availability = _PhoneAvailability.NO_NO_RECEIVE;
  }

  static PhoneAvailability fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _PhoneAvailability availability =
        _encoding.entries.firstWhere((MapEntry<_PhoneAvailability, int> entry) {
      return entry.value == code;
    }).key;
    PhoneAvailability object = PhoneAvailability._();
    object._availability = availability;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is PhoneAvailability && o._availability == _availability;

  // override hashcode
  @override
  int get hashCode => _availability.hashCode;

  static List<PhoneAvailability> get allValues => [
        PhoneAvailability.YES(),
        PhoneAvailability.NO_NO_PHONE(),
        PhoneAvailability.NO_ONLY_SA_PHONE(),
        PhoneAvailability.NO_NO_RECEIVE(),
      ];

  /// Returns the text description of this availability.
  String get description => _description[_availability];

  /// Returns the code that represents this availability.
  int get code => _encoding[_availability];
}

enum _PhoneAvailability { YES, NO_NO_PHONE, NO_ONLY_SA_PHONE, NO_NO_RECEIVE }
