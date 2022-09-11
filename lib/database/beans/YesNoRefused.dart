class YesNoRefused {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_Answer, int> _encoding = {
    _Answer.YES: 1,
    _Answer.NO: 2,
    _Answer.REFUSED_TO_ANSWER: 3,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_Answer, String> _description = {
    _Answer.YES: 'Yes',
    _Answer.NO: 'No',
    _Answer.REFUSED_TO_ANSWER: 'Refused to answer',
  };

  _Answer _answer;

  // Constructors
  // ------------

  // make default constructor private
  YesNoRefused._();

  YesNoRefused.YES() {
    _answer = _Answer.YES;
  }

  YesNoRefused.NO() {
    _answer = _Answer.NO;
  }

  YesNoRefused.REFUSED_TO_ANSWER() {
    _answer = _Answer.REFUSED_TO_ANSWER;
  }

  static YesNoRefused fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _Answer answer =
        _encoding.entries.firstWhere((MapEntry<_Answer, int> entry) {
      return entry.value == code;
    }).key;
    YesNoRefused object = YesNoRefused._();
    object._answer = answer;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) => o is YesNoRefused && o._answer == _answer;

  // override hashcode
  @override
  int get hashCode => _answer.hashCode;

  static List<YesNoRefused> get allValues => [
        YesNoRefused.YES(),
        YesNoRefused.NO(),
        YesNoRefused.REFUSED_TO_ANSWER(),
      ];

  /// Returns the text description of this answer.
  String get description => _description[_answer];

  /// Returns the code that represents this answer.
  int get code => _encoding[_answer];
}

enum _Answer { YES, NO, REFUSED_TO_ANSWER }
