import 'package:flutter_test/flutter_test.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';

void main() {
  group('SupportPreferencesSelection', () {

    test('serialization', () {
      var sps = SupportPreferencesSelection();
      sps.nurseAtClinicSelected = true;
      sps.saturdayClinicClubSelected = false;
      sps.homeVisitPESelected = true;
      sps.phoneCallPESelected = false;
      sps.communityYouthClubSelected = true;

      final json = sps.serializeToJSON();
      final expectedJson = '{"saturdayClinicClubSelected":false,"communityYouthClubSelected":true,"phoneCallPESelected":false,"homeVisitPESelected":true,"nurseAtClinicSelected":true}';
      expect(json, expectedJson);
    });

    test('deserialization', () {
      final json = '{"saturdayClinicClubSelected":false,"communityYouthClubSelected":true,"phoneCallPESelected":false,"homeVisitPESelected":true,"nurseAtClinicSelected":true}';
      final sps = SupportPreferencesSelection.deserializeFromJSON(json);

      expect(sps.nurseAtClinicSelected, true);
      expect(sps.saturdayClinicClubSelected, false);
      expect(sps.homeVisitPESelected, true);
      expect(sps.phoneCallPESelected, false);
      expect(sps.communityYouthClubSelected, true);
    });

  });
}