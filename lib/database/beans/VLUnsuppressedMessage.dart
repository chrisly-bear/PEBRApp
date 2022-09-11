class VLUnsuppressedMessage {
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
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_Message, String> _description = {
    _Message.MESSAGE_1: "Keep trying. Do better next time.",
    _Message.MESSAGE_2: "No leke. Etsa betere ka moso.",
    _Message.MESSAGE_3: "Ahhh!!!",
    _Message.MESSAGE_4: "OH NO!!!",
    _Message.MESSAGE_5: "Battery low. Take action! -.-'",
    _Message.MESSAGE_6: "Battery e tlase. Etsa hohong! -.-'",
  };

  _Message _message;

  // Constructors
  // ------------

  // make default constructor private
  VLUnsuppressedMessage._();

  VLUnsuppressedMessage.MESSAGE_1() {
    _message = _Message.MESSAGE_1;
  }

  VLUnsuppressedMessage.MESSAGE_2() {
    _message = _Message.MESSAGE_2;
  }

  VLUnsuppressedMessage.MESSAGE_3() {
    _message = _Message.MESSAGE_3;
  }

  VLUnsuppressedMessage.MESSAGE_4() {
    _message = _Message.MESSAGE_4;
  }

  VLUnsuppressedMessage.MESSAGE_5() {
    _message = _Message.MESSAGE_5;
  }

  VLUnsuppressedMessage.MESSAGE_6() {
    _message = _Message.MESSAGE_6;
  }

  static VLUnsuppressedMessage fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _Message message =
        _encoding.entries.firstWhere((MapEntry<_Message, int> entry) {
      return entry.value == code;
    }).key;
    VLUnsuppressedMessage object = VLUnsuppressedMessage._();
    object._message = message;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) => o is VLUnsuppressedMessage && o._message == _message;

  // override hashcode
  @override
  int get hashCode => _message.hashCode;

  static List<VLUnsuppressedMessage> get allValues => [
        VLUnsuppressedMessage.MESSAGE_1(),
        VLUnsuppressedMessage.MESSAGE_2(),
        VLUnsuppressedMessage.MESSAGE_3(),
        VLUnsuppressedMessage.MESSAGE_4(),
        VLUnsuppressedMessage.MESSAGE_5(),
        VLUnsuppressedMessage.MESSAGE_6(),
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
  MESSAGE_6
}
