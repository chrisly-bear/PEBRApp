class Gender {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_Gender, int> _encoding = {
    _Gender.FEMALE: 1,
    _Gender.MALE: 2,
    _Gender.TRANSGENDER: 3,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_Gender, String> _description = {
    _Gender.FEMALE: 'Female',
    _Gender.MALE: 'Male',
    _Gender.TRANSGENDER: 'Transgender',
  };

  _Gender _gender;

  // Constructors
  // ------------

  // make default constructor private
  Gender._();

  Gender.FEMALE() {
    _gender = _Gender.FEMALE;
  }

  Gender.MALE() {
    _gender = _Gender.MALE;
  }

  Gender.TRANSGENDER() {
    _gender = _Gender.TRANSGENDER;
  }

  static Gender fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _Gender gender =
        _encoding.entries.firstWhere((MapEntry<_Gender, int> entry) {
      return entry.value == code;
    }).key;
    Gender object = Gender._();
    object._gender = gender;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) => o is Gender && o._gender == _gender;

  // override hashcode
  @override
  int get hashCode => _gender.hashCode;

  static List<Gender> get allValues => [
        Gender.FEMALE(),
        Gender.MALE(),
        Gender.TRANSGENDER(),
      ];

  /// Returns the text description of this gender.
  String get description => _description[_gender];

  /// Returns the code that represents this gender.
  int get code => _encoding[_gender];
}

enum _Gender { FEMALE, MALE, TRANSGENDER }
