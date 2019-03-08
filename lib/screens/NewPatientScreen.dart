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
                  } else {
                    print('Validation successful');
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
            ],
          ),
        ),
      ),
    );
  }

  _onSubmitForm() {
    // Validate will return true if the form is valid, or false if
    // the form is invalid.
    if (_formKey.currentState.validate()) {
      // If the form is valid, we want to show a Snackbar
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Creating new patient')));

      final newPatient = Patient(_artNumberCtr.text, _districtCtr.text, _phoneNumberCtr.text, _villageCtr.text);
      print('NEW PATIENT: ${newPatient.toMap()}');
      // await DatabaseProvider.db.insertPatient(newPatient);
      DatabaseProvider.db.insertPatient(newPatient).then((dynamic) => print('THEN'));
      print('patient stored in database');
      Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('New patient created successfully')));

    }
  }
}
