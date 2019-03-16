import 'package:flutter/material.dart';
import 'package:pebrapp/components/SizedButton.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return Column(children: [
      Expanded(child: SingleChildScrollView(child: NewPatientForm())),
    ]);
  }
}

// https://flutter.dev/docs/cookbook/forms/validation
class NewPatientForm extends StatefulWidget {
  @override
  _NewPatientFormState createState() {
    return _NewPatientFormState();
  }
}

class _NewPatientFormState extends State<NewPatientForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  final _formKey = GlobalKey<FormState>();

  var _artNumberCtr = TextEditingController();
  var _villageCtr = TextEditingController();
  var _districtCtr = TextEditingController();
  var _phoneNumberCtr = TextEditingController();

  List<String> _artNumbersInDB;
  bool get _isLoading { return _artNumbersInDB == null; }

  @override
  initState() {
    print('~~~ initState');
    super.initState();
    DatabaseProvider().retrievePatientsART().then((artNumbers) {
      setState(() {
        _artNumbersInDB = artNumbers;
      });
    });
  }

  @override
  void didUpdateWidget(NewPatientForm oldWidget) {
    print('~~~ didUpdateWidget');
    super.didUpdateWidget(oldWidget);
  }

  @override
  void reassemble() {
    print('~~~ reassemble');
    super.reassemble();
  }

  @override
  void didChangeDependencies() {
    print('~~~ didChangeDependencies');
    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    print('~~~ deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('~~~ dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('~~~ build');
    // Build a Form widget using the _formKey we created above
    return Form(
      key: _formKey,
      child: Column(children: [
        Card(
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
                      print('ART validation failed');
                      return 'Please enter an ART number';
                    } else if (_artNumberExists(value)) {
                      print('ART validation failed');
                      return 'This ART number exists already in the database';
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
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: SizedButton(
              'Save',
              onPressed: _isLoading ? null : _onSubmitForm,
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: SizedButton(
              'Open KoBoCollect',
              onPressed: _openKoBoCollect,
            ),
          ),
        ),
      ]),
    );
  }

  _openKoBoCollect() async {
    const appUrl = 'android-app://org.koboc.collect.android';
    const marketUrl = 'market://details?id=org.koboc.collect.android';
    if (await canLaunch(appUrl)) {
      await launch(appUrl);
    } else if (await canLaunch(marketUrl)) {
      await launch(marketUrl);
    } else {
      showFlushBar(context, "Could not finde KoBoCollect app. Make sure KoBoCollect is installed.");
    }
  }

  _onSubmitForm() async {
    // Validate will return true if the form is valid, or false if the form is invalid.
    if (_formKey.currentState.validate()) {
      final newPatient = Patient(_artNumberCtr.text, _districtCtr.text, _phoneNumberCtr.text, _villageCtr.text);
      print('NEW PATIENT (_id will be given by SQLite database):\n$newPatient');
      await DatabaseProvider().insertPatient(newPatient);
      Navigator.of(context).pop(); // close New Patient screen
      showFlushBar(context, 'New patient created successfully');
    }
  }

  _getDBInfo() async {
    final columns = await DatabaseProvider().getTableInfo(Patient.tableName);
    print('### TABLE \'${Patient.tableName}\' INFO <START> ###');
    for (final column in columns) {
      print(column);
    }
    print('### TABLE \'${Patient.tableName}\' INFO <END> ###');
  }

  _getAllPatients() async {
    final List<Patient> patients = await DatabaseProvider().retrievePatients();
    if (patients.length == 0) { print('No patients in Patient table'); }
    for (final patient in patients) {
      print(patient);
    }
    showFlushBar(context, "${patients.length} patients in database");
  }

  bool _artNumberExists(artNumber) {
    return _artNumbersInDB.contains(artNumber);
  }

}
