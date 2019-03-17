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

    test('SupportPreference serialization', () {
      int serializedValueSCC = SupportPreference.SATURDAY_CLINIC_CLUB.index;
      expect(serializedValueSCC, 0);
      int serializedValueCYC = SupportPreference.COMMUNITY_YOUTH_CLUB.index;
      expect(serializedValueCYC, 1);
      int serializedValuePhoneCallPE = SupportPreference.PHONE_CALL_PE.index;
      expect(serializedValuePhoneCallPE, 2);
      int serializedValueHomeVisitPE = SupportPreference.HOME_VISIT_PE.index;
      expect(serializedValueHomeVisitPE, 3);
      int serializedValueNurseAtClinic = SupportPreference.NURSE_AT_CLINIC.index;
      expect(serializedValueNurseAtClinic, 4);
    });

    test('SupportPreference serialization', () {
      SupportPreference deserializedValueSCC = SupportPreference.values[0];
      expect(deserializedValueSCC, SupportPreference.SATURDAY_CLINIC_CLUB);
      SupportPreference deserializedValueCYC = SupportPreference.values[1];
      expect(deserializedValueCYC, SupportPreference.COMMUNITY_YOUTH_CLUB);
      SupportPreference deserializedValuePhoneCallPE = SupportPreference.values[2];
      expect(deserializedValuePhoneCallPE, SupportPreference.PHONE_CALL_PE);
      SupportPreference deserializedValueHomeVisitPE = SupportPreference.values[3];
      expect(deserializedValueHomeVisitPE, SupportPreference.HOME_VISIT_PE);
      SupportPreference deserializedValueNurseAtClinic = SupportPreference.values[4];
      expect(deserializedValueNurseAtClinic, SupportPreference.NURSE_AT_CLINIC);
    });

  });
}