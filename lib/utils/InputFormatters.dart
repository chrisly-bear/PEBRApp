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
      if (newValue.selection.end >= 2) selectionIndex++;
    }
    if (newTextLength >= 6) {
      newText.write(newValue.text.substring(2, usedSubstringIndex = 5) + '-');
      if (newValue.selection.end >= 5) selectionIndex++;
    }
    if (newTextLength >= 9) {
      newText.write(newValue.text.substring(5, usedSubstringIndex = 8) + ' ');
      if (newValue.selection.end >= 8) selectionIndex++;
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
  if (!phoneExp.hasMatch(value)) return 'Enter a valid Lesotho phone number';
  return null;
}

class ARTNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = StringBuffer();
    if (newTextLength >= 2) {
      newText.write(newValue.text.substring(0, usedSubstringIndex = 1) + '/');
      if (newValue.selection.end >= 1) selectionIndex++;
    }
    if (newTextLength >= 4) {
      newText.write(newValue.text.substring(1, usedSubstringIndex = 3) + '/');
      if (newValue.selection.end >= 3) selectionIndex++;
    }
    if (newTextLength >= 9) {
      newText.write(newValue.text.substring(3, usedSubstringIndex = 8) + ' ');
      if (newValue.selection.end >= 8) selectionIndex++;
    }
    // Dump the rest.
    if (newTextLength >= usedSubstringIndex)
      newText.write(newValue.text.substring(usedSubstringIndex));
    return TextEditingValue(
      text: newText.toString().toUpperCase(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

String validateARTNumber(String value) {
  final RegExp artNumberExp = RegExp(r'^[A-Z]/[A-Z0-9]{2}/\d{5}$');
  if (!artNumberExp.hasMatch(value)) return 'Enter a valid ART number';
  return null;
}

class LabNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: TextSelection.collapsed(offset: newValue.selection.end),
    );
  }
}

String validateLabNumber(String value) {
  final RegExp labNumberExp = RegExp(r'^[A-Z]{3}\d+$');
  if (value == null || value == '') {
    // lab number may be left empty
    return null;
  }
  if (!labNumberExp.hasMatch(value))
    return 'Expected 3 letters followed by 1 or more digits.';
  return null;
}
