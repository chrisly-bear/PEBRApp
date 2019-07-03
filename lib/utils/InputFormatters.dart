import 'package:flutter/services.dart';

/// Format incoming numeric text to fit the format of +266-12-345-678
class LesothoPhoneNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = StringBuffer();
    if (newTextLength >= 3) {
      newText.write(newValue.text.substring(0, usedSubstringIndex = 2) + '-');
      if (newValue.selection.end >= 2)
        selectionIndex++;
    }
    if (newTextLength >= 6) {
      newText.write(newValue.text.substring(2, usedSubstringIndex = 5) + '-');
      if (newValue.selection.end >= 5)
        selectionIndex++;
    }
    if (newTextLength >= 9) {
      newText.write(newValue.text.substring(5, usedSubstringIndex = 8) + ' ');
      if (newValue.selection.end >= 8)
        selectionIndex++;
    }
    // Dump the rest.
    if (newTextLength >= usedSubstringIndex)
      newText.write(newValue.text.substring(usedSubstringIndex));
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

String validatePhoneNumber(String value) {
  final RegExp phoneExp = RegExp(r'^\d\d\-\d\d\d\-\d\d\d$');
  if (!phoneExp.hasMatch(value))
    return 'Enter a valid Lesotho phone number';
  return null;
}
