class VLSuppressedMessage {
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
    _Message.MESSAGE_1: ":-)",
    _Message.MESSAGE_2: "Well done, keep it up!",
    _Message.MESSAGE_3: "Hoooha!",
    _Message.MESSAGE_4: "GOT IT!",
    _Message.MESSAGE_5: "WOW!!!",
    _Message.MESSAGE_6: "PELE EA PELE!",
  };

  _Message _message;

  // Constructors
  // ------------

  // make default constructor private
  VLSuppressedMessage._();

  VLSuppressedMessage.MESSAGE_1() {
    _message = _Message.MESSAGE_1;
  }

  VLSuppressedMessage.MESSAGE_2() {
    _message = _Message.MESSAGE_2;
  }

  VLSuppressedMessage.MESSAGE_3() {
    _message = _Message.MESSAGE_3;
  }

  VLSuppressedMessage.MESSAGE_4() {
    _message = _Message.MESSAGE_4;
  }

  VLSuppressedMessage.MESSAGE_5() {
    _message = _Message.MESSAGE_5;
  }

  VLSuppressedMessage.MESSAGE_6() {
    _message = _Message.MESSAGE_6;
  }

  static VLSuppressedMessage fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _Message message =
        _encoding.entries.firstWhere((MapEntry<_Message, int> entry) {
      return entry.value == code;
    }).key;
    VLSuppressedMessage object = VLSuppressedMessage._();
    object._message = message;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) => o is VLSuppressedMessage && o._message == _message;

  // override hashcode
  @override
  int get hashCode => _message.hashCode;

  static List<VLSuppressedMessage> get allValues => [
        VLSuppressedMessage.MESSAGE_1(),
        VLSuppressedMessage.MESSAGE_2(),
        VLSuppressedMessage.MESSAGE_3(),
        VLSuppressedMessage.MESSAGE_4(),
        VLSuppressedMessage.MESSAGE_5(),
        VLSuppressedMessage.MESSAGE_6(),
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
