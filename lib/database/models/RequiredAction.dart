class RequiredAction {
  static final tableName = 'RequiredAction';

  // column names
  static final colId = 'id'; // primary key
  static final colCreatedDate = 'created_date';
  static final colPatientART =
      'patient_art'; // foreign key to [Patient].art_number
  static final colType = 'action_type';
  static final colDueDate = 'due_date';

  DateTime _createdDate;
  String patientART;
  RequiredActionType type;
  DateTime dueDate;

  // Constructors
  // ------------

  RequiredAction(this.patientART, this.type, this.dueDate);

  RequiredAction.fromMap(map) {
    this._createdDate = DateTime.parse(map[colCreatedDate]);
    this.patientART = map[colPatientART];
    this.type = RequiredActionType.values[map[colType]];
    this.dueDate = DateTime.parse(map[colDueDate]);
  }

  // Other
  // -----

  // override the equality operator
  // we deliberately define RequiredActions to be equal if they belong to the
  // same patient and are of the same type, we ignore different dueDates
  // because we don't want to allow for duplicates of the same type (e.g. if
  // there are several entries of NOTIFICATIONS_UPLOAD_REQUIRED we only want to
  // require an upload from the user once and not display several such actions)
  @override
  bool operator ==(o) =>
      o is RequiredAction &&
      o.patientART == this.patientART &&
      o.type == this.type;

  // override hashcode
  @override
  int get hashCode => patientART.hashCode ^ type.hashCode;

  toMap() {
    var map = Map<String, dynamic>();
    map[colCreatedDate] = _createdDate.toIso8601String();
    map[colPatientART] = patientART;
    map[colType] = type.index;
    map[colDueDate] = dueDate.toIso8601String();
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
  NOTIFICATIONS_UPLOAD_REQUIRED,
  PATIENT_CHARACTERISTICS_UPLOAD_REQUIRED,
  VIRAL_LOAD_MEASUREMENT_REQUIRED,
  VIRAL_LOAD_DISCREPANCY_WARNING,
  ADHERENCE_QUESTIONNAIRE_2P5M_REQUIRED,
  ADHERENCE_QUESTIONNAIRE_5M_REQUIRED,
  ADHERENCE_QUESTIONNAIRE_9M_REQUIRED,
  QUALITY_OF_LIFE_QUESTIONNAIRE_5M_REQUIRED,
  QUALITY_OF_LIFE_QUESTIONNAIRE_9M_REQUIRED,
  VIRAL_LOAD_9M_REQUIRED,
  PATIENT_STATUS_UPLOAD_REQUIRED
}
