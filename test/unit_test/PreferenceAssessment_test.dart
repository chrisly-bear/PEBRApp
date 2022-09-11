import 'package:flutter_test/flutter_test.dart';
import 'package:pebrapp/database/beans/ARTRefillOption.dart';
import 'package:pebrapp/database/beans/AdherenceReminderFrequency.dart';
import 'package:pebrapp/database/beans/SupportPreferencesSelection.dart';

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

    test('serialization with None', () {
      var sps = SupportPreferencesSelection();
      sps.deselectAll();
      final json = sps.serializeToJSON();
      final expectedJson = '[]';
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

    test('deserialization with None', () {
      final json = '[]';
      final sps = SupportPreferencesSelection.deserializeFromJSON(json);
      expect(sps.areAllDeselected, true);
    });

    test('excel formatting', () {
      var sps = SupportPreferencesSelection();
      sps.NURSE_CLINIC_selected = true;
      sps.SATURDAY_CLINIC_CLUB_selected = false;
      sps.HOME_VISIT_PE_selected = true;
      sps.PHONE_CALL_PE_selected = false;
      sps.COMMUNITY_YOUTH_CLUB_selected = true;
      sps.SCHOOL_VISIT_PE_selected = false;

      final excelString = sps.toExcelString();
      final expected = '1, 3, 5';
      expect(excelString, expected);
    });

    test('excel formatting with None option', () {
      var sps = SupportPreferencesSelection();
      final excelString = sps.toExcelString();
      final expected = '14';
      expect(excelString, expected);
    });

    test('excel formatting with None option and some deselected', () {
      var sps = SupportPreferencesSelection();
      sps.NURSE_CLINIC_selected = false;
      sps.SATURDAY_CLINIC_CLUB_selected = false;
      sps.HOME_VISIT_PE_selected = false;
      sps.PHONE_CALL_PE_selected = false;
      sps.COMMUNITY_YOUTH_CLUB_selected = false;
      sps.SCHOOL_VISIT_PE_selected = false;

      final excelString = sps.toExcelString();
      final expected = '14';
      expect(excelString, expected);
    });
  });

  group('Enums', () {
    test('ARTRefillOption serialization', () {
      int serializedValueClinic = ARTRefillOption.CLINIC().code;
      expect(serializedValueClinic, 1);
      int serializedValuePEHomeDelivery =
          ARTRefillOption.PE_HOME_DELIVERY().code;
      expect(serializedValuePEHomeDelivery, 2);
      int serializedValueVHW = ARTRefillOption.VHW().code;
      expect(serializedValueVHW, 3);
      int serializedValueCAC = ARTRefillOption.COMMUNITY_ADHERENCE_CLUB().code;
      expect(serializedValueCAC, 4);
      int serializedValueTreatmentBuddy =
          ARTRefillOption.TREATMENT_BUDDY().code;
      expect(serializedValueTreatmentBuddy, 5);
    });

    test('ARTRefillOption deserialization', () {
      ARTRefillOption deserializedValueClinic = ARTRefillOption.fromCode(1);
      expect(deserializedValueClinic, ARTRefillOption.CLINIC());
      ARTRefillOption deserializedValuePEHomeDelivery =
          ARTRefillOption.fromCode(2);
      expect(
          deserializedValuePEHomeDelivery, ARTRefillOption.PE_HOME_DELIVERY());
      ARTRefillOption deserializedValueVHW = ARTRefillOption.fromCode(3);
      expect(deserializedValueVHW, ARTRefillOption.VHW());
      ARTRefillOption deserializedValueCAC = ARTRefillOption.fromCode(4);
      expect(deserializedValueCAC, ARTRefillOption.COMMUNITY_ADHERENCE_CLUB());
      ARTRefillOption deserializedValueTreatmentBuddy =
          ARTRefillOption.fromCode(5);
      expect(
          deserializedValueTreatmentBuddy, ARTRefillOption.TREATMENT_BUDDY());
    });

    test('AdherenceReminderFrequency serialization', () {
      int serializedValueDaily = AdherenceReminderFrequency.DAILY().code;
      expect(serializedValueDaily, 1);
      int serializedValueWeekly = AdherenceReminderFrequency.WEEKLY().code;
      expect(serializedValueWeekly, 2);
      int serializedValueMonthly = AdherenceReminderFrequency.MONTHLY().code;
      expect(serializedValueMonthly, 3);
    });

    test('AdherenceReminderFrequency deserialization', () {
      AdherenceReminderFrequency deserializedValueDaily =
          AdherenceReminderFrequency.fromCode(1);
      expect(deserializedValueDaily, AdherenceReminderFrequency.DAILY());
      AdherenceReminderFrequency deserializedValueWeekly =
          AdherenceReminderFrequency.fromCode(2);
      expect(deserializedValueWeekly, AdherenceReminderFrequency.WEEKLY());
      AdherenceReminderFrequency deserializedValueMonthly =
          AdherenceReminderFrequency.fromCode(3);
      expect(deserializedValueMonthly, AdherenceReminderFrequency.MONTHLY());
    });
  });
}
