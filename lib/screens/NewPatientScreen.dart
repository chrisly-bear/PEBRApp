import 'package:flutter/material.dart';
import 'package:pebrapp/components/SizedButton.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/Patient.dart';

class NewPatientScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 224, 224, 224),
        appBar: AppBar(
          title: const Text('New Patient'),
        ),
        body: Center(
          child: NewPatientScreenBody(),
        ));
  }
}

class NewPatientScreenBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NewPatientForm();
  }
}

// https://flutter.dev/docs/cookbook/forms/validation
class NewPatientForm extends StatefulWidget {
  @override
  NewPatientFormState createState() {
    return NewPatientFormState();
  }
}

class NewPatientFormState extends State<NewPatientForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a `GlobalKey<FormState>`, not a GlobalKey<MyCustomFormState>!
  final _formKey = GlobalKey<FormState>();
  
  var _artNumberCtr = TextEditingController();
  var _villageCtr = TextEditingController();
  var _districtCtr = TextEditingController();
  var _phoneNumberCtr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey we created above
    return Form(
      key: _formKey,
      child: Card(
        margin: EdgeInsets.all(20),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('ART Number'),
              TextFormField(
                controller: _artNumberCtr,
                validator: (value) {
                  if (value.isEmpty) {
                    print('Validation failed');
                    return 'Please enter an ART number';
                  }
                },
              ),
              Text('Village'),
              TextFormField(
                controller: _villageCtr,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter an village';
                  }
                },
              ),
              Text('District'),
              TextFormField(
                controller: _districtCtr,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a district';
                  }
                },
              ),
              Text('Phone Number'),
              TextFormField(
                controller: _phoneNumberCtr,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: SizedButton(
                    'Save',
                    onPressed: _onSubmitForm,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: SizedButton(
                    'Get DB Info',
                    onPressed: _getDBInfo,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: SizedButton(
                    'Get All Patients',
                    onPressed: _getAllPatients,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _onSubmitForm() async {
    // Validate will return true if the form is valid, or false if the form is invalid.
    if (_formKey.currentState.validate()) {
      final newPatient = Patient(_artNumberCtr.text, _districtCtr.text, _phoneNumberCtr.text, _villageCtr.text);
      print('NEW PATIENT (_id will be given by SQLite database):\n$newPatient');
      await DatabaseProvider.db.insertPatient(newPatient);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          'New patient created successfully',
          textAlign: TextAlign.center,
          )
        )
      );
    }
  }

  _getDBInfo() async {
    final columns = await DatabaseProvider.db.getTableInfo(Patient.tableName); 
    print('### TABLE \'${Patient.tableName}\' INFO <START> ###');
    for (final column in columns) {
      print(column);
    }
    print('### TABLE \'${Patient.tableName}\' INFO <END> ###');
  }

  _getAllPatients() async {
    final List<Patient> patients = await DatabaseProvider.db.retrievePatients();
    if (patients.length == 0) { print('No patients in Patient table'); }
    for (final patient in patients) {
      print(patient);
    }
  }

}
