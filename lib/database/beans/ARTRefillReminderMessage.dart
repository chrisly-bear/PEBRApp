class ARTRefillReminderMessage {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_Message, int> _encoding = {
    _Message.VISIT_COMING_UP: 1,
    _Message.BA_BONE: 2,
    _Message.GET_MORE: 3,
    _Message.NKA_TSE_LING: 4,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_Message, String> _description = {
    _Message.VISIT_COMING_UP: 'Visit coming up!',
    _Message.BA_BONE: 'Ba Bone uena gheerl / guy',
    _Message.GET_MORE: 'GET SOME MORE!',
    _Message.NKA_TSE_LING: 'Nka tse ling!',
  };

  _Message _message;

  // Constructors
  // ------------

  // make default constructor private
  ARTRefillReminderMessage._();

  ARTRefillReminderMessage.VISIT_COMING_UP() {
    _message = _Message.VISIT_COMING_UP;
  }

  ARTRefillReminderMessage.BA_BONE() {
    _message = _Message.BA_BONE;
  }

  ARTRefillReminderMessage.GET_MORE() {
    _message = _Message.GET_MORE;
  }

  ARTRefillReminderMessage.NKA_TSE_LING() {
    _message = _Message.NKA_TSE_LING;
  }

  static ARTRefillReminderMessage fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _Message message =
        _encoding.entries.firstWhere((MapEntry<_Message, int> entry) {
      return entry.value == code;
    }).key;
    ARTRefillReminderMessage object = ARTRefillReminderMessage._();
    object._message = message;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is ARTRefillReminderMessage && o._message == _message;

  // override hashcode
  @override
  int get hashCode => _message.hashCode;

  static List<ARTRefillReminderMessage> get allValues => [
        ARTRefillReminderMessage.VISIT_COMING_UP(),
        ARTRefillReminderMessage.BA_BONE(),
        ARTRefillReminderMessage.GET_MORE(),
        ARTRefillReminderMessage.NKA_TSE_LING(),
      ];

  /// Returns the text description of this message.
  String get description => _description[_message];

  /// Returns the code that represents this message.
  int get code => _encoding[_message];
}

enum _Message { VISIT_COMING_UP, BA_BONE, GET_MORE, NKA_TSE_LING }
