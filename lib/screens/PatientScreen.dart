import 'package:flutter/material.dart';
import 'package:pebrapp/components/SizedButton.dart';
import 'package:pebrapp/screens/PreferenceAssessmentScreen.dart';

class PatientScreen extends StatelessWidget {
  final _patientId;

  PatientScreen(this._patientId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 224, 224, 224),
        appBar: AppBar(
          title: Text('Patient ${this._patientId}'),
        ),
        body: Center(child: PatientScreenBody(context, _patientId)));
  }
}

class PatientScreenBody extends StatelessWidget {
  final _tableRowPaddingVertical = 5.0;
  final BuildContext _context;
  final String _patientART;

  PatientScreenBody(BuildContext this._context, String this._patientART);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _buildTitle('Patient Characteristics'),
        _buildPatientCharacteristicsCard(),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [SizedButton('Edit Characteristics')]),
        _buildTitle('Preferences'),
        _buildPreferencesCard(),
        Center(child: _buildTitle('Next Preference Assessment')),
        Center(child: Text('Today')),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [SizedButton('Start Assessment', onPressed: () { _pushPreferenceAssessmentScreen(_context, _patientART); })]),
        Center(child: _buildTitle('Next ART Refill')),
        Center(child: Text('02.02.2019')),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [SizedButton('Manage Refill')]),
        Container(height: 50), // padding at bottom
      ],
    );
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
                      child: Text('Abele')),
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
                        child: Text('Maseru'))),
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
                      child: Text('+266 57 123 456')),
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
