import 'package:flutter/material.dart';
import 'package:pebrapp/components/SizedButton.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/screens/NewOrEditPatientScreen.dart';
import 'package:pebrapp/screens/PreferenceAssessmentScreen.dart';

class PatientScreen extends StatelessWidget {
  final Patient _patient;

  PatientScreen(this._patient);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 224, 224, 224),
        appBar: AppBar(
          title: Text('Patient ${this._patient.artNumber}'),
        ),
        body: Center(child: _PatientScreenBody(context, _patient)));
  }
}

class _PatientScreenBody extends StatefulWidget {
  final BuildContext _context;
  final Patient _patient;

  _PatientScreenBody(this._context, this._patient);

  @override
  createState() => _PatientScreenBodyState(_context, _patient);
}

class _PatientScreenBodyState extends State<_PatientScreenBody> {
  final _tableRowPaddingVertical = 5.0;
  final BuildContext _context;
  Patient _patient;

  _PatientScreenBodyState(this._context, this._patient);
  
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _buildTitle('Patient Characteristics'),
        _buildPatientCharacteristicsCard(),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [SizedButton('Edit Characteristics', onPressed: () { _pushEditPatientScreen(_patient); })]),
        _buildTitle('Preferences'),
        _buildPreferencesCard(),
        Center(child: _buildTitle('Next Preference Assessment')),
        Center(child: Text('Today')),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [SizedButton('Start Assessment', onPressed: () { _pushPreferenceAssessmentScreen(_context, _patient.artNumber); })]),
        Center(child: _buildTitle('Next ART Refill')),
        Center(child: Text('02.02.2019')),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [SizedButton('Manage Refill')]),
        Container(height: 50), // padding at bottom
      ],
    );
  }

  void _pushEditPatientScreen(Patient patient) async {
    Patient newPatient = await Navigator.of(_context).push(
      new MaterialPageRoute<Patient>(
        builder: (BuildContext context) {
          return NewOrEditPatientScreen(existingPatient: patient);
        },
      ),
    );
    if (newPatient != null) {
      setState(() {
        this._patient = newPatient;
      });
    }
  }

  _buildTitle(String title) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  _buildPatientCharacteristicsCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Table(
            children: [
              TableRow(children: [
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: _tableRowPaddingVertical),
                    child: Text('Village'),
                  ),
                ),
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _tableRowPaddingVertical),
                      child: Text(_patient.village)),
                ),
              ]),
              TableRow(children: [
                TableCell(
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: _tableRowPaddingVertical),
                        child: Text('District'))),
                TableCell(
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: _tableRowPaddingVertical),
                        child: Text(_patient.district))),
              ]),
              TableRow(children: [
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _tableRowPaddingVertical),
                      child: Text('Phone Number')),
                ),
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _tableRowPaddingVertical),
                      child: Text(_patient.phoneNumber)),
                ),
              ]),
            ],
          )),
    );
  }

  _buildPreferencesCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Table(
            children: [
              TableRow(children: [
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: _tableRowPaddingVertical),
                    child: Text('ART Refill'),
                  ),
                ),
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _tableRowPaddingVertical),
                      child: Text('VHW')),
                ),
              ]),
              TableRow(children: [
                TableCell(
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: _tableRowPaddingVertical),
                        child: Text('Weekly Notification Message'))),
                TableCell(
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: _tableRowPaddingVertical),
                        child: Text('—'))),
              ]),
              TableRow(children: [
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _tableRowPaddingVertical),
                      child: Text('Weekly Notification Time')),
                ),
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _tableRowPaddingVertical),
                      child: Text('—')),
                ),
              ]),
              TableRow(children: [
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _tableRowPaddingVertical),
                      child: Text('Viral Load Message (suppressed)')),
                ),
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _tableRowPaddingVertical),
                      child: Text('You rock!')),
                ),
              ]),
              TableRow(children: [
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _tableRowPaddingVertical),
                      child: Text('Viral Load Message (unsuppressed)')),
                ),
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _tableRowPaddingVertical),
                      child: Text(':(')),
                ),
              ]),
              TableRow(children: [
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _tableRowPaddingVertical),
                      child: Text('Support')),
                ),
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: _tableRowPaddingVertical),
                    child: Table(columnWidths: {
                      0: FixedColumnWidth(250.0),
                      // 0: IntrinsicColumnWidth(),
                      // 1: FixedColumnWidth(250.0),
                    }, children: [

                      TableRow(children: [
                        TableCell(
                          child: CheckboxListTile(
                            // secondary: const Icon(Icons.home),
                            title: Text('Home Visit PE'),
                            dense: true,
                            value: false,
                            onChanged: (bool newState) {
                              print('Checkbox clicked: $newState');
                            },
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Text(''),
                        ),
                      ]),

                      TableRow(children: [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: CheckboxListTile(
                            // secondary: const Icon(Icons.local_hospital),
                            title: Text(
                              'Nurse at Clinic',
                              style: TextStyle(
                                  decoration: TextDecoration.lineThrough),
                            ),
                            dense: true,
                            value: true,
                            onChanged: (bool newState) {
                              print('Checkbox clicked: $newState');
                            },
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Text('done on 04.02.2019'),
                        ),
                      ]),

                    ]),
                  ),
                ),
              ]),
              TableRow(children: [
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _tableRowPaddingVertical),
                      child: Text('EAC')),
                ),
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _tableRowPaddingVertical),
                      child: Text('Nurse at Clinic')),
                ),
              ]),
            ],
          )),
    );
  }

  void _pushPreferenceAssessmentScreen(BuildContext context, String patientART) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return PreferenceAssessmentScreen(patientART);
        },
      ),
    );
  }

}
