class RefillType {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_Type, int> _encoding = {
    _Type.CHANGE_DATE: 1,
    _Type.DONE: 2,
    _Type.NOT_DONE: 3,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_Type, String> _description = {
    _Type.CHANGE_DATE: 'Change Date',
    _Type.DONE: 'Refill Done',
    _Type.NOT_DONE: 'Refill Not Done',
  };

  _Type _type;

  // Constructors
  // ------------

  // make default constructor private
  RefillType._();

  RefillType.CHANGE_DATE() {
    _type = _Type.CHANGE_DATE;
  }

  RefillType.DONE() {
    _type = _Type.DONE;
  }

  RefillType.NOT_DONE() {
    _type = _Type.NOT_DONE;
  }

  static RefillType fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _Type type =
        _encoding.entries.firstWhere((MapEntry<_Type, int> entry) {
      return entry.value == code;
    }).key;
    RefillType object = RefillType._();
    object._type = type;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) => o is RefillType && o._type == _type;

  // override hashcode
  @override
  int get hashCode => _type.hashCode;

  static List<RefillType> get allValues => [
        RefillType.CHANGE_DATE(),
        RefillType.DONE(),
        RefillType.NOT_DONE(),
      ];

  /// Returns the text description of this type.
  String get description => _description[_type];

  /// Returns the code that represents this type.
  int get code => _encoding[_type];
}

enum _Type { CHANGE_DATE, DONE, NOT_DONE }
