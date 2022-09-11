class AdherenceReminderMessage {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_Message, int> _encoding = {
    _Message.MESSAGE_1: 1,
    _Message.MESSAGE_2: 2,
    _Message.MESSAGE_3: 3,
    _Message.MESSAGE_4: 4,
    _Message.MESSAGE_5: 5,
    _Message.MESSAGE_6: 6,
    _Message.MESSAGE_7: 7,
    _Message.MESSAGE_8: 8,
    _Message.MESSAGE_9: 9,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_Message, String> _description = {
    _Message.MESSAGE_1: "Meds time",
    _Message.MESSAGE_2: "Nako ea lithlare",
    _Message.MESSAGE_3: "Recharge!",
    _Message.MESSAGE_4: "Healthy living!",
    _Message.MESSAGE_5: "Bophelo bo botle!",
    _Message.MESSAGE_6: "Me and good health!",
    _Message.MESSAGE_7: "Nna le bophelo bo botle!",
    _Message.MESSAGE_8: "Right time!",
    _Message.MESSAGE_9: "Nake e nepahetseng",
  };

  _Message _message;

  // Constructors
  // ------------

  // make default constructor private
  AdherenceReminderMessage._();

  AdherenceReminderMessage.MESSAGE_1() {
    _message = _Message.MESSAGE_1;
  }

  AdherenceReminderMessage.MESSAGE_2() {
    _message = _Message.MESSAGE_2;
  }

  AdherenceReminderMessage.MESSAGE_3() {
    _message = _Message.MESSAGE_3;
  }

  AdherenceReminderMessage.MESSAGE_4() {
    _message = _Message.MESSAGE_4;
  }

  AdherenceReminderMessage.MESSAGE_5() {
    _message = _Message.MESSAGE_5;
  }

  AdherenceReminderMessage.MESSAGE_6() {
    _message = _Message.MESSAGE_6;
  }

  AdherenceReminderMessage.MESSAGE_7() {
    _message = _Message.MESSAGE_7;
  }

  AdherenceReminderMessage.MESSAGE_8() {
    _message = _Message.MESSAGE_8;
  }

  AdherenceReminderMessage.MESSAGE_9() {
    _message = _Message.MESSAGE_9;
  }

  static AdherenceReminderMessage fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _Message message =
        _encoding.entries.firstWhere((MapEntry<_Message, int> entry) {
      return entry.value == code;
    }).key;
    AdherenceReminderMessage object = AdherenceReminderMessage._();
    object._message = message;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is AdherenceReminderMessage && o._message == _message;

  // override hashcode
  @override
  int get hashCode => _message.hashCode;

  static List<AdherenceReminderMessage> get allValues => [
        AdherenceReminderMessage.MESSAGE_1(),
        AdherenceReminderMessage.MESSAGE_2(),
        AdherenceReminderMessage.MESSAGE_3(),
        AdherenceReminderMessage.MESSAGE_4(),
        AdherenceReminderMessage.MESSAGE_5(),
        AdherenceReminderMessage.MESSAGE_6(),
        AdherenceReminderMessage.MESSAGE_7(),
        AdherenceReminderMessage.MESSAGE_8(),
        AdherenceReminderMessage.MESSAGE_9(),
      ];

  /// Returns the text description of this message.
  String get description => _description[_message];

  /// Returns the code that represents this message.
  int get code => _encoding[_message];
}

enum _Message {
  MESSAGE_1,
  MESSAGE_2,
  MESSAGE_3,
  MESSAGE_4,
  MESSAGE_5,
  MESSAGE_6,
  MESSAGE_7,
  MESSAGE_8,
  MESSAGE_9
}
