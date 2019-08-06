import 'package:flutter_test/flutter_test.dart';
import 'package:pebrapp/utils/Utils.dart';

void main() {
  group('Date Formatting', () {
    // TODO: write date formatting unit tests
    test('today', () {
      final result = formatDateAndTimeTodayYesterday(DateTime.now());
      expect(result.substring(0, 7), 'today, ');
    });
    test('yesterday', () {
      final result = formatDateAndTimeTodayYesterday(DateTime.now().subtract(Duration(days: 1)));
      expect(result.substring(0, 11), 'yesterday, ');
    });
  });

  group('Date Calculation', () {
    test('today', () {
      final result = differenceInDays(DateTime(2000, 12, 31, 23, 55), DateTime(2000, 12, 31, 0, 5));
      expect(result, 0);
    });
    test('yesterday', () {
      final result = differenceInDays(DateTime(2000, 12, 31, 23, 55), DateTime(2000, 12, 30, 0, 5));
      expect(result, -1);
    });
    test('tomorrow', () {
      final result = differenceInDays(DateTime(2000, 12, 31, 23, 55), DateTime(2001, 1, 1, 0, 5));
      expect(result, 1);
    });
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