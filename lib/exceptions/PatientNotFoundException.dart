class PatientNotFoundException implements Exception {
  final message;

  PatientNotFoundException([this.message]);

  String toString() {
    if (message == null) return "PatientNotFoundException";
    return message;
  }
}
