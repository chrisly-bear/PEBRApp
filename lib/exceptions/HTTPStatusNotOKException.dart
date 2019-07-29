class HTTPStatusNotOKException implements Exception {
  final message;

  HTTPStatusNotOKException([this.message]);

  String toString() {
    if (message == null) return "HTTPStatusNotOKException";
    return message;
  }
}
