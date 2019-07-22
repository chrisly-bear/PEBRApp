class VisibleImpactLoginFailedException implements Exception {
  final message;

  VisibleImpactLoginFailedException([this.message]);

  String toString() {
    if (message == null) return "VisibleImpactLoginFailedException";
    return message;
  }
}
