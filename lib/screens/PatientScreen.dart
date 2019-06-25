import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonFlat.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/TransparentHeaderPage.dart';
import 'package:pebrapp/components/ViralLoadBadge.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/ARTRefillOption.dart';
import 'package:pebrapp/database/beans/Gender.dart';
import 'package:pebrapp/database/beans/SupportPreferencesSelection.dart';
import 'package:pebrapp/database/beans/ViralLoadSource.dart';
import 'package:pebrapp/database/beans/YesNoRefused.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/screens/ARTRefillScreen.dart';
import 'package:pebrapp/screens/AddViralLoadScreen.dart';
import 'package:pebrapp/screens/EditPatientScreen.dart';
import 'package:pebrapp/screens/PreferenceAssessmentScreen.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:pebrapp/utils/VisibleImpactUtils.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientScreen extends StatefulWidget {
  final Patient _patient;
  PatientScreen(this._patient);
  @override
  createState() => _PatientScreenState(_patient);
}

class _PatientScreenState extends State<PatientScreen> {
  final int _descriptionFlex = 1;
  final int _contentFlex = 1;
  BuildContext _context;
  Patient _patient;
  String _nextAssessmentText = '—';
  String _nextRefillText = '—';
  String _nextEndpointText = '—';
  double _screenWidth;

  bool NURSE_CLINIC_done = false;
  bool SATURDAY_CLINIC_CLUB_done = false;
  bool COMMUNITY_YOUTH_CLUB_done = false;
  bool PHONE_CALL_PE_done = false;
  bool HOME_VISIT_PE_done = false;
  bool SCHOOL_VISIT_PE_done = false;
  bool PITSO_VISIT_PE_done = false;

  StreamSubscription<AppState> _appStateStream;

  final double _spacingBetweenCards = 40.0;

  // constructor
  _PatientScreenState(this._patient);

