
class RequiredAction {
  static final tableName = 'RequiredAction';

  // column names
  static final colId = 'id'; // primary key
  static final colCreatedDate = 'created_date_utc';
  static final colPatientART = 'patient_art'; // foreign key to [Patient].art_number
  static final colType = 'action_type';
  static final colDescription = 'description';

  DateTime _createdDate;
  String patientART;
  RequiredActionType type;
  String description;

  // Constructors
  // ------------

  RequiredAction(this.patientART, this.type, this.description);

  RequiredAction.fromMap(map) {
    this._createdDate = DateTime.parse(map[colCreatedDate]);
    this.patientART = map[colPatientART];
    this.type = RequiredActionType.values[map[colType]];
    this.description = map[colDescription];
  }


  // Other
  // -----

  toMap() {
    var map = Map<String, dynamic>();
    map[colCreatedDate] = _createdDate.toIso8601String();
    map[colPatientART] = patientART;
    map[colType] = type.index;
    map[colDescription] = description;
    return map;
  }

  /// Do not set the createdDate manually! The DatabaseProvider sets the date
  /// automatically on inserts into database.
  // ignore: unnecessary_getters_setters
  set createdDate(DateTime date) => _createdDate = date;

  // ignore: unnecessary_getters_setters
  DateTime get createdDate => _createdDate;

}

// Do not change the order as the index of each item is used to persist in the
// database. If a new type should be added, add it at the end of this enum list.
enum RequiredActionType {
  REFILL_REQUIRED,
  ASSESSMENT_REQUIRED,
  ENDPOINT_SURVEY_REQUIRED,
  NOTIFICATIONS_UPLOAD_REQUIRED,
  ART_REFILL_DATE_UPLOAD_REQUIRED
}
