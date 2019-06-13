import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonFlat.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/TransparentHeaderPage.dart';
import 'package:pebrapp/components/ViralLoadBadge.dart';
import 'package:pebrapp/database/beans/AdherenceReminderFrequency.dart';
import 'package:pebrapp/database/beans/AdherenceReminderMessage.dart';
import 'package:pebrapp/database/beans/SupportPreferencesSelection.dart';
import 'package:pebrapp/database/beans/VLSuppressedMessage.dart';
import 'package:pebrapp/database/beans/VLUnsuppressedMessage.dart';
import 'package:pebrapp/database/beans/ViralLoadSource.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/screens/ARTRefillScreen.dart';
import 'package:pebrapp/screens/AddViralLoadScreen.dart';
import 'package:pebrapp/screens/EditPatientScreen.dart';
import 'package:pebrapp/screens/PreferenceAssessmentScreen.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/Utils.dart';

class PatientScreen extends StatelessWidget {
  final Patient _patient;

  PatientScreen(this._patient);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        body: TransparentHeaderPage(
          title: 'Patient',
          subtitle: _patient.artNumber,
          actions: <Widget>[IconButton(onPressed: () { Navigator.of(context).pop(); }, icon: Icon(Icons.close),)],
          child: _PatientScreenBody(context, _patient)));
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

  bool NURSE_CLINIC_done = false;
  bool SATURDAY_CLINIC_CLUB_done = false;
  bool COMMUNITY_YOUTH_CLUB_done = false;
  bool PHONE_CALL_PE_done = false;
  bool HOME_VISIT_PE_done = false;
  bool SCHOOL_VISIT_PE_done = false;
  bool PITSO_VISIT_PE_done = false;

  bool dummy_item_done = false;

  _PatientScreenBodyState(this._context, this._patient);
  
  @override
  Widget build(BuildContext context) {

    DateTime lastAssessmentDate = _patient.latestPreferenceAssessment?.createdDate;
    if (lastAssessmentDate != null) {
      DateTime nextAssessmentDate = calculateNextAssessment(lastAssessmentDate, isSuppressed(_patient));
      _nextAssessmentText = formatDate(nextAssessmentDate);
    }

    DateTime nextRefillDate = _patient.latestARTRefill?.nextRefillDate;
    if (nextRefillDate != null) {
      _nextRefillText = formatDate(nextRefillDate);
    } else {
      _nextRefillText = '—';
    }

    return Column(
      children: <Widget>[
        _buildPatientCharacteristicsCard(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PEBRAButtonFlat('Edit Characteristics', onPressed: () { _pushEditPatientScreen(_patient); }),
          ],
        ),
        _buildViralLoadHistoryCard(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PEBRAButtonFlat('fetch from database', onPressed: () { _fetchFromDatabasePressed(_context, _patient); }),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PEBRAButtonFlat('add manual entry', onPressed: () { _addManualEntryPressed(_context, _patient); }),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text('Use this option to correct a wrong entry from the database.', textAlign: TextAlign.center),
        ),
        _buildPreferencesCard(),
        _buildTitle('Next Preference Assessment'),
        Text(_nextAssessmentText, style: TextStyle(fontSize: 16.0)),
        SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PEBRAButtonRaised('Start Assessment', onPressed: () { _pushPreferenceAssessmentScreen(_context, _patient); }),
          ],
        ),
        _buildTitle('Next ART Refill'),
        Text(_nextRefillText, style: TextStyle(fontSize: 16.0)),
        SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PEBRAButtonRaised('Manage Refill', onPressed: () { _pushARTRefillScreen(_context, _patient, _nextRefillText); }),
          ],
        ),
        SizedBox(height: 50),
      ],
    );
  }

  Future<void> _fetchFromDatabasePressed(BuildContext context, Patient patient) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Not Implemented'),
          content: Text('This feature is not yet available.'),
          actions: [
            FlatButton(
              child: Text("Dismiss"),
              onPressed: () { Navigator.of(context).pop(); },
            ),
          ],
        );
      },
    );
    // TODO: implement call to viral load database API
    // calling setState to trigger a re-render of the page and display the new
    // viral load history
    setState(() {});
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
                _buildRow('Enrolment Date', formatDateConsistent(_patient.enrolmentDate)),
                _buildRow('ART Number', _patient.artNumber),
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
                  "No viral load data available for this patient. Fetch data from the viral load database or add a new entry manually.",
                  style: TextStyle(color: NO_DATA_TEXT),
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget _buildViralLoadHeader() {
      Widget content = Row(
        children: <Widget>[
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: _formatHeaderRowText('Viral Load'),
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(child: _formatHeaderRowText('Lab Number')),
          Expanded(child: _formatHeaderRowText('Source')),
        ],
      );
      Widget row = Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          children: <Widget>[
            Expanded(flex: _descriptionFlex, child: _formatHeaderRowText('Date')),
            Expanded(flex: _contentFlex, child: content),
          ],
        ),
      );
      return row;
    }

    Widget _buildViralLoadRow(vl) {
      if (vl?.isSuppressed == null) { return Column(); }
      Widget description = Text('${formatDateConsistent(vl.dateOfBloodDraw)}');
      final double vlIconSize = 25.0;
      Widget viralLoadIcon = vl.isSuppressed
          ? _getPaddedIcon('assets/icons/viralload_suppressed.png', width: vlIconSize, height: vlIconSize)
          : _getPaddedIcon('assets/icons/viralload_unsuppressed.png', width: vlIconSize, height: vlIconSize);
      Widget viralLoadBadge = ViralLoadBadge(vl, smallSize: false);
      Widget content = Row(
        children: <Widget>[
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: viralLoadIcon,
//              child: viralLoadBadge,
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(child: Text(vl.labNumber)),
          Expanded(child: Text(vl.source == ViralLoadSource.MANUAL_INPUT() ? 'manual' : 'database')),
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

    Widget _baselineVLRows() {
      Widget content;
      if (_patient.viralLoadBaselineManual == null && _patient.viralLoadBaselineDatabase == null) {
        content = Text('No Baseline Viral Load data available', style: TextStyle(color: NO_DATA_TEXT),);
      } else {
        content = Column(children: <Widget>[
          _buildViralLoadHeader(),
          _buildViralLoadRow(_patient.viralLoadBaselineManual),
          _buildViralLoadRow(_patient.viralLoadBaselineDatabase),
        ]);
      }
      return Column(children: <Widget>[
        _makeSubtitle('Baseline Viral Load'),
        Divider(),
        content,
      ]);
    }

    Widget _followUpVLRows() {
      Widget content;
      if (vlFollowUps.length == 0) {
        content = Text('No Follow Up Viral Load data available', style: TextStyle(color: NO_DATA_TEXT),);
      } else {
        content = Column(children: <Widget>[
          _buildViralLoadHeader(),
          ...vlFollowUps,
        ]);
      }
      return Column(children: <Widget>[
        _makeSubtitle('Follow Up Viral Loads'),
        Divider(),
        content,
      ]);
    }

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
                _baselineVLRows(),
                SizedBox(height: 20.0),
                _followUpVLRows(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildPreferencesCard() {

    _buildSupportOptions() {
      final SupportPreferencesSelection sps = _patient.latestPreferenceAssessment.supportPreferences;
      if (sps.areAllDeselected) {
        return Text('—');
      }
      final double iconWidth = 28.0;
      final double iconHeight = 28.0;
      List<TableRow> supportOptions = List<TableRow>();
      if (sps.NURSE_CLINIC_selected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.NURSE_CLINIC_DESCRIPTION,
          checkboxState: NURSE_CLINIC_done,
          onChanged: (bool newState) { setState(() { NURSE_CLINIC_done = newState; }); },
          icon: _getPaddedIcon('assets/icons/nurse_clinic_fett.png', width: iconWidth, height: iconHeight),
        ));
      }
      if (sps.SATURDAY_CLINIC_CLUB_selected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.SATURDAY_CLINIC_CLUB_DESCRIPTION,
          checkboxState: SATURDAY_CLINIC_CLUB_done,
          onChanged: (bool newState) { setState(() { SATURDAY_CLINIC_CLUB_done = newState; }); },
          icon: _getPaddedIcon('assets/icons/saturday_clinic_club_black.png', width: iconWidth, height: iconHeight),
        ));
      }
      if (sps.COMMUNITY_YOUTH_CLUB_selected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.COMMUNITY_YOUTH_CLUB_DESCRIPTION,
          checkboxState: COMMUNITY_YOUTH_CLUB_done,
          onChanged: (bool newState) { setState(() { COMMUNITY_YOUTH_CLUB_done = newState; }); },
          icon: _getPaddedIcon('assets/icons/youth_club_black.png', width: iconWidth, height: iconHeight),
        ));
      }
      if (sps.PHONE_CALL_PE_selected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.PHONE_CALL_PE_DESCRIPTION,
          checkboxState: PHONE_CALL_PE_done,
          onChanged: (bool newState) { setState(() { PHONE_CALL_PE_done = newState; }); },
          icon: _getPaddedIcon('assets/icons/phonecall_pe_black.png', width: iconWidth, height: iconHeight),
        ));
      }
      if (sps.HOME_VISIT_PE_selected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.HOME_VISIT_PE_DESCRIPTION,
          checkboxState: HOME_VISIT_PE_done,
          onChanged: (bool newState) { setState(() { HOME_VISIT_PE_done = newState; }); },
          icon: _getPaddedIcon('assets/icons/homevisit_pe_black.png', width: iconWidth, height: iconHeight),
        ));
      }
      if (sps.SCHOOL_VISIT_PE_selected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.SCHOOL_VISIT_PE_DESCRIPTION,
          checkboxState: SCHOOL_VISIT_PE_done,
          onChanged: (bool newState) { setState(() { SCHOOL_VISIT_PE_done = newState; }); },
          icon: _getPaddedIcon('assets/icons/schooltalk_pe_black.png', width: iconWidth, height: iconHeight),
        ));
      }
      if (sps.PITSO_VISIT_PE_selected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.PITSO_VISIT_PE_DESCRIPTION,
          checkboxState: PITSO_VISIT_PE_done,
          onChanged: (bool newState) { setState(() { PITSO_VISIT_PE_done = newState; }); },
          icon: _getPaddedIcon('assets/icons/pitso_black.png', width: iconWidth, height: iconHeight),
        ));
      }

      // TODO: remove this demo option (it is just an idea how to display completed items)
      supportOptions.add(_buildSupportOption('Completed Item',
          checkboxState: dummy_item_done,
          onChanged: (bool newState) { setState(() { dummy_item_done = newState; }); },
          icon: _getPaddedIcon('assets/icons/schooltalk_pe_black.png', width: iconWidth, height: iconHeight),
          doneText: 'done on 04.02.2019'),
      );

      return Table(columnWidths: {
        0: FixedColumnWidth(250.0),
        // 0: IntrinsicColumnWidth(),
        // 1: FixedColumnWidth(250.0),
      }, children: supportOptions);
    }

    Widget content() {
      if (_patient.latestPreferenceAssessment == null) {
        return Center(
          child: Text(
            "No preferences available for this patient. Start a new preference assessment below.",
            style: TextStyle(
              color: NO_DATA_TEXT,
            ),
          ),
        );
      } else {
        return Table(
          children: [
            _buildTableRow('ART Refill', _patient.latestPreferenceAssessment?.lastRefillOption?.description),
            _buildTableRow('Adherence Reminder Message', _patient.latestPreferenceAssessment?.adherenceReminderMessage?.description),
            _buildTableRow('Adherence Reminder Frequency', _patient.latestPreferenceAssessment?.adherenceReminderFrequency?.description),
            _buildTableRow('Adherence Reminder Notification Time', formatTime(_patient.latestPreferenceAssessment?.adherenceReminderTime)),
            _buildTableRow('Viral Load Message (suppressed)', _patient.latestPreferenceAssessment?.vlNotificationMessageSuppressed?.description),
            _buildTableRow('Viral Load Message (unsuppressed)', _patient.latestPreferenceAssessment?.vlNotificationMessageUnsuppressed?.description),
            _buildTableRowWithWidget('Support', _buildSupportOptions()),
          ],
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.0),
        _buildTitle('Preferences'),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: content(),
          ),
        ),
      ],
    );

  }


  /*
   * Helper Functions
   */

  TableRow _buildTableRow(String description, String content) {
    return _buildTableRowWithWidget(description, Text(content ?? '—'));
  }

  TableRow _buildTableRowWithWidget(String description, Widget content) {
    return TableRow(children: [
      TableCell(
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: _tableRowPaddingVertical),
          child: Text(description),
        ),
      ),
      TableCell(
        child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: _tableRowPaddingVertical),
            child: content),
      ),
    ]);
  }

  Widget _formatHeaderRowText(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12.0,
        color: VL_HISTORY_HEADER_TEXT,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _makeSubtitle(String subtitle) {
    return Padding(padding: EdgeInsets.only(top: 20, bottom: 10),
        child:
        Row(children: [
          Text(subtitle, style: TextStyle(
            color: DATA_SUBTITLE_TEXT,
            fontStyle: FontStyle.italic,
            fontSize: 15.0,
          ),)
        ]));
  }

  ClipRect _getPaddedIcon(String assetLocation, {Color color, double width: 25.0, double height: 25.0}) {
    return ClipRect(
        clipBehavior: Clip.antiAlias,
        child: SizedOverflowBox(
            size: Size(width, height),
            child: Image(
              height: height,
              color: color,
              image: AssetImage(
                  assetLocation),
            )));
  }

  TableRow _buildSupportOption(String title, {bool checkboxState, Function onChanged(bool newState), Widget icon, String doneText}) {
    return TableRow(children: [
      TableCell(
        child: CheckboxListTile(
          activeColor: ICON_INACTIVE,
          secondary: icon,
//              subtitle: Text(doneText ?? '', style: TextStyle(fontStyle: FontStyle.italic),),
          title: Text(
            title,
            style: TextStyle(
              decoration: checkboxState ? TextDecoration.lineThrough : TextDecoration.none,
              color: checkboxState ? TEXT_INACTIVE : TEXT_ACTIVE,
            ),
          ),
          dense: true,
          value: checkboxState,
          onChanged: onChanged,
        ),
      ),
      // done text
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Text(
          doneText ?? '',
          style: TextStyle(
            color: checkboxState ? TEXT_INACTIVE : TEXT_ACTIVE,
          ),
        ),
      ),
    ]);
  }

  /// Pushes [newScreen] to the top of the navigation stack using a fade in
  /// transition.
  Future<T> _fadeInScreen<T extends Object>(Widget newScreen) {
    return Navigator.of(_context).push(
      PageRouteBuilder<T>(
        opaque: false,
        transitionsBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2, Widget widget) {
          return FadeTransition(
            opacity: anim1,
            child: widget, // child is the value returned by pageBuilder
          );
        },
        pageBuilder: (BuildContext context, _, __) {
          return newScreen;
        },
      ),
    );
  }

  void _pushEditPatientScreen(Patient patient) {
    _fadeInScreen(EditPatientScreen(patient));
  }

  void _addManualEntryPressed(BuildContext context, Patient patient) {
    _fadeInScreen(AddViralLoadScreen(patient)).then((_) {
      // calling setState to trigger a re-render of the page and display the new
      // viral load history
      setState(() {});
    });
  }

  void _pushPreferenceAssessmentScreen(BuildContext context, Patient patient) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return PreferenceAssessmentScreen(patient);
        },
      ),
    );
  }

  void _pushARTRefillScreen(BuildContext context, Patient patient, String nextRefillDate) {
    _fadeInScreen(ARTRefillScreen(patient, nextRefillDate)).then((_) {
      // calling setState to trigger a re-render of the page and display the new
      // ART Refill Date
      setState(() {});
    });
  }

}
