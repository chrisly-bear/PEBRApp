class AdherenceReminderFrequency {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_Frequency, int> _encoding = {
    _Frequency.DAILY: 1,
    _Frequency.WEEKLY: 2,
    _Frequency.MONTHLY: 3,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_Frequency, String> _description = {
    _Frequency.DAILY: 'Daily',
    _Frequency.WEEKLY: 'Weekly',
    _Frequency.MONTHLY: 'Monthly',
  };

  static const Map<_Frequency, String> _apiString = {
    _Frequency.DAILY: 'daily',
    _Frequency.WEEKLY: 'weekly',
    _Frequency.MONTHLY: 'monthly',
  };

  _Frequency _frequency;

  // Constructors
  // ------------

  // make default constructor private
  AdherenceReminderFrequency._();

  AdherenceReminderFrequency.DAILY() {
    _frequency = _Frequency.DAILY;
  }

  AdherenceReminderFrequency.WEEKLY() {
    _frequency = _Frequency.WEEKLY;
  }

  AdherenceReminderFrequency.MONTHLY() {
    _frequency = _Frequency.MONTHLY;
  }

  static AdherenceReminderFrequency fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _Frequency frequency =
        _encoding.entries.firstWhere((MapEntry<_Frequency, int> entry) {
      return entry.value == code;
    }).key;
    AdherenceReminderFrequency object = AdherenceReminderFrequency._();
    object._frequency = frequency;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is AdherenceReminderFrequency && o._frequency == _frequency;

  // override hashcode
  @override
  int get hashCode => _frequency.hashCode;

  static List<AdherenceReminderFrequency> get allValues => [
        AdherenceReminderFrequency.DAILY(),
        AdherenceReminderFrequency.WEEKLY(),
        AdherenceReminderFrequency.MONTHLY(),
      ];

  /// Returns the text description of this frequency.
  String get description => _description[_frequency];

  String get visibleImpactAPIString => _apiString[_frequency];

  /// Returns the code that represents this frequency.
  int get code => _encoding[_frequency];
}

enum _Frequency { DAILY, WEEKLY, MONTHLY }
