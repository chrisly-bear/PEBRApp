
class ARTRefill {
  static final tableName = 'ARTRefill';

  // column names
  static final colId = 'id'; // primary key
  static final colPatientART = 'patient_art'; // foreign key to [Patient].art_number
  static final colCreatedDate = 'created_date_utc';
  static final colRefillType = 'refill_type';
  static final colNextRefillDate = 'next_refill_date_utc'; // nullable
  static final colNotDoneReason = 'not_done_reason'; // nullable
  static final colOtherClinicLesotho = 'other_clinic_lesotho'; // nullable
  static final colOtherClinicSouthAfrica = 'other_clinic_south_africa'; // nullable
  static final colNotTakingARTReason = 'not_taking_art_reason'; // nullable

  String patientART;
  DateTime _createdDate;
  RefillType _refillType;
  DateTime nextRefillDate;
  ARTRefillNotDoneReason notDoneReason;
  String otherClinicLesotho;
  String otherClinicSouthAfrica;
  String notTakingARTReason;


  // Constructors
  // ------------

  ARTRefill(
      this.patientART,
      this._refillType,
      {
        this.nextRefillDate,
        this.notDoneReason,
        this.otherClinicLesotho,
        this.otherClinicSouthAfrica,
        this.notTakingARTReason,
      });

  ARTRefill.uninitialized();

  ARTRefill.fromMap(map) {
    this.patientART = map[colPatientART];
    this.createdDate = DateTime.parse(map[colCreatedDate]);
    this._refillType = map[colRefillType] == null ? null : RefillType.values[map[colRefillType]];
    this.nextRefillDate = map[colNextRefillDate] == null ? null : DateTime.parse(map[colNextRefillDate]);
    this.notDoneReason = map[colNotDoneReason] == null ? null : ARTRefillNotDoneReason.values[map[colNotDoneReason]];
    this.otherClinicLesotho = map[colOtherClinicLesotho];
    this.otherClinicSouthAfrica = map[colOtherClinicSouthAfrica];
    this.notTakingARTReason = map[colNotTakingARTReason];
  }

  toMap() {
    var map = Map<String, dynamic>();
    map[colPatientART] = patientART;
    map[colCreatedDate] = createdDate.toIso8601String();
    map[colRefillType] = _refillType.index;
    map[colNextRefillDate] = nextRefillDate.toIso8601String();
    map[colNotDoneReason] = notDoneReason.index;
    map[colOtherClinicLesotho] = otherClinicLesotho;
    map[colOtherClinicSouthAfrica] = otherClinicSouthAfrica;
    map[colNotTakingARTReason] = notTakingARTReason;
    return map;
  }

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  set createdDate(DateTime date) => this._createdDate = date;

  DateTime get createdDate => this._createdDate;

}


// Do not change the order of the enums as their index is used to store the instance in the database!
enum RefillType { DONE, NOT_DONE, CHANGE_DATE }

// Do not change the order of the enums as their index is used to store the instance in the database!
enum ARTRefillNotDoneReason { PATIENT_DIED, PATIENT_HOSPITALIZED, ART_FROM_OTHER_CLINIC_LESOTHO, ART_FROM_OTHER_CLINIC_SA, NOT_TAKING_ART_ANYMORE, STOCK_OUT_OR_FAILED_DELIVERY }
