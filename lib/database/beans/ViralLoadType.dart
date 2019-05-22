
class ViralLoadType {

  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_ViralLoadType, int> _encoding = {
    _ViralLoadType.DATABASE_ENTRY: 1,
    _ViralLoadType.MANUAL_ENTRY: 2,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_ViralLoadType, String> _description = {
    _ViralLoadType.DATABASE_ENTRY: 'From Viral Load Database',
    _ViralLoadType.MANUAL_ENTRY: 'Manual Entry',
  };

  _ViralLoadType _type;

  // Constructors
  // ------------

  // make default constructor private
  ViralLoadType._();

  ViralLoadType.DATABASE_ENTRY() {
    _type = _ViralLoadType.DATABASE_ENTRY;
  }

  ViralLoadType.MANUAL_ENTRY() {
    _type = _ViralLoadType.MANUAL_ENTRY;
  }

  static ViralLoadType fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _ViralLoadType type = _encoding.entries.firstWhere((MapEntry<_ViralLoadType, int> entry) {
      return entry.value == code;
    }).key;
    ViralLoadType object = ViralLoadType._();
    object._type = type;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) => o is ViralLoadType && o._type == _type;

  // override hashcode
  @override
  int get hashCode => _type.hashCode;

  static List<ViralLoadType> get allValues => [
    ViralLoadType.DATABASE_ENTRY(),
    ViralLoadType.MANUAL_ENTRY(),
  ];

  /// Returns the text description of this type.
  String get description => _description[_type];

  /// Returns the code that represents this type.
  int get code => _encoding[_type];

}

enum _ViralLoadType { DATABASE_ENTRY, MANUAL_ENTRY }
