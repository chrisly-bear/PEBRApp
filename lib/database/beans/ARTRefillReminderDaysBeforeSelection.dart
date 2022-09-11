import 'dart:convert';

class ARTRefillReminderDaysBeforeSelection {
  // Class Variables
  // ---------------

  // Encoding as defined in the study codebook.
  // NOTE: These integers are the values that are stored in the database. So if
  // you change the encoding (the integers) you will have to migrate the entire
  // database to the new encoding!
  static const Map<_DaysBefore, int> _encoding = {
    _DaysBefore.SEVEN_DAYS_BEFORE: 1,
    _DaysBefore.THREE_DAYS_BEFORE: 2,
    _DaysBefore.TWO_DAYS_BEFORE: 3,
    _DaysBefore.ONE_DAY_BEFORE: 4,
    _DaysBefore.ZERO_DAYS_BEFORE: 5,
  };

  // These are the descriptions that will be displayed in the UI.
  static String get SEVEN_DAYS_BEFORE => "7 Days Before";
  static String get THREE_DAYS_BEFORE => "3 Days Before";
  static String get TWO_DAYS_BEFORE => "2 Days Before";
  static String get ONE_DAY_BEFORE => "1 Day Before";
  static String get ZERO_DAYS_BEFORE => "On the day of ART Refill";

  // integer representation of how many days each option stands for
  static const Map<_DaysBefore, int> _intRepresentation = {
    _DaysBefore.SEVEN_DAYS_BEFORE: 7,
    _DaysBefore.THREE_DAYS_BEFORE: 3,
    _DaysBefore.TWO_DAYS_BEFORE: 2,
    _DaysBefore.ONE_DAY_BEFORE: 1,
    _DaysBefore.ZERO_DAYS_BEFORE: 0,
  };

  Set<_DaysBefore> _selection = Set();

  String get description {
    // ''
    if (_selection.length == 0) {
      return '';
    }
    // '1 day before' / '0 days before' / '2 days before' / ...
    if (_selection.length == 1) {
      if (_selection.first == _DaysBefore.ONE_DAY_BEFORE) {
        return '1 day before';
      }
      return '${_intRepresentation[_selection.first]} days before';
    }
    // '7, 3, 2, 1 and 0 days before'
    final selectionSorted = _selection.toList();
    selectionSorted
        .sort((_DaysBefore a, _DaysBefore b) => a.index > b.index ? 1 : -1);
    String result = '';
    for (int i = 0; i < selectionSorted.length; i++) {
      if (i == selectionSorted.length - 1) {
        // last item
        result = result.substring(0, result.length - 2); // remove ', '
        result += ' and ${_intRepresentation[selectionSorted[i]]} days before';
      } else {
        result += '${_intRepresentation[selectionSorted[i]]}, ';
      }
    }
    return result;
  }

  // Constructors
  // ------------

  String serializeToJSON() {
    final selectionAsList =
        _selection.map((_DaysBefore pref) => _encoding[pref]).toList();
    selectionAsList.sort((int a, int b) => a > b ? 1 : -1);
    return jsonEncode(selectionAsList);
  }

  static ARTRefillReminderDaysBeforeSelection deserializeFromJSON(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    var obj = ARTRefillReminderDaysBeforeSelection();
    obj._selection = list.map((dynamic code) {
      final _DaysBefore preference =
          _encoding.entries.firstWhere((MapEntry<_DaysBefore, int> entry) {
        return entry.value == code as int;
      }).key;
      return preference;
    }).toSet();
    return obj;
  }

  // Public API
  // ----------

  void deselectAll() {
    _selection.clear();
  }

  bool get areAllDeselected => _selection.isEmpty;

  set SEVEN_DAYS_BEFORE_selected(bool selected) {
    selected
        ? _selection.add(_DaysBefore.SEVEN_DAYS_BEFORE)
        : _selection.remove(_DaysBefore.SEVEN_DAYS_BEFORE);
  }

  set THREE_DAYS_BEFORE_selected(bool selected) {
    selected
        ? _selection.add(_DaysBefore.THREE_DAYS_BEFORE)
        : _selection.remove(_DaysBefore.THREE_DAYS_BEFORE);
  }

  set TWO_DAYS_BEFORE_selected(bool selected) {
    selected
        ? _selection.add(_DaysBefore.TWO_DAYS_BEFORE)
        : _selection.remove(_DaysBefore.TWO_DAYS_BEFORE);
  }

  set ONE_DAY_BEFORE_selected(bool selected) {
    selected
        ? _selection.add(_DaysBefore.ONE_DAY_BEFORE)
        : _selection.remove(_DaysBefore.ONE_DAY_BEFORE);
  }

  set ZERO_DAYS_BEFORE_selected(bool selected) {
    selected
        ? _selection.add(_DaysBefore.ZERO_DAYS_BEFORE)
        : _selection.remove(_DaysBefore.ZERO_DAYS_BEFORE);
  }

  bool get SEVEN_DAYS_BEFORE_selected =>
      _selection.contains(_DaysBefore.SEVEN_DAYS_BEFORE);

  bool get THREE_DAYS_BEFORE_selected =>
      _selection.contains(_DaysBefore.THREE_DAYS_BEFORE);

  bool get TWO_DAYS_BEFORE_selected =>
      _selection.contains(_DaysBefore.TWO_DAYS_BEFORE);

  bool get ONE_DAY_BEFORE_selected =>
      _selection.contains(_DaysBefore.ONE_DAY_BEFORE);

  bool get ZERO_DAYS_BEFORE_selected =>
      _selection.contains(_DaysBefore.ZERO_DAYS_BEFORE);
}

enum _DaysBefore {
  SEVEN_DAYS_BEFORE,
  THREE_DAYS_BEFORE,
  TWO_DAYS_BEFORE,
  ONE_DAY_BEFORE,
  ZERO_DAYS_BEFORE,
}
