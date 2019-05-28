import 'package:flutter_test/flutter_test.dart';
import 'package:pebrapp/database/beans/SupportPreferencesSelection.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';

void main() {
  group('SupportPreferencesSelection', () {

    test('serialization', () {
      var sps = SupportPreferencesSelection();
      sps.NURSE_CLINIC_selected = true;
      sps.SATURDAY_CLINIC_CLUB_selected = false;
      sps.HOME_VISIT_PE_selected = true;
      sps.PHONE_CALL_PE_selected = false;
      sps.COMMUNITY_YOUTH_CLUB_selected = true;
      sps.SCHOOL_VISIT_PE_selected = false;

      final json = sps.serializeToJSON();
      final expectedJson = '[1,3,5]';
      expect(json, expectedJson);
    });

    test('deserialization', () {
      final json = '[1,3,5]';
      final sps = SupportPreferencesSelection.deserializeFromJSON(json);

      expect(sps.NURSE_CLINIC_selected, true);
      expect(sps.SATURDAY_CLINIC_CLUB_selected, false);
      expect(sps.HOME_VISIT_PE_selected, true);
      expect(sps.PHONE_CALL_PE_selected, false);
      expect(sps.COMMUNITY_YOUTH_CLUB_selected, true);
      expect(sps.SCHOOL_VISIT_PE_selected, false);
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