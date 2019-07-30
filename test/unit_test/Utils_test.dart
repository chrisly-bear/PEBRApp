import 'package:flutter_test/flutter_test.dart';
import 'package:pebrapp/utils/Utils.dart';

void main() {
  group('Date Formatting', () {
    // TODO: write date formatting unit tests
  });

  group('SMS', () {

    test('compose SMS', () {
      final String composedSMS = composeSMS(
        message: 'This is a test message.',
        peName: 'Malerato Thabane',
        pePhone: '+266-12-345-678',
      );
      print(composedSMS);
      final String expected = "PEBRA\n\n"
          "This is a test message.\n\n"
          "Etsetsa call-back nomorong ena Malerato Thabane, penya "
          "*140*12345678# (VCL) kapa *181*12345678# (econet).";
      expect(composedSMS, expected);
    });

  });
}