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
      final result = formatDateAndTimeTodayYesterday(
          DateTime.now().subtract(Duration(days: 1)));
      expect(result.substring(0, 11), 'yesterday, ');
    });
  });

  group('Date Calculation', () {
    group('Date Calculation (local time)', () {
      test('today local-local', () {
        final result = differenceInDays(
            DateTime(2000, 12, 31, 0, 5), DateTime(2000, 12, 31, 23, 55));
        expect(result, 0);
      });
      test('yesterday local-local', () {
        final result = differenceInDays(
            DateTime(2000, 12, 31, 0, 5), DateTime(2000, 12, 30, 23, 55));
        expect(result, -1);
      });
      test('tomorrow local-local', () {
        final result = differenceInDays(
            DateTime(2000, 12, 31, 23, 55), DateTime(2001, 1, 1, 0, 5));
        expect(result, 1);
      });
      test('today utc-local', () {
        final operation = () {
          differenceInDays(DateTime(2000, 12, 31, 0, 5).toUtc(),
              DateTime(2000, 12, 31, 23, 55));
        };
        expect(() => operation(), throwsAssertionError);
      });
      test('yesterday utc-local', () {
        final operation = () {
          differenceInDays(DateTime(2000, 12, 31, 0, 5).toUtc(),
              DateTime(2000, 12, 30, 23, 55));
        };
        expect(() => operation(), throwsAssertionError);
      });
      test('tomorrow utc-local', () {
        final operation = () {
          differenceInDays(DateTime(2000, 12, 31, 23, 55).toUtc(),
              DateTime(2001, 1, 1, 0, 5));
        };
        expect(() => operation(), throwsAssertionError);
      });
      test('today local-utc', () {
        final operation = () {
          differenceInDays(DateTime(2000, 12, 31, 0, 5),
              DateTime(2000, 12, 31, 23, 55).toUtc());
        };
        expect(() => operation(), throwsAssertionError);
      });
      test('yesterday local-utc', () {
        final operation = () {
          differenceInDays(DateTime(2000, 12, 31, 0, 5),
              DateTime(2000, 12, 30, 23, 55).toUtc());
        };
        expect(() => operation(), throwsAssertionError);
      });
      test('tomorrow local-utc', () {
        final operation = () {
          differenceInDays(DateTime(2000, 12, 31, 23, 55),
              DateTime(2001, 1, 1, 0, 5).toUtc());
        };
        expect(() => operation(), throwsAssertionError);
      });
    });

    group('Date Calculation (UTC)', () {
      test('today utc-utc', () {
        final result = differenceInDays(DateTime.utc(2000, 12, 31, 0, 5),
            DateTime.utc(2000, 12, 31, 23, 55));
        expect(result, 0);
      });
      test('yesterday utc-utc', () {
        final result = differenceInDays(DateTime.utc(2000, 12, 31, 0, 5),
            DateTime.utc(2000, 12, 30, 23, 55));
        expect(result, -1);
      });
      test('tomorrow utc-utc', () {
        final result = differenceInDays(
            DateTime.utc(2000, 12, 31, 23, 55), DateTime.utc(2001, 1, 1, 0, 5));
        expect(result, 1);
      });
      test('today utc-local', () {
        final operation = () {
          differenceInDays(DateTime.utc(2000, 12, 31, 0, 5),
              DateTime.utc(2000, 12, 31, 23, 55).toLocal());
        };
        expect(() => operation(), throwsAssertionError);
      });
      test('yesterday utc-local', () {
        final operation = () {
          differenceInDays(DateTime.utc(2000, 12, 31, 0, 5),
              DateTime.utc(2000, 12, 30, 23, 55).toLocal());
        };
        expect(() => operation(), throwsAssertionError);
      });
      test('tomorrow utc-local', () {
        final operation = () {
          differenceInDays(DateTime.utc(2000, 12, 31, 23, 55),
              DateTime.utc(2001, 1, 1, 0, 5).toLocal());
        };
        expect(() => operation(), throwsAssertionError);
      });
      test('today local-utc', () {
        final operation = () {
          differenceInDays(DateTime.utc(2000, 12, 31, 0, 5).toLocal(),
              DateTime.utc(2000, 12, 31, 23, 55));
        };
        expect(() => operation(), throwsAssertionError);
      });
      test('yesterday local-utc', () {
        final operation = () {
          differenceInDays(DateTime.utc(2000, 12, 31, 0, 5).toLocal(),
              DateTime.utc(2000, 12, 30, 23, 55));
        };
        expect(() => operation(), throwsAssertionError);
      });
      test('tomorrow local-utc', () {
        final operation = () {
          differenceInDays(DateTime.utc(2000, 12, 31, 23, 55).toLocal(),
              DateTime.utc(2001, 1, 1, 0, 5));
        };
        expect(() => operation(), throwsAssertionError);
      });
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
