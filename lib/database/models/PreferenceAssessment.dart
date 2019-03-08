
class PreferenceAssessment {
  static final tableName = 'PreferenceAssessment';

  // column names
  static final colId = 'id';
  static final colPatient = 'patient';
  static final colCreatedDate = 'created_date';

  int _id; // primary key
  int _patient; // foreign key to [Patient] model
  DateTime _createdDate;

  PreferenceAssessment() {
    this._createdDate = DateTime.now();
  }

  PreferenceAssessment.fromMap(map) {
    this._id = map[colId];
    this._patient = map[colPatient];
    this._createdDate = DateTime.fromMillisecondsSinceEpoch(map[colCreatedDate]);
  }

  toMap() {
    var map = {};
    map[colPatient] = _patient;
    map[colCreatedDate] = _createdDate.millisecondsSinceEpoch;
    if (_id != null) {
      map[colId] = _id;
    }
    return map;
  }

}