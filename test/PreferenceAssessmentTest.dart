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
      sps.schoolTalkPESelected = false;

      final json = sps.serializeToJSON();
      final expectedJson = '{"saturdayClinicClubSelected":false,"communityYouthClubSelected":true,"phoneCallPESelected":false,"homeVisitPESelected":true,"nurseAtClinicSelected":true,"schoolTalkPESelected":false}';
      expect(json, expectedJson);
    });

    test('deserialization', () {
      final json = '{"saturdayClinicClubSelected":false,"communityYouthClubSelected":true,"phoneCallPESelected":false,"homeVisitPESelected":true,"nurseAtClinicSelected":true,"schoolTalkPESelected":false}';
      final sps = SupportPreferencesSelection.deserializeFromJSON(json);

      expect(sps.nurseAtClinicSelected, true);
      expect(sps.saturdayClinicClubSelected, false);
      expect(sps.homeVisitPESelected, true);
      expect(sps.phoneCallPESelected, false);
      expect(sps.communityYouthClubSelected, true);
      expect(sps.schoolTalkPESelected, false);
    });

  });

  group('Enums', () {

    test('ARTRefillOption serialization', () {
      int serializedValueClinic = ARTRefillOption.CLINIC.index;
      expect(serializedValueClinic, 0);
      int serializedValuePEHomeDelivery = ARTRefillOption.PE_HOME_DELIVERY.index;
      expect(serializedValuePEHomeDelivery, 1);
      int serializedValueVHW = ARTRefillOption.VHW.index;
      expect(serializedValueVHW, 2);
      int serializedValueTreatmentBuddy = ARTRefillOption.TREATMENT_BUDDY.index;
      expect(serializedValueTreatmentBuddy, 3);
      int serializedValueCAC = ARTRefillOption.COMMUNITY_ADHERENCE_CLUB.index;
      expect(serializedValueCAC, 4);
    });

    test('ARTRefillOption deserialization', () {
      ARTRefillOption deserializedValueClinic = ARTRefillOption.values[0];
      expect(deserializedValueClinic, ARTRefillOption.CLINIC);
      ARTRefillOption deserializedValuePEHomeDelivery = ARTRefillOption.values[1];
      expect(deserializedValuePEHomeDelivery, ARTRefillOption.PE_HOME_DELIVERY);
      ARTRefillOption deserializedValueVHW = ARTRefillOption.values[2];
      expect(deserializedValueVHW, ARTRefillOption.VHW);
      ARTRefillOption deserializedValueTreatmentBuddy = ARTRefillOption.values[3];
      expect(deserializedValueTreatmentBuddy, ARTRefillOption.TREATMENT_BUDDY);
      ARTRefillOption deserializedValueCAC = ARTRefillOption.values[4];
      expect(deserializedValueCAC, ARTRefillOption.COMMUNITY_ADHERENCE_CLUB);
    });

    test('AdherenceReminderFrequency serialization', () {
      int serializedValueDaily = AdherenceReminderFrequency.DAILY.index;
      expect(serializedValueDaily, 0);
      int serializedValueWeekly = AdherenceReminderFrequency.WEEKLY.index;
      expect(serializedValueWeekly, 1);
      int serializedValueMonthly = AdherenceReminderFrequency.MONTHLY.index;
      expect(serializedValueMonthly, 2);
    });

    test('AdherenceReminderFrequency deserialization', () {
      AdherenceReminderFrequency deserializedValueDaily = AdherenceReminderFrequency.values[0];
      expect(deserializedValueDaily, AdherenceReminderFrequency.DAILY);
      AdherenceReminderFrequency deserializedValueWeekly = AdherenceReminderFrequency.values[1];
      expect(deserializedValueWeekly, AdherenceReminderFrequency.WEEKLY);
      AdherenceReminderFrequency deserializedValueMonthly = AdherenceReminderFrequency.values[2];
      expect(deserializedValueMonthly, AdherenceReminderFrequency.MONTHLY);
    });

  });
}