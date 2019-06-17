
class HealthCenter {

  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_HealthCenter, int> _encoding = {
    _HealthCenter.C1: 1,
    _HealthCenter.C2: 2,
    _HealthCenter.C3: 3,
    _HealthCenter.C4: 4,
    _HealthCenter.C5: 5,
    _HealthCenter.C6: 6,
    _HealthCenter.C7: 7,
    _HealthCenter.C8: 8,
    _HealthCenter.C9: 9,
    _HealthCenter.C10: 10,
    _HealthCenter.C11: 11,
    _HealthCenter.C12: 12,
    _HealthCenter.C13: 13,
    _HealthCenter.C14: 14,
    _HealthCenter.C15: 15,
    _HealthCenter.C16: 16,
    _HealthCenter.C17: 17,
    _HealthCenter.C18: 18,
    _HealthCenter.C19: 19,
    _HealthCenter.C20: 20,
    _HealthCenter.C21: 21,
    _HealthCenter.C22: 22,
    _HealthCenter.C23: 23,
    _HealthCenter.C24: 24,
    _HealthCenter.C25: 25,
    _HealthCenter.C26: 26,
    _HealthCenter.C27: 27,
    _HealthCenter.C28: 28,
    _HealthCenter.C29: 29,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_HealthCenter, String> _description = {
    _HealthCenter.C1: "Makhunoane",
    _HealthCenter.C2: "Linakeng",
    _HealthCenter.C3: "Tsime",
    _HealthCenter.C4: "St. Peters",
    _HealthCenter.C5: "St. Paul",
    _HealthCenter.C6: "Boiketsiso",
    _HealthCenter.C7: "Motete",
    _HealthCenter.C8: "Rampai",
    _HealthCenter.C9: "Ngoajane",
    _HealthCenter.C10: "Muela",
    _HealthCenter.C11: "Malefiloane",
    _HealthCenter.C12: "St. James",
    _HealthCenter.C13: "Moeketsane",
    _HealthCenter.C14: "Mapholaneng",
    _HealthCenter.C15: "Linakaneng",
    _HealthCenter.C16: "Molikaliko",
    _HealthCenter.C17: "Libibing",
    _HealthCenter.C18: "Maputsoe Filter Clinic",
    _HealthCenter.C19: "Maputsoe SDA",
    _HealthCenter.C20: "Peka",
    _HealthCenter.C21: "Mamohau",
    _HealthCenter.C22: "Matlameng",
    _HealthCenter.C23: "Pontmain",
    _HealthCenter.C24: "Linotsing",
    _HealthCenter.C25: "Seshote",
    _HealthCenter.C26: "Mahobong",
    _HealthCenter.C27: "St. Monicas",
    _HealthCenter.C28: "Ha Lejone",
    _HealthCenter.C29: "Little Flower",
  };

  static const int _BUTHA_BUTHE = 1;
  static const int _MOKHOTLONG = 2;
  static const int _LERIBE = 3;

  static const Map<_HealthCenter, int> _district = {
    _HealthCenter.C1: _BUTHA_BUTHE,
    _HealthCenter.C2: _BUTHA_BUTHE,
    _HealthCenter.C3: _BUTHA_BUTHE,
    _HealthCenter.C4: _BUTHA_BUTHE,
    _HealthCenter.C5: _BUTHA_BUTHE,
    _HealthCenter.C6: _BUTHA_BUTHE,
    _HealthCenter.C7: _BUTHA_BUTHE,
    _HealthCenter.C8: _BUTHA_BUTHE,
    _HealthCenter.C9: _BUTHA_BUTHE,
    _HealthCenter.C10: _BUTHA_BUTHE,
    _HealthCenter.C11: _MOKHOTLONG,
    _HealthCenter.C12: _MOKHOTLONG,
    _HealthCenter.C13: _MOKHOTLONG,
    _HealthCenter.C14: _MOKHOTLONG,
    _HealthCenter.C15: _MOKHOTLONG,
    _HealthCenter.C16: _MOKHOTLONG,
    _HealthCenter.C17: _MOKHOTLONG,
    _HealthCenter.C18: _LERIBE,
    _HealthCenter.C19: _LERIBE,
    _HealthCenter.C20: _LERIBE,
    _HealthCenter.C21: _LERIBE,
    _HealthCenter.C22: _LERIBE,
    _HealthCenter.C23: _LERIBE,
    _HealthCenter.C24: _LERIBE,
    _HealthCenter.C25: _LERIBE,
    _HealthCenter.C26: _LERIBE,
    _HealthCenter.C27: _LERIBE,
    _HealthCenter.C28: _LERIBE,
    _HealthCenter.C29: _LERIBE,
  };

  static const int _INTERVENTION = 1;
  static const int _CONTROL = 2;

  // TODO: set the proper study arm for each health center before the trial starts
  static const Map<_HealthCenter, int> _studyArm = {
    _HealthCenter.C1: _INTERVENTION,
    _HealthCenter.C2: _INTERVENTION,
    _HealthCenter.C3: _INTERVENTION,
    _HealthCenter.C4: _INTERVENTION,
    _HealthCenter.C5: _INTERVENTION,
    _HealthCenter.C6: _INTERVENTION,
    _HealthCenter.C7: _INTERVENTION,
    _HealthCenter.C8: _INTERVENTION,
    _HealthCenter.C9: _INTERVENTION,
    _HealthCenter.C10: _INTERVENTION,
    _HealthCenter.C11: _INTERVENTION,
    _HealthCenter.C12: _INTERVENTION,
    _HealthCenter.C13: _INTERVENTION,
    _HealthCenter.C14: _INTERVENTION,
    _HealthCenter.C15: _INTERVENTION,
    _HealthCenter.C16: _INTERVENTION,
    _HealthCenter.C17: _INTERVENTION,
    _HealthCenter.C18: _CONTROL,
    _HealthCenter.C19: _CONTROL,
    _HealthCenter.C20: _CONTROL,
    _HealthCenter.C21: _CONTROL,
    _HealthCenter.C22: _CONTROL,
    _HealthCenter.C23: _CONTROL,
    _HealthCenter.C24: _CONTROL,
    _HealthCenter.C25: _CONTROL,
    _HealthCenter.C26: _CONTROL,
    _HealthCenter.C27: _CONTROL,
    _HealthCenter.C28: _CONTROL,
    _HealthCenter.C29: _CONTROL,
  };

  _HealthCenter _healthCenter;

  // Constructors
  // ------------

  // make default constructor private
  HealthCenter._(this._healthCenter);

  static HealthCenter fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _HealthCenter center = _encoding.entries.firstWhere((MapEntry<_HealthCenter, int> entry) => entry.value == code).key;
    return HealthCenter._(center);
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) => o is HealthCenter && o._healthCenter == _healthCenter;

  // override hashcode
  @override
  int get hashCode => _healthCenter.hashCode;

  static List<HealthCenter> get allValues => _HealthCenter.values.map((_HealthCenter hcEnum) => HealthCenter._(hcEnum)).toList();

  /// Returns the text description of this health center.
  String get description => _description[_healthCenter];

  /// Returns the code that represents this health center.
  int get code => _encoding[_healthCenter];

  /// Returns the district code of this health center.
  int get district => _district[_healthCenter];

  /// Returns the district name of this health center.
  String get districtName {
    final int districtCode = _district[_healthCenter];
    switch (districtCode) {
      case _BUTHA_BUTHE:
        return "Butha-Buthe";
      case _MOKHOTLONG:
        return "Mokhotlong";
      case _LERIBE:
        return "Leribe";
      default:
        return "Uknown District";
    }
  }

  /// Returns the study arm for this health center (1 for Intervention, 2 for
  /// Control).
  int get studyArm => _studyArm[_healthCenter];

}

enum _HealthCenter { C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15, C16, C17, C18, C19, C20, C21, C22, C23, C24, C25, C26, C27, C28, C29 }
