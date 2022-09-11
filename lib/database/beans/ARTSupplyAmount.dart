class ARTSupplyAmount {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_SupplyAmount, int> _encoding = {
    _SupplyAmount.ONE_MONTH: 1,
    _SupplyAmount.THREE_MONTHS: 2,
    _SupplyAmount.SIX_MONTHS: 3,
    _SupplyAmount.TWELVE_MONTHS: 4,
  };

  // These are the descriptions that will be displayed in the UI.
  static const Map<_SupplyAmount, String> _description = {
    _SupplyAmount.ONE_MONTH: '1 month supply',
    _SupplyAmount.THREE_MONTHS: '3 months supply',
    _SupplyAmount.SIX_MONTHS: '6 months supply',
    _SupplyAmount.TWELVE_MONTHS: '12 months supply',
  };

  _SupplyAmount _supplyAmount;

  // Constructors
  // ------------

  // make default constructor private
  ARTSupplyAmount._();

  ARTSupplyAmount.ONE_MONTH() {
    _supplyAmount = _SupplyAmount.ONE_MONTH;
  }

  ARTSupplyAmount.THREE_MONTHS() {
    _supplyAmount = _SupplyAmount.THREE_MONTHS;
  }

  ARTSupplyAmount.SIX_MONTHS() {
    _supplyAmount = _SupplyAmount.SIX_MONTHS;
  }

  ARTSupplyAmount.TWELVE_MONTHS() {
    _supplyAmount = _SupplyAmount.TWELVE_MONTHS;
  }

  static ARTSupplyAmount fromCode(int code) {
    if (code == null || !_encoding.containsValue(code)) {
      return null;
    }
    final _SupplyAmount amount =
        _encoding.entries.firstWhere((MapEntry<_SupplyAmount, int> entry) {
      return entry.value == code;
    }).key;
    ARTSupplyAmount object = ARTSupplyAmount._();
    object._supplyAmount = amount;
    return object;
  }

  // Public API
  // ----------

  // override the equality operator
  @override
  bool operator ==(o) =>
      o is ARTSupplyAmount && o._supplyAmount == _supplyAmount;

  // override hashcode
  @override
  int get hashCode => _supplyAmount.hashCode;

  static List<ARTSupplyAmount> get allValues => [
        ARTSupplyAmount.ONE_MONTH(),
        ARTSupplyAmount.THREE_MONTHS(),
        ARTSupplyAmount.SIX_MONTHS(),
        ARTSupplyAmount.TWELVE_MONTHS(),
      ];

  /// Returns the text description of this supply amount.
  String get description => _description[_supplyAmount];

  /// Returns the code that represents this supply amount.
  int get code => _encoding[_supplyAmount];
}

enum _SupplyAmount { ONE_MONTH, THREE_MONTHS, SIX_MONTHS, TWELVE_MONTHS }
