import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonFlat.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/ViralLoadBadge.dart';
import 'package:pebrapp/database/beans/SupportPreferencesSelection.dart';
import 'package:pebrapp/database/beans/ViralLoadSource.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/screens/ARTRefillScreen.dart';
import 'package:pebrapp/screens/AddViralLoadScreen.dart';
import 'package:pebrapp/screens/EditPatientScreen.dart';
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
  final int _descriptionFlex = 1;
  final int _contentFlex = 1;
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
        _buildPatientCharacteristicsCard(),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [PEBRAButtonFlat('Edit Characteristics', onPressed: () { _pushEditPatientScreen(_patient); })]),
        _buildViralLoadHistoryCard(),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [PEBRAButtonFlat('add viral load', onPressed: () { _addViralLoadPressed(_context, _patient); })]),
        _buildTitle('Preferences'),
        _buildPreferencesCard(),
        Center(child: _buildTitle('Next Preference Assessment')),
        Center(child: Text(_nextAssessmentText)),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [PEBRAButtonRaised('Start Assessment', onPressed: () { _pushPreferenceAssessmentScreen(_context, _patient.artNumber); })]),
        Center(child: _buildTitle('Next ART Refill')),
        Center(child: Text(_nextRefillText)),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [PEBRAButtonRaised('Manage Refill', onPressed: () { _pushARTRefillScreen(_context, _patient, _nextRefillText); })]),
        Container(height: 50), // padding at bottom
      ],
    );
  }

  void _pushEditPatientScreen(Patient patient) {
    Navigator.of(_context).push(
      new MaterialPageRoute<Patient>(
        builder: (BuildContext context) {
          return EditPatientScreen(patient);
        },
      ),
    );
  }

  void _addViralLoadPressed(BuildContext context, Patient patient) {
    Navigator.of(context).push(
      new PageRouteBuilder<void>(
        opaque: false,
        transitionsBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2, Widget widget) {
          return FadeTransition(
            opacity: anim1,
            child: widget, // child is the value returned by pageBuilder
          );
        },
        pageBuilder: (BuildContext context, _, __) {
          return AddViralLoadScreen(patient);
        },
      ),
    ).then((_) {
      // calling setState to trigger a re-render of the page and display the new
      // viral load history
      setState(() {});
    });
  }

  Widget _buildRow(String description, String content) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child:
        Row(
          children: <Widget>[
            Expanded(flex: _descriptionFlex, child: Text(description)),
            Expanded(flex: _contentFlex, child: Text(content ?? '—')),
          ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle('Patient Characterstics'),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: [
                _buildRow('Sticker Number', _patient.stickerNumber),
                _buildRow('Year of Birth', _patient.yearOfBirth.toString()),
                _buildRow('Gender', _patient.gender.description),
                _buildRow('Sexual Orientation', _patient.sexualOrientation.description),
                _buildRow('Village', _patient.village),
                _buildRow('Phone Number', _patient.phoneNumber),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildViralLoadHistoryCard() {

    if (_patient.mostRecentViralLoad == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle('Viral Load History'),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Center(
                child: Text(
                  "No viral load data available for this patient. Sync with the viral load database or add a new entry manually.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget _makeSubtitle(String subtitle) {
      return Padding(padding: EdgeInsets.only(top: 20, bottom: 10),
          child:
          Row(children: [
            Text(subtitle, style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
              fontSize: 15.0,
            ),)
          ]));
    }

    ClipRect _getPaddedIcon(String assetLocation, {Color color}) {
      return ClipRect(
        clipBehavior: Clip.antiAlias,
        child: SizedOverflowBox(
          size: Size(32.0, 30.0),
          child: Image(
            height: 30.0,
            color: color,
            image: AssetImage(assetLocation),
          ),
        ),
      );
    }

    Widget _buildViralLoadRow(vl) {
      if (vl == null) { return Column(); }
      Widget description = Text('${formatDateConsistent(vl.dateOfBloodDraw)}');
      Widget viralLoadIcon = vl.isLowerThanDetectable
          ? Text('LTDL')
          : (vl.isSuppressed
            ? _getPaddedIcon('assets/icons/viralload_suppressed.png')
            : _getPaddedIcon('assets/icons/viralload_unsuppressed.png'));
      Widget viralLoadBadge = ViralLoadBadge(vl, smallSize: false);
      Widget content = Row(
        children: <Widget>[
//          viralLoadIcon,
          viralLoadBadge,
          SizedBox(width: 10.0),
          Text(vl.labNumber),
          SizedBox(width: 10.0),
          Text(vl.source == ViralLoadSource.MANUAL_INPUT() ? 'manual' : 'database'),
        ],
      );
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          children: <Widget>[
            Expanded(flex: _descriptionFlex, child: description),
            Expanded(flex: _contentFlex, child: content),
          ],
        ),
      );
    }

    final vlFollowUps = _patient.viralLoadFollowUps.map((ViralLoad vl) {
      return _buildViralLoadRow(vl);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle('Viral Load History'),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: [
                _makeSubtitle('Baseline Viral Load'),
                _buildViralLoadRow(_patient.viralLoadBaselineManual),
                _buildViralLoadRow(_patient.viralLoadBaselineDatabase),
                _makeSubtitle('Follow Up Viral Loads'),
                ...vlFollowUps,
              ],
            ),
          ),
        ),
      ],
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
      if (sps.NURSE_CLINIC_selected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.NURSE_CLINIC_DESCRIPTION));
      }
      if (sps.SATURDAY_CLINIC_CLUB_selected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.SATURDAY_CLINIC_CLUB_DESCRIPTION));
      }
      if (sps.COMMUNITY_YOUTH_CLUB_selected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.COMMUNITY_YOUTH_CLUB_DESCRIPTION));
      }
      if (sps.PHONE_CALL_PE_selected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.PHONE_CALL_PE_DESCRIPTION));
      }
      if (sps.HOME_VISIT_PE_selected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.HOME_VISIT_PE_DESCRIPTION));
      }
      if (sps.SCHOOL_VISIT_PE_selected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.SCHOOL_VISIT_PE_DESCRIPTION));
      }
      if (sps.PITSO_VISIT_PE_selected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.PITSO_VISIT_PE_DESCRIPTION));
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
    Navigator.of(context).push(
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
