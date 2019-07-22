class MultiplePatientsException implements Exception {
  final message;

  MultiplePatientsException([this.message]);

  String toString() {
    if (message == null) return "MultiplePatientsException";
    return message;
  }
}
