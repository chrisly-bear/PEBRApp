import 'package:flutter_test/flutter_test.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/beans/Gender.dart';
import 'package:pebrapp/utils/VisibleImpactUtils.dart';

void main() {
  test('Match found', () {
    final List<dynamic> patients = [
      {
        "patient_id": 2,
        "is_duplicate": false,
        "art_number": "B/01/11111",
        "birth_date": "1996-09-12",
        "sex": "M",
        "patient_status": "active",
        "patient_status_date": "2019-09-12",
        "mobile_phone": "+26657123456",
        "mobile_owner": "patient",
        "first_cd4_date": "2009-11-02",
        "first_cd4_result": 548,
        "last_treatment_switch": "2018-10-26",
        "labdata_checksum": "e85a0e73089b0c5affca563b4b0a3f6e"
      },
      {
        "patient_id": 4,
        "is_duplicate": false,
        "art_number": "B/01/11111",
        "birth_date": "1994-09-27",
        "sex": "M",
        "patient_status": "active",
        "patient_status_date": "2019-09-12",
        "mobile_phone": "+26657683501",
        "mobile_owner": null,
        "first_cd4_date": "2014-04-16",
        "first_cd4_result": 204,
        "last_treatment_switch": "2018-10-26",
        "labdata_checksum": "9fdaa3e53acc10b50e2493d33523e518"
      },
      {
        "patient_id": 5,
        "is_duplicate": false,
        "art_number": "B\/01\/11223",
        "birth_date": "1995-08-08",
        "sex": "M",
        "patient_status": "active",
        "patient_status_date": "2019-09-12",
        "mobile_phone": null,
        "mobile_owner": null,
        "first_cd4_date": "2014-04-24",
        "first_cd4_result": 337,
        "last_treatment_switch": "2018-10-27",
        "labdata_checksum": "eda8d7e9970e206b24e7346269a8671f"
      }
    ];

    final Patient patient = Patient(
        artNumber: "B/01/11111",
        birthday: DateTime(1994, 9, 27),
        gender: Gender.MALE(),
        phoneNumber: "+266-57-683-501");
    final dynamic p = getMatchingPatient(patients, patient);
    expect(p['art_number'], patient.artNumber);
  });

  test('No Match found', () {
    final List<dynamic> patients = [
      {
        "patient_id": 2,
        "is_duplicate": false,
        "art_number": "B/01/11111",
        "birth_date": "1994-09-12",
        "sex": "M",
        "patient_status": "active",
        "patient_status_date": "2019-09-12",
        "mobile_phone": "+26657123456",
        "mobile_owner": "patient",
        "first_cd4_date": "2009-11-02",
        "first_cd4_result": 548,
        "last_treatment_switch": "2018-10-26",
        "labdata_checksum": "e85a0e73089b0c5affca563b4b0a3f6e"
      },
      {
        "patient_id": 4,
        "is_duplicate": false,
        "art_number": "B/01/11111",
        "birth_date": "1994-09-27",
        "sex": "M",
        "patient_status": "active",
        "patient_status_date": "2019-09-12",
        "mobile_phone": "+26657683501",
        "mobile_owner": null,
        "first_cd4_date": "2014-04-16",
        "first_cd4_result": 204,
        "last_treatment_switch": "2018-10-26",
        "labdata_checksum": "9fdaa3e53acc10b50e2493d33523e518"
      },
      {
        "patient_id": 5,
        "is_duplicate": false,
        "art_number": "B\/01\/11223",
        "birth_date": "1994-08-08",
        "sex": "M",
        "patient_status": "active",
        "patient_status_date": "2019-09-12",
        "mobile_phone": null,
        "mobile_owner": null,
        "first_cd4_date": "2014-04-24",
        "first_cd4_result": 337,
        "last_treatment_switch": "2018-10-27",
        "labdata_checksum": "eda8d7e9970e206b24e7346269a8671f"
      }
    ];

    final Patient patient = Patient(
        artNumber: "B/01/22222",
        birthday: DateTime(1994, 8, 11),
        gender: Gender.FEMALE(),
        phoneNumber: "+266-56-543-501");
    final dynamic p = getMatchingPatient(patients, patient);
    expect(p, null);
  });
}
