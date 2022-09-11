class ViralLoadSource {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_ViralLoadSource, int> _encoding = {
    _ViralLoadSource.DATABASE: 1,
    _ViralLoadSource.MANUAL_INPUT: 2,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_ViralLoadSource, String> _description = {
    _ViralLoadSource.DATABASE: 'From Viral Load Database',
    _ViralLoadSource.MANUAL_INPUT: 'Manual Entry',
  };

  _ViralLoadSource _source;

  // Constructors
  // ------------

  // make default constructor private
  ViralLoadSource._();

  ViralLoadSource.DATABASE() {
    _source = _ViralLoadSource.DATABASE;
  }

  ViralLoadSource.MANUAL_INPUT() {
    _source = _ViralLoadSource.MANUAL_INPUT;
  }

  static ViralLoadSource fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _ViralLoadSource source =
        _encoding.entries.firstWhere((MapEntry<_ViralLoadSource, int> entry) {
      return entry.value == code;
    }).key;
    ViralLoadSource object = ViralLoadSource._();
    object._source = source;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) => o is ViralLoadSource && o._source == _source;

  // override hashcode
  @override
  int get hashCode => _source.hashCode;

  static List<ViralLoadSource> get allValues => [
        ViralLoadSource.DATABASE(),
        ViralLoadSource.MANUAL_INPUT(),
      ];

  /// Returns the text description of this source.
  String get description => _description[_source];

  /// Returns the code that represents this source.
  int get code => _encoding[_source];
}

enum _ViralLoadSource { DATABASE, MANUAL_INPUT }