  @override
  void initState() {
    super.initState();
    _appStateStream = PatientBloc.instance.appState.listen( (streamEvent) {
      print('*** PatientScreen received data: ${streamEvent.runtimeType} ***');
      if (streamEvent is AppStateRequiredActionData && streamEvent.action.patientART == _patient.artNumber) {
        print('*** PatientScreen received AppStateRequiredActionData: ${streamEvent.action.patientART} ***');
        setState(() {
          // TODO: animate insertion and removal of required action label for visual fidelity
          if (streamEvent.isDone) {
            _patient.requiredActions.removeWhere((RequiredAction a) => a.type == streamEvent.action.type);
          } else {
            _patient.requiredActions.add(streamEvent.action);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _appStateStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('*** PatientScreenState.build ***');
    _context = context;
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

    DateTime nextEndpointSurveyDate = _patient.enrolmentDate;
    nextEndpointSurveyDate = calculateNextEndpointSurvey(nextEndpointSurveyDate);
    if (nextEndpointSurveyDate != null) {
      _nextEndpointText = formatDate(nextEndpointSurveyDate);
    } else {
      _nextEndpointText = '—';
    }

    final Widget content = Column(
      children: <Widget>[
        _buildRequiredActions(),
        _buildNextActions(),
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
      ],
    );

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: TransparentHeaderPage(
        title: 'Patient',
        subtitle: _patient.artNumber,
        actions: <Widget>[IconButton(onPressed: () { Navigator.of(context).pop(); }, icon: Icon(Icons.close),)],
        child: content,
      ),
    );

  }

  Widget _buildRequiredActions() {

    FlatButton _endpointSurveyDoneButton(RequiredAction action) {
      return FlatButton(
        onPressed: () async {
          _patient.requiredActions.removeWhere((RequiredAction a) => a.type == action.type);
          await DatabaseProvider().removeRequiredAction(_patient.artNumber, action.type);
          // TODO: hide the action card, ideally with an animation for visual fidelity
        },
        splashColor: NOTIFICATION_INFO_SPLASH,
        child: Text(
          "ENDPOINT SURVEY COMPLETED",
          style: TextStyle(
            color: NOTIFICATION_INFO_TEXT,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final actions = _patient.requiredActions.toList().asMap().map((int i, RequiredAction action) {
      String actionText;
      Widget actionButton;
      switch (action.type) {
        case RequiredActionType.ASSESSMENT_REQUIRED:
          actionText = "Preference assessment required. Start a preference assessment by tapping 'Start Assessment' below.";
          break;
        case RequiredActionType.REFILL_REQUIRED:
          actionText = "ART refill required. Start an ART refill by tapping 'Manage Refill' below.";
          break;
        case RequiredActionType.ENDPOINT_3M_SURVEY_REQUIRED:
          actionText = "3 month endpoint survey required. Start an endpoint survey by tapping 'Open KoBoCollect' below.";
          actionButton = _endpointSurveyDoneButton(action);
          break;
        case RequiredActionType.ENDPOINT_6M_SURVEY_REQUIRED:
          actionText = "6 month endpoint survey required. Start an endpoint survey by tapping 'Open KoBoCollect' below.";
          actionButton = _endpointSurveyDoneButton(action);
          break;
        case RequiredActionType.ENDPOINT_12M_SURVEY_REQUIRED:
          actionText = "12 month endpoint survey required. Start an endpoint survey by tapping 'Open KoBoCollect' below.";
          actionButton = _endpointSurveyDoneButton(action);
          break;
        case RequiredActionType.NOTIFICATIONS_UPLOAD_REQUIRED:
          actionText = "The automatic synchronization of the notifications preferences with the database failed. Please synchronize manually.";
          actionButton = FlatButton(
            onPressed: () async {
              await uploadNotificationsPreferences(_patient, _patient.latestPreferenceAssessment);
              // TODO: hide the action card if the upload was successful, ideally with an animation for visual fidelity
            },
            splashColor: NOTIFICATION_INFO_SPLASH,
            child: Text(
              "SYNCHRONIZE",
              style: TextStyle(
                color: NOTIFICATION_INFO_TEXT,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
          break;
        case RequiredActionType.ART_REFILL_DATE_UPLOAD_REQUIRED:
          actionText = "The automatic synchronization of the ART refill date with the database failed. Please synchronize manually.";
          actionButton = FlatButton(
            onPressed: () async {
              await uploadNextARTRefillDate(_patient, _patient.latestARTRefill.nextRefillDate);
              // TODO: hide the action card if the upload was successful, ideally with an animation for visual fidelity
            },
            splashColor: NOTIFICATION_INFO_SPLASH,
            child: Text(
              "SYNCHRONIZE",
              style: TextStyle(
                color: NOTIFICATION_INFO_TEXT,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
          break;
      }

      final double badgeSize = 30.0;
      return MapEntry(
        i,
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          elevation: 5.0,
          clipBehavior: Clip.antiAlias,
          child: Container(
            color: NOTIFICATION_NORMAL,
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                SizedBox(height: 20.0),
                Container(
                  width: double.infinity,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Hero(
                          tag: "RequiredAction_${_patient.artNumber}_$i",
                          child: Container(
                            width: badgeSize,
                            height: badgeSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: Center(
                              child: Text(
                                '${i+1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Roboto',
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            actionText,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: NOTIFICATION_MESSAGE_TEXT,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ]),
                ),
                actionButton ?? SizedBox(height: 15.0),
                SizedBox(height: 5.0),
              ],
            ),
          ),
        ),
      );
    }).values.toList();

    return Column(
      children: <Widget>[
        ...actions,
        SizedBox(height: actions.length > 0 ? 20.0 : 0.0),
      ],
    );
  }

  Widget _buildNextActions() {

    Widget _buildNextActionRow({String title, String dueDate, String explanation, Widget button}) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10.0),
                      Text(dueDate, style: TextStyle(fontSize: 16.0)),
                      SizedBox(height: 10.0),
                      Text(explanation),
                    ],
                  ),
                ),
                SizedBox(width: 10.0),
                button,
              ],
            ),
          ],
        ),
      );
    }

    String pronoun = 'his/her';
    if (_patient.gender == Gender.FEMALE()) {
      pronoun = 'her';
    } else if (_patient.gender == Gender.MALE()) {
      pronoun = 'his';
    }
    return Column(
      children: <Widget>[
        _buildNextActionRow(
          title: 'Next Preference Assessment',
          dueDate: _nextAssessmentText,
          explanation: 'Preference assessments are due every month for unsuppressed patients and every 3 months for suppressed patients.',
          button: _makeButton('Start Assessment', onPressed: () { _startAssessmentPressed(_context, _patient); }),
        ),
        SizedBox(height: _spacingBetweenCards),
        _buildNextActionRow(
          title: 'Next ART Refill',
          dueDate: _nextRefillText,
          explanation: 'The ART refill date is selected when the patient collects $pronoun ARTs or has them delivered.',
          button: _makeButton('Manage Refill', onPressed: () { _manageRefillPressed(_context, _patient, _nextRefillText); }),
        ),
        SizedBox(height: _spacingBetweenCards),
        _buildNextActionRow(
          title: 'Next Endpoint Survey',
          dueDate: _nextEndpointText,
          explanation: 'Endpoint surveys are due 3, 6, and 12 months after patient enrollment.',
          button: _makeButton('Open KoBoCollect', onPressed: _onOpenKoboCollectPressed),
        ),
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
            _getPaddedIcon('assets/icons/no_support.png', width: iconWidth, height: iconHeight),
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
          icon: _getPaddedIcon('assets/icons/nurse_clinic.png', width: iconWidth, height: iconHeight, color: NURSE_CLINIC_done ? ICON_INACTIVE : ICON_ACTIVE),
        ));
      }
      if (sps.SATURDAY_CLINIC_CLUB_selected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.SATURDAY_CLINIC_CLUB_DESCRIPTION,
          checkboxState: SATURDAY_CLINIC_CLUB_done,
          onChanged: (bool newState) { setState(() { SATURDAY_CLINIC_CLUB_done = newState; }); },
          icon: _getPaddedIcon('assets/icons/saturday_clinic_club.png', width: iconWidth, height: iconHeight, color: SATURDAY_CLINIC_CLUB_done ? ICON_INACTIVE : ICON_ACTIVE),
        ));
      }
      if (sps.COMMUNITY_YOUTH_CLUB_selected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.COMMUNITY_YOUTH_CLUB_DESCRIPTION,
          checkboxState: COMMUNITY_YOUTH_CLUB_done,
          onChanged: (bool newState) { setState(() { COMMUNITY_YOUTH_CLUB_done = newState; }); },
          icon: _getPaddedIcon('assets/icons/youth_club.png', width: iconWidth, height: iconHeight, color: COMMUNITY_YOUTH_CLUB_done ? ICON_INACTIVE : ICON_ACTIVE),
        ));
      }
      if (sps.PHONE_CALL_PE_selected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.PHONE_CALL_PE_DESCRIPTION,
          checkboxState: PHONE_CALL_PE_done,
          onChanged: (bool newState) { setState(() { PHONE_CALL_PE_done = newState; }); },
          icon: _getPaddedIcon('assets/icons/phonecall_pe.png', width: iconWidth, height: iconHeight, color: PHONE_CALL_PE_done ? ICON_INACTIVE : ICON_ACTIVE),
        ));
      }
      if (sps.HOME_VISIT_PE_selected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.HOME_VISIT_PE_DESCRIPTION,
          checkboxState: HOME_VISIT_PE_done,
          onChanged: (bool newState) { setState(() { HOME_VISIT_PE_done = newState; }); },
          icon: _getPaddedIcon('assets/icons/homevisit_pe.png', width: iconWidth, height: iconHeight, color: HOME_VISIT_PE_done ? ICON_INACTIVE : ICON_ACTIVE),
        ));
      }
      if (sps.SCHOOL_VISIT_PE_selected) {
        String schoolNameAndVillage = _patient.latestPreferenceAssessment?.school;
        schoolNameAndVillage = schoolNameAndVillage == null ? '' : '\n($schoolNameAndVillage)';
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.SCHOOL_VISIT_PE_DESCRIPTION + schoolNameAndVillage,
          checkboxState: SCHOOL_VISIT_PE_done,
          onChanged: (bool newState) { setState(() { SCHOOL_VISIT_PE_done = newState; }); },
          icon: _getPaddedIcon('assets/icons/schooltalk_pe.png', width: iconWidth, height: iconHeight, color: SCHOOL_VISIT_PE_done ? ICON_INACTIVE : ICON_ACTIVE),
        ));
      }
      if (sps.PITSO_VISIT_PE_selected) {
        supportOptions.add(_buildSupportOption(SupportPreferencesSelection.PITSO_VISIT_PE_DESCRIPTION,
          checkboxState: PITSO_VISIT_PE_done,
          onChanged: (bool newState) { setState(() { PITSO_VISIT_PE_done = newState; }); },
          icon: _getPaddedIcon('assets/icons/pitso.png', width: iconWidth, height: iconHeight, color: PITSO_VISIT_PE_done ? ICON_INACTIVE : ICON_ACTIVE),
        ));
      }

      final String supportDisclaimer = "The following support options require "
          "additional action. Tick off any options that are completed.";

      // small screen option:
      // shows disclaimer first, then the support options below, both in full
      // width
      print('screen width: $_screenWidth');
      if (_screenWidth < 400.0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Text(supportDisclaimer),
            ),
            ...supportOptions,
          ],
        );
      }

      // wide screen option:
      // shows disclaimer on the left (as all the other descriptors above),
      // and the support options on the right (as all the other contents above)
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Text(supportDisclaimer),
            ),
          ),
          SizedBox(width: 5.0),
          Expanded(
            child: Column(children: [...supportOptions],
            ),
          ),
        ],
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

        Widget _vhwInfo() {
          ARTRefillOption lastOption = _patient.latestPreferenceAssessment?.lastRefillOption;
          if (lastOption == null || lastOption != ARTRefillOption.VHW()) {
            return Container();
          }
          return Column(
              children: [
                _buildRow('VHW Name', _patient.latestPreferenceAssessment?.artRefillVHWName),
                _buildRow("VHW's Village", _patient.latestPreferenceAssessment?.artRefillVHWVillage),
                _buildRow("VHW's Phone Number", _patient.latestPreferenceAssessment?.artRefillVHWPhoneNumber),
              ],
          );
        }

        Widget _treatmentBuddyInfo() {
          ARTRefillOption lastOption = _patient.latestPreferenceAssessment?.lastRefillOption;
          if (lastOption == null || lastOption != ARTRefillOption.TREATMENT_BUDDY()) {
            return Container();
          }
          return Column(
            children: [
              _buildRow("Treatment Buddy's ART Nr.", _patient.latestPreferenceAssessment?.artRefillTreatmentBuddyART),
              _buildRow("Treatment Buddy's Village", _patient.latestPreferenceAssessment?.artRefillTreatmentBuddyVillage),
              _buildRow("Treatment Buddy's Phone Number", _patient.latestPreferenceAssessment?.artRefillTreatmentBuddyPhoneNumber),
            ],
          );
        }

        Widget _adherenceReminderInfo() {
          bool enabled = _patient.latestPreferenceAssessment?.adherenceReminderEnabled;
          if (enabled == null || !enabled) {
            return _buildRow('Adherence Reminders', 'disabled');
          }
          return Column(
            children: [
              _buildRow('Adherence Reminder Frequency', _patient.latestPreferenceAssessment?.adherenceReminderFrequency?.description),
              _buildRow('Adherence Reminder Notification Time', formatTime(_patient.latestPreferenceAssessment?.adherenceReminderTime)),
              _buildRow('Adherence Reminder Message', _patient.latestPreferenceAssessment?.adherenceReminderMessage?.description),
            ],
          );
        }

        Widget _refillReminderInfo() {
          bool enabled = _patient.latestPreferenceAssessment?.artRefillReminderEnabled;
          if (enabled == null || !enabled) {
            return _buildRow('ART Refill Reminders', 'disabled');
          }
          return Column(
            children: [
              _buildRow('ART Refill Reminder Time', _patient.latestPreferenceAssessment?.artRefillReminderDaysBefore?.description),
              _buildRow('ART Refill Reminder Message', _patient.latestPreferenceAssessment?.artRefillReminderMessage?.description),
            ],
          );
        }

        Widget _vlNotificationInfo() {
          bool enabled = _patient.latestPreferenceAssessment?.vlNotificationEnabled;
          if (enabled == null || !enabled) {
            return _buildRow('Viral Load Notifications', 'disabled');
          }
          return Column(
            children: [
              _buildRow('Viral Load Message (suppressed)', _patient.latestPreferenceAssessment?.vlNotificationMessageSuppressed?.description),
              _buildRow('Viral Load Message (unsuppressed)', _patient.latestPreferenceAssessment?.vlNotificationMessageUnsuppressed?.description),
            ],
          );
        }

        Widget _psychosocialSupportInfo() {
          final YesNoRefused answer = _patient.latestPreferenceAssessment?.psychosocialShareSomethingAnswer;
          final bool shareSomething = answer != null && answer == YesNoRefused.YES();
          return Column(
            children: [
              _buildRow('Did the patient want to share something?', answer.description),
              shareSomething ? _buildRow('The patient shared:', _patient.latestPreferenceAssessment?.psychosocialShareSomethingContent) : Container(),
              _buildRow('How was the patient doing?', _patient.latestPreferenceAssessment?.psychosocialHowDoing),
            ],
          );
        }

        Widget _unsuppressedVlInfo() {
          final YesNoRefused answer = _patient.latestPreferenceAssessment?.unsuppressedSafeEnvironmentAnswer;
          if (answer == null) {
            return Text(
              'The patient was suppressed at the time of the preference assessment. Thus, this section was not covered during the assessment.',
              style: TextStyle(color: TEXT_INACTIVE),
              textAlign: TextAlign.center,
            );
          }
          final bool notSafe = answer == YesNoRefused.NO();
          return Column(
            children: [
              _buildRow('Does the patient have a safe environment to take the medication?', answer.description),
              notSafe ? _buildRow('Why is the environment not safe?', _patient.latestPreferenceAssessment?.unsuppressedWhyNotSafe) : Container(),
            ],
          );
        }

        final double _spacingBetweenPreferences = 20.0;
        final double _spacingBetweenNotificationsInfos = 10.0;
        return Column(
          children: [
            SizedBox(height: 5.0),
            _buildSubtitle('ART Refill'), Divider(),
            _buildRow('ART Refill', _patient.latestPreferenceAssessment?.lastRefillOption?.description),
            _vhwInfo(),
            _treatmentBuddyInfo(),
            _buildRow('ART Supply Amount', _patient.latestPreferenceAssessment?.artSupplyAmount?.description),
            SizedBox(height: _spacingBetweenPreferences),
            _buildSubtitle('Notifications'), Divider(),
            _adherenceReminderInfo(),
            SizedBox(height: _spacingBetweenNotificationsInfos),
            _refillReminderInfo(),
            SizedBox(height: _spacingBetweenNotificationsInfos),
            _vlNotificationInfo(),
            SizedBox(height: _spacingBetweenPreferences),
            _buildSubtitle('Support'), Divider(),
            _buildSupportOptions(),
            SizedBox(height: _spacingBetweenPreferences),
            _buildSubtitle('Psychosocial Support'), Divider(),
            _psychosocialSupportInfo(),
            SizedBox(height: _spacingBetweenPreferences),
            _buildSubtitle('Unsuppressed Viral Load'), Divider(),
            _unsuppressedVlInfo(),
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
      child: Row(
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
    _fadeInScreen(EditPatientScreen(patient)).then((_) {
      // calling setState to trigger a re-render of the page and display the new
      // patient characteristics
      setState(() {});
    });
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

  Future<void> _startAssessmentPressed(BuildContext context, Patient patient) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return PreferenceAssessmentScreen(patient);
        },
      ),
    );
  }

  Future<void> _manageRefillPressed(BuildContext context, Patient patient, String nextRefillDate) async {
    await _fadeInScreen(ARTRefillScreen(patient, nextRefillDate));
    // calling setState to trigger a re-render of the page and display the new
    // ART Refill Date
    setState(() {});
  }

  Future<void> _onOpenKoboCollectPressed() async {
    const appUrl = 'android-app://org.koboc.collect.android';
    const marketUrl = 'market://details?id=org.koboc.collect.android';
    if (await canLaunch(appUrl)) {
      await launch(appUrl);
    } else if (await canLaunch(marketUrl)) {
      await launch(marketUrl);
    } else {
      showFlushbar("Could not find KoBoCollect app. Make sure KoBoCollect is installed.");
    }
  }

  Widget _makeButton(String buttonText, {Function() onPressed, bool flat: false}) {
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
