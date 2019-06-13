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
  final BuildContext _context;
  Patient _patient;
  String _nextAssessmentText = '—';
  String _nextRefillText = '—';
  double _screenWidth;

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

    _screenWidth = MediaQuery.of(context).size.width;

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

    final double _spacingBetweenCards = 40.0;
    return Column(
      children: <Widget>[
        _buildPatientCharacteristicsCard(),
        _makeButton('Edit Characteristics', onPressed: () { _editCharacteristicsPressed(_patient); }, flat: true),
        SizedBox(height: _spacingBetweenCards),
        _buildViralLoadHistoryCard(),
        _makeButton('fetch from database', onPressed: () { _fetchFromDatabasePressed(_context, _patient); }, flat: true),
        _makeButton('add manual entry', onPressed: () { _addManualEntryPressed(_context, _patient); }, flat: true),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text('Use this option to correct a wrong entry from the database.', textAlign: TextAlign.center),
        ),
        SizedBox(height: _spacingBetweenCards),
        _buildPreferencesCard(),
        SizedBox(height: _spacingBetweenCards),
        _buildTitle('Next Preference Assessment'),
        Text(_nextAssessmentText, style: TextStyle(fontSize: 16.0)),
        SizedBox(height: 10.0),
        _makeButton('Start Assessment', onPressed: () { _startAssessmentPressed(_context, _patient); }),
        SizedBox(height: _spacingBetweenCards),
        _buildTitle('Next ART Refill'),
        Text(_nextRefillText, style: TextStyle(fontSize: 16.0)),
        SizedBox(height: 10.0),
        _makeButton('Manage Refill', onPressed: () { _manageRefillPressed(_context, _patient, _nextRefillText); }),
        SizedBox(height: _spacingBetweenCards),
      ],
    );
  }

  _buildPatientCharacteristicsCard() {
    return _buildCard(
      title: 'Patient Characterstics',
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
    );
  }

  _buildViralLoadHistoryCard() {

    if (_patient.mostRecentViralLoad == null) {
      return _buildCard(
        title: 'Viral Load History',
        child: Center(
          child: Text(
            "No viral load data available for this patient. Fetch data from the viral load database or add a new entry manually.",
            style: TextStyle(color: NO_DATA_TEXT),
          ),
        ),
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

      final String description = '${formatDateConsistent(vl.dateOfBloodDraw)}';
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

      return _buildRowWithWidget(description, content);
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
        _buildSubtitle('Baseline Viral Load'),
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
        _buildSubtitle('Follow Up Viral Loads'),
        Divider(),
        content,
      ]);
    }

    return _buildCard(
      title: 'Viral Load History',
      child: Column(
        children: [
          _baselineVLRows(),
          SizedBox(height: 20.0),
          _followUpVLRows(),
        ],
      ),
    );

  }

  _buildPreferencesCard() {

    Widget _buildSupportOptions() {
      final SupportPreferencesSelection sps = _patient.latestPreferenceAssessment.supportPreferences;
      final double iconWidth = 28.0;
      final double iconHeight = 28.0;
      if (sps.areAllDeselected) {
        return _buildRowWithWidget('Support',
          Row(
            children: [
            _getPaddedIcon('assets/icons/no_support_fett.png', width: iconWidth, height: iconHeight),
            SizedBox(width: 5.0),
            Text(SupportPreferencesSelection.NONE_DESCRIPTION),
            ],
          ),
        );
      }
      if (sps.areAllWithTodoDeselected) {
        return _buildRow('Support', '—');
      }
      List<Widget> supportOptions = [];
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
          icon: Icon(Icons.description, color: dummy_item_done ? ICON_INACTIVE : ICON_ACTIVE),
          doneText: 'done on 04.02.2019'),
      );

      // small screen option:
      // shows a 'Support' line first, then the support options in full width
      print('screen width: $_screenWidth');
      if (_screenWidth < 400.0) {
        return Column(
          children: [
            _buildRow('Support', ''),
            ...supportOptions,
          ],
        );
      }

      // wide screen option:
      // shows 'Support' on the left (as all the other descriptors above), then
      // the support options on the right (as all the other contents above)
      return _buildRowWithWidget('Support',
        Column(children: [...supportOptions],
        ),
      );

    }

    Widget _buildPreferencesCardContent() {
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
        return Column(
          children: [
            _buildRow('ART Refill', _patient.latestPreferenceAssessment?.lastRefillOption?.description),
            _buildRow('Adherence Reminder Message', _patient.latestPreferenceAssessment?.adherenceReminderMessage?.description),
            _buildRow('Adherence Reminder Frequency', _patient.latestPreferenceAssessment?.adherenceReminderFrequency?.description),
            _buildRow('Adherence Reminder Notification Time', formatTime(_patient.latestPreferenceAssessment?.adherenceReminderTime)),
            _buildRow('Viral Load Message (suppressed)', _patient.latestPreferenceAssessment?.vlNotificationMessageSuppressed?.description),
            _buildRow('Viral Load Message (unsuppressed)', _patient.latestPreferenceAssessment?.vlNotificationMessageUnsuppressed?.description),
            _buildSupportOptions(),
          ],
        );
      }
    }

    return _buildCard(
      title: 'Preferences',
      child: Container(
        width: double.infinity,
        child: _buildPreferencesCardContent(),
      ),
    );

  }


  /*
   * Helper Functions
   */

  Widget _buildCard({@required Widget child, String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (title == null || title == '') ? Container() : _buildTitle(title),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String description, String content) {
    return _buildRowWithWidget(description, Text(content ?? '—'));
  }

  Widget _buildRowWithWidget(String description, Widget content) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child:
      Row(
        children: <Widget>[
          Expanded(flex: _descriptionFlex, child: Text(description)),
          SizedBox(width: 5.0),
          Expanded(flex: _contentFlex, child: content),
        ],
      ),
    );
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

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubtitle(String subtitle) {
    return Row(
      children: [
        Text(
          subtitle,
          style: TextStyle(
            color: DATA_SUBTITLE_TEXT,
            fontStyle: FontStyle.italic,
            fontSize: 15.0,
          ),
        ),
      ],
    );
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

  Row _buildSupportOption(String title, {bool checkboxState, Function onChanged(bool newState), Widget icon, String doneText}) {
    return Row(children: [
      Expanded(
        child: CheckboxListTile(
          activeColor: ICON_INACTIVE,
          secondary: icon,
          subtitle: checkboxState ? Text(doneText ?? 'done', style: TextStyle(fontStyle: FontStyle.italic)) : null,
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

  void _editCharacteristicsPressed(Patient patient) {
    _fadeInScreen(EditPatientScreen(patient));
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

  void _addManualEntryPressed(BuildContext context, Patient patient) {
    _fadeInScreen(AddViralLoadScreen(patient)).then((_) {
      // calling setState to trigger a re-render of the page and display the new
      // viral load history
      setState(() {});
    });
  }

  void _startAssessmentPressed(BuildContext context, Patient patient) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return PreferenceAssessmentScreen(patient);
        },
      ),
    );
  }

  void _manageRefillPressed(BuildContext context, Patient patient, String nextRefillDate) {
    _fadeInScreen(ARTRefillScreen(patient, nextRefillDate)).then((_) {
      // calling setState to trigger a re-render of the page and display the new
      // ART Refill Date
      setState(() {});
    });
  }

  Widget _makeButton(String buttonText, {Null Function() onPressed, bool flat: false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        flat
            ? PEBRAButtonFlat(buttonText, onPressed: onPressed)
            : PEBRAButtonRaised(buttonText, onPressed: onPressed),
      ],
    );
  }

}
