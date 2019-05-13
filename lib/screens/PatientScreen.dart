import 'package:flutter/material.dart';
import 'package:pebrapp/components/SizedButton.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/screens/ARTRefillScreen.dart';
import 'package:pebrapp/screens/NewOrEditPatientScreen.dart';
import 'package:pebrapp/screens/PreferenceAssessmentScreen.dart';
import 'package:pebrapp/utils/Utils.dart';

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
  String _nextAssessmentText = '—';
  String _nextRefillText = '—';

  _PatientScreenBodyState(this._context, this._patient);
  
  @override
  Widget build(BuildContext context) {

    DateTime lastAssessmentDate = _patient.latestPreferenceAssessment?.createdDate;
    if (lastAssessmentDate != null) {
      DateTime nextAssessmentDate = calculateNextAssessment(lastAssessmentDate);
      _nextAssessmentText = formatDate(nextAssessmentDate);
    }

    DateTime nextRefillDate = _patient.latestARTRefill?.nextRefillDate;
    if (nextRefillDate != null) {
      _nextRefillText = formatDate(nextRefillDate);
    } else {
      _nextRefillText = '—';
    }

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
        Center(child: Text(_nextAssessmentText)),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [SizedButton('Start Assessment', onPressed: () { _pushPreferenceAssessmentScreen(_context, _patient.artNumber); })]),
        Center(child: _buildTitle('Next ART Refill')),
        Center(child: Text(_nextRefillText)),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [SizedButton('Manage Refill', onPressed: () { _pushARTRefillScreen(_context, _patient, _nextRefillText); })]),
        Container(height: 50), // padding at bottom
      ],
    );
  }

  void _pushEditPatientScreen(Patient patient) {
    Navigator.of(_context).push(
      new MaterialPageRoute<Patient>(
        builder: (BuildContext context) {
          return NewOrEditPatientScreen(existingPatient: patient);
        },
      ),
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

    _buildARTRefillText() {
      String text = artRefillOptionToString(_patient.latestPreferenceAssessment.artRefillOption1);
      return Text(text);
    }

    _buildAdherenceReminderMessageText() {
      AdherenceReminderMessage message = _patient.latestPreferenceAssessment.adherenceReminderMessage;
      String text = message == null ? '—' : adherenceReminderMessageToString(message);
      return Text(text);
    }

    _buildAdherenceReminderFrequencyText() {
      final AdherenceReminderFrequency freq = _patient.latestPreferenceAssessment.adherenceReminderFrequency;
      String text = freq == null ? '—' : adherenceReminderFrequencyToString(freq);
      return Text(text);
    }

    _buildAdherenceReminderTimeText() {
      String text = _patient.latestPreferenceAssessment.adherenceReminderTime ?? '—';
      return Text(text);
    }

    _buildVLMessageSuppressedText() {
      VLSuppressedMessage message = _patient.latestPreferenceAssessment.vlNotificationMessageSuppressed;
      String text = message == null ? '—' : vlSuppressedMessageToString(message);
      return Text(text);
    }

    _buildVLMessageUnsuppressedText() {
      VLUnsuppressedMessage message = _patient.latestPreferenceAssessment.vlNotificationMessageUnsuppressed;
      String text = message == null ? '—' : vlUnsuppressedMessageToString(message);
      return Text(text);
    }

    TableRow _buildSupportOption(String title) {
      return TableRow(children: [
        TableCell(
          child: CheckboxListTile(
            // secondary: const Icon(Icons.home),
            title: Text(title),
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
      ]);
    }

    _buildSupportOptions() {
      final SupportPreferencesSelection sps = _patient.latestPreferenceAssessment.supportPreferences;
      if (sps.areAllDeselected) {
        return Text('—');
      }
      List<TableRow> supportOptions = List<TableRow>();
      if (sps.saturdayClinicClubSelected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.saturdayClinicClubDescription));
      }
      if (sps.communityYouthClubSelected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.communityYouthClubDescription));
      }
      if (sps.phoneCallPESelected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.phoneCallPEDescription));
      }
      if (sps.homeVisitPESelected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.homeVisitPEDescription));
      }
      if (sps.schoolTalkPESelected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.schoolTalkPEDescription));
      }
      if (sps.nurseAtClinicSelected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.nurseAtClinicDescription));
      }

      // TODO: remove this demo option (it is just an idea how to display completed items)
      supportOptions.add(
        TableRow(children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: CheckboxListTile(
              // secondary: const Icon(Icons.local_hospital),
              title: Text(
                'Completed Item',
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
      );

      return Table(columnWidths: {
        0: FixedColumnWidth(250.0),
        // 0: IntrinsicColumnWidth(),
        // 1: FixedColumnWidth(250.0),
      }, children: supportOptions);
    }

    if (_patient.latestPreferenceAssessment == null) {
      return Card(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Center(
                  child: Text(
                "No preferences available for this patient. Start a new preference assessment below.",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ))));
    }
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
                      child: _buildARTRefillText()),
                ),
              ]),
              TableRow(children: [
                TableCell(
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: _tableRowPaddingVertical),
                        child: Text('Adherence Reminder Message'))),
                TableCell(
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: _tableRowPaddingVertical),
                        child: _buildAdherenceReminderMessageText())),
              ]),
              TableRow(children: [
                TableCell(
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: _tableRowPaddingVertical),
                        child: Text('Adherence Reminder Frequency'))),
                TableCell(
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: _tableRowPaddingVertical),
                        child: _buildAdherenceReminderFrequencyText())),
              ]),
              TableRow(children: [
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _tableRowPaddingVertical),
                      child: Text('Adherence Reminder Notification Time')),
                ),
                TableCell(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _tableRowPaddingVertical),
                      child: _buildAdherenceReminderTimeText()),
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
                      child: _buildVLMessageSuppressedText()),
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
                      child: _buildVLMessageUnsuppressedText()),
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
                    child: _buildSupportOptions(),
                  ),
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

  void _pushARTRefillScreen(BuildContext context, Patient patient, String nextRefillDate) {
    Navigator.of(_context).push(
      new PageRouteBuilder<void>(
        opaque: false,
        transitionsBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2, Widget widget) {
          return FadeTransition(
            opacity: anim1,
            child: widget, // child is the value returned by pageBuilder
          );
        },
        pageBuilder: (BuildContext context, _, __) {
          return ARTRefillScreen(patient, nextRefillDate);
        },
      ),
    ).then((_) {
      // calling setState to trigger a re-render of the page and display the new
      // ART Refill Date
      setState(() {});
    });
  }

}
