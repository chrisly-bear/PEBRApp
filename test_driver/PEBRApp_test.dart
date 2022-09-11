// Imports the Flutter Driver API
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('PEBRApp', () {
    // First, define the Finders. We can use these to locate Widgets from the
    // test suite.
    final buttonFinder = find.byValueKey('addPatient');
    final titleFinder = find.byValueKey('newOrEditPatientTitle');

    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('opens screen for recording a new patient', () async {
      // First, tap on the button
      await driver.tap(buttonFinder);

      // Then, verify that the title has the expected text
      expect(await driver.getText(titleFinder), "New Participant");
    });
  });
}
