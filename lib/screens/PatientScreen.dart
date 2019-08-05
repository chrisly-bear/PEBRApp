import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonFlat.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/RequiredActionContainer.dart';
import 'package:pebrapp/components/TransparentHeaderPage.dart';
import 'package:pebrapp/components/ViralLoadBadge.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/ARTRefillOption.dart';
import 'package:pebrapp/database/beans/Gender.dart';
import 'package:pebrapp/database/beans/SupportOption.dart';
import 'package:pebrapp/database/beans/SupportPreferencesSelection.dart';
import 'package:pebrapp/database/beans/ViralLoadSource.dart';
import 'package:pebrapp/database/beans/YesNoRefused.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/exceptions/MultiplePatientsException.dart';
import 'package:pebrapp/exceptions/VisibleImpactLoginFailedException.dart';
import 'package:pebrapp/screens/ARTRefillScreen.dart';
import 'package:pebrapp/screens/AddViralLoadScreen.dart';
import 'package:pebrapp/screens/EditPatientScreen.dart';
import 'package:pebrapp/screens/PreferenceAssessmentScreen.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:pebrapp/utils/VisibleImpactUtils.dart';

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
  bool _isFetchingViralLoads = false;
  String lastVLFetchDate = 'loading...';

  StreamSubscription<AppState> _appStateStream;

  final double _spacingBetweenCards = 40.0;
  final Map<RequiredActionType, AnimateDirection> shouldAnimateRequiredActionContainer = {};

  // constructor
  _PatientScreenState(this._patient);

  @override
  void initState() {
    super.initState();
    getLatestViralLoadFetchFromSharedPrefs(_patient.artNumber).then((DateTime fetchDate) {
      setState(() {
        lastVLFetchDate = fetchDate == null ? 'never' : formatDateAndTime(fetchDate);
      });
    });
    _appStateStream = PatientBloc.instance.appState.listen( (streamEvent) {
      if (streamEvent is AppStatePatientData && streamEvent.patient.artNumber == _patient.artNumber) {
        // TODO: animate changes to the new patient data (e.g. insertions and removals of required action card) with an animation for visual fidelity
        print('*** PatientScreen received AppStatePatientData: ${streamEvent.patient.artNumber} ***');
        final Set<RequiredAction> newVisibleRequiredActions = streamEvent.patient.calculateDueRequiredActions();
        for (RequiredAction a in newVisibleRequiredActions) {
          if (streamEvent.oldRequiredActions != null && !streamEvent.oldRequiredActions.contains(a)) {
            // this required action is new, animate it forward
            shouldAnimateRequiredActionContainer[a.type] = AnimateDirection.FORWARD;
          }
        }
        setState(() {});
      }
      if (streamEvent is AppStateRequiredActionData && streamEvent.action.patientART == _patient.artNumber) {
        print('*** PatientScreen received AppStateRequiredActionData: ${streamEvent.action.patientART} ***');
          // TODO: animate insertion and removal of required action card for visual fidelity
          if (streamEvent.isDone) {
            // this required action is done, animate it back
            if (_patient.requiredActions.firstWhere((RequiredAction a) => a.type == streamEvent.action.type, orElse: () => null) != null) {
              setState(() {
                shouldAnimateRequiredActionContainer[streamEvent.action.type] = AnimateDirection.BACKWARD;
              });
            }
          } else {
            // this required action is new, animate it forward
            if (_patient.requiredActions.firstWhere((RequiredAction a) => a.type == streamEvent.action.type, orElse: () => null) == null) {
              setState(() {
                shouldAnimateRequiredActionContainer[streamEvent.action.type] = AnimateDirection.FORWARD;
                _patient.requiredActions.add(streamEvent.action);
              });
            }
          }
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
    DateTime nextAssessmentDate = calculateNextAssessment(lastAssessmentDate, isSuppressed(_patient)) ?? _patient.enrollmentDate;
    _nextAssessmentText = formatDate(nextAssessmentDate);

    DateTime nextRefillDate = _patient.latestDoneARTRefill?.nextRefillDate ?? _patient.enrollmentDate;
    _nextRefillText = formatDate(nextRefillDate);

    DateTime nextEndpointSurveyDate = calculateNextQuestionnaire(_patient.enrollmentDate, _patient.requiredActions);
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
        _makeButton(
          'fetch from database',
          onPressed: _isFetchingViralLoads ? null : () { _fetchFromDatabasePressed(_context, _patient); },
          widget: _isFetchingViralLoads
            ? SizedBox(height: 15.0, width: 15.0, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(SPINNER_PATIENT_SCREEN_FETCH_VIRAL_LOADS)))
            : null,
          flat: true,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text('Last fetch: ${lastVLFetchDate ?? 'never'}', textAlign: TextAlign.center),
        ),
        _makeButton(
          'add manual entry',
          onPressed: _isFetchingViralLoads ? null : () { _addManualEntryPressed(_context, _patient); },
          flat: true,
        ),
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
        title: 'Participant',
        subtitle: _patient.artNumber,
        actions: <Widget>[IconButton(onPressed: () { Navigator.of(context).pop(); }, icon: Icon(Icons.close),)],
        child: content,
      ),
    );

  }

  Widget _buildRequiredActions() {

    final List<RequiredAction> visibleRequiredActionsSorted =_patient.calculateDueRequiredActions().toList();
    visibleRequiredActionsSorted.sort((RequiredAction a, RequiredAction b) => a.dueDate.isBefore(b.dueDate) ? -1 : 1);
    final actions = visibleRequiredActionsSorted.asMap().map((int i, RequiredAction action) {
      final mapEntry = MapEntry(
        i,
        RequiredActionContainer(
          action,
          i,
          _patient,
          animateDirection: shouldAnimateRequiredActionContainer[action.type],
          onAnimated: () {
            setState(() {});
          },
        ),
      );
      shouldAnimateRequiredActionContainer[action.type] = null;
      _patient.initializeRequiredActionsField();
      return mapEntry;
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
          explanation: 'Preference assessments are due every month for unsuppressed participants and every 3 months for suppressed participants.',
          button: _makeButton('Start Assessment', onPressed: () { _startAssessmentPressed(_context, _patient); }),
        ),
        SizedBox(height: _spacingBetweenCards),
        _buildNextActionRow(
          title: 'Next ART Refill',
          dueDate: _nextRefillText,
          explanation: 'The ART refill date is selected when the participant collects $pronoun ARTs or has them delivered.',
          button: _makeButton('Manage Refill', onPressed: () { _manageRefillPressed(_context, _patient, _nextRefillText); }),
        ),
        SizedBox(height: _spacingBetweenCards),
        _buildNextActionRow(
          title: 'Next Questionnaire',
          dueDate: _nextEndpointText,
          explanation: 'Adherence questionnaires are due 2.5–3.5 months, 5–8 '
              'months, and 9–15 months after participant enrollment. Quality of'
              ' Life questionnaires are due 5–8 months and 9–15 months after '
              'participant enrollment.',
          button: _makeButton('Open KoBoCollect', onPressed: _onOpenKoboCollectPressed),
        ),
        SizedBox(height: _spacingBetweenCards),
      ],
    );
  }

  _buildPatientCharacteristicsCard() {
    return _buildCard(
      title: 'Characterstics',
      child: Column(
        children: [
          _buildRow('Enrollment Date', formatDateConsistent(_patient.enrollmentDate)),
          _buildRow('ART Number', _patient.artNumber),
          _buildRow('Sticker Number', _patient.stickerNumber),
          _buildRow('Birthday', '${formatDateConsistent(_patient.birthday)} (age ${calculateAge(_patient.birthday)})'),
          _buildRow('Gender', _patient.gender.description),
          _buildRow('Sexual Orientation', _patient.sexualOrientation.description),
          _buildRow('Village', _patient.village),
          _buildRow('Phone Number', _patient.phoneNumber),
        ],
      ),
    );
  }

  _buildViralLoadHistoryCard() {

    final double _spaceBetweenColumns = 10.0;
    final double _sourceColumnWidth = 70.0;
    bool _hasAnyDiscrepancies() => _patient.viralLoads.any((ViralLoad vl) => vl.discrepancy ?? false);
    bool _vlWarningRequiredActionShowing() => _patient.requiredActions.any((RequiredAction a) => a.type == RequiredActionType.VIRAL_LOAD_DISCREPANCY_WARNING);
    bool _shouldDisplayWarningColumn() => _hasAnyDiscrepancies() && _vlWarningRequiredActionShowing();
    final double _warningColumnWidth = 25.0;

    Widget _buildViralLoadHeader() {
      Widget row = Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          children: <Widget>[
            Expanded(child: _formatHeaderRowText('Date Created / Fetched')),
            SizedBox(width: _spaceBetweenColumns),
            Expanded(child: _formatHeaderRowText('Date of Blood Draw')),
            SizedBox(width: _spaceBetweenColumns),
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: _formatHeaderRowText('Viral Load'),
              ),
            ),
            SizedBox(width: _spaceBetweenColumns),
            Expanded(child: _formatHeaderRowText('Lab Number')),
            SizedBox(width: _spaceBetweenColumns),
            SizedBox(
              width: _sourceColumnWidth,
              child: _formatHeaderRowText('Source'),
            ),
            _shouldDisplayWarningColumn() ? SizedBox(width: _spaceBetweenColumns) : SizedBox(),
            _shouldDisplayWarningColumn() ? SizedBox(width: _warningColumnWidth) : SizedBox(),
          ],
        ),
      );
      return row;
    }

    Widget _buildViralLoadRow(vl, {bool bold: false}) {

      final String description = '${formatDateConsistent(vl.dateOfBloodDraw)}';

      Widget _viralLoadIcon(ViralLoad vl) {
      final double vlIconSize = 25.0;
        if (vl.failed) {
          return _getPaddedIcon('assets/icons/viralload_failed.png', width: vlIconSize, height: vlIconSize);
        } else if (vl.isSuppressed) {
          return _getPaddedIcon('assets/icons/viralload_suppressed.png', width: vlIconSize, height: vlIconSize);
        } else if (!vl.isSuppressed) {
          return _getPaddedIcon('assets/icons/viralload_unsuppressed.png', width: vlIconSize, height: vlIconSize);
        }
        return Text('—');
      }
      Widget viralLoadBadge = ViralLoadBadge(vl, smallSize: false);

      String _vlText(ViralLoad vl) {
        if (vl.failed) {
          return 'failed';
        } else if (vl.isLowerThanDetectable) {
          return 'LTDL';
        }
        return '${vl.viralLoad} c/mL';
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(formatDateConsistent(vl.createdDate), style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal))),
            SizedBox(width: _spaceBetweenColumns),
            Expanded(child: Text(description, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal))),
            SizedBox(width: _spaceBetweenColumns),
            Expanded(
              child: Row(
                children:
                [
                  _viralLoadIcon(vl),
//              viralLoadBadge,
                  SizedBox(width: 5.0),
                  Text(_vlText(vl), style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
            ),
            SizedBox(width: _spaceBetweenColumns),
            Expanded(child: Text(vl.labNumber ?? '—', style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal))),
            SizedBox(width: _spaceBetweenColumns),
            SizedBox(
              width: _sourceColumnWidth,
              child: Text(vl.source == ViralLoadSource.MANUAL_INPUT() ? 'manual' : 'database', style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
            ),
            _shouldDisplayWarningColumn() ? SizedBox(width: _spaceBetweenColumns) : SizedBox(),
            _shouldDisplayWarningColumn() ? SizedBox(
              width: _warningColumnWidth,
              child: (vl.discrepancy ?? false) ? Icon(Icons.warning) : null,
            ) : SizedBox(),
          ],
        ),
      );
    }

    Widget content;

    if (_patient.viralLoads.length == 0) {
      content = Center(
        child: Text(
          "No viral load data available for this participant. Fetch data from the viral load database or add a new entry manually.",
          style: TextStyle(color: NO_DATA_TEXT),
        ),
      );
    } else {
      final int numOfVLs = _patient.viralLoads.length;
      final List<Map<String, dynamic>> vlsMarkedAsBold = [];
      // determine which viral load should be marked as bold (namely the last one)
      _patient.viralLoads.asMap().forEach((int i, ViralLoad vl) {
        vlsMarkedAsBold.add({'vl': vl, 'bold': numOfVLs > 1 && i == numOfVLs - 1});
      });
      // sort according to date of blood draw
      vlsMarkedAsBold.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
        ViralLoad a_vl = a['vl'];
        ViralLoad b_vl = b['vl'];
        return a_vl.dateOfBloodDraw.isBefore(b_vl.dateOfBloodDraw) ? -1 : 1;
      });
      // build widgets
      final viralLoads = vlsMarkedAsBold.map((Map<String, dynamic> m) {
        ViralLoad vl = m['vl'];
        bool bold = m['bold'];
        return _buildViralLoadRow(vl, bold: bold);
      }).toList();
      content = Column(children: <Widget>[
        _buildViralLoadHeader(),
        ...viralLoads,
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle('Viral Load History'),
        _buildExplanation('All available viral loads for this participant up to one '
            'year before the enrollment are listed here. The viral loads are sorted by their '
            'date of blood draw. The bold entry marks the currently active viral '
            'load.'),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 15.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 550.0,
                maxWidth: max(550.0, MediaQuery.of(context).size.width - 2 * 15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                child: content,
              ),
            ),
          ),
        ),
      ],
    );

  }

  _buildPreferencesCard() {

    Widget _buildSupportOptions() {
      final PreferenceAssessment _pa = _patient.latestPreferenceAssessment;
      final SupportPreferencesSelection sps = _pa.supportPreferences;
      final double iconWidth = 28.0;
      final double iconHeight = 28.0;
      if (sps.areAllDeselected) {
        return _buildRowWithWidget('Support',
          Row(
            children: [
            _getPaddedIcon('assets/icons/no_support.png', width: iconWidth, height: iconHeight),
            SizedBox(width: 5.0),
            Text(SupportOption.NONE().description),
            ],
          ),
        );
      }
      List<Widget> supportOptions = [];
      if (sps.NURSE_CLINIC_selected) {
        supportOptions.add(_buildSupportOption(
          SupportOption.NURSE_CLINIC().description,
          checkboxState: _pa.NURSE_CLINIC_done,
          doneText: 'done ${formatDateAndTimeTodayYesterday(_pa.NURSE_CLINIC_done_date)}',
          onChanged: (bool newState) {
            setState(() {
              _pa.set_NURSE_CLINIC_done(newState);
            });
            return;
          },
          icon: _getPaddedIcon('assets/icons/nurse_clinic.png', width: iconWidth, height: iconHeight, color: _pa.NURSE_CLINIC_done ? ICON_INACTIVE : ICON_ACTIVE),
        ));
      }
      if (sps.SATURDAY_CLINIC_CLUB_selected && _pa.saturdayClinicClubAvailable) {
        supportOptions.add(_buildSupportOption(
          SupportOption.SATURDAY_CLINIC_CLUB().description,
          checkboxState: _pa.SATURDAY_CLINIC_CLUB_done,
          doneText: 'done ${formatDateAndTimeTodayYesterday(_pa.SATURDAY_CLINIC_CLUB_done_date)}',
          onChanged: (bool newState) {
            setState(() {
              _pa.set_SATURDAY_CLINIC_CLUB_done(newState);
            });
            return;
          },
          icon: _getPaddedIcon('assets/icons/saturday_clinic_club.png', width: iconWidth, height: iconHeight, color: _pa.SATURDAY_CLINIC_CLUB_done ? ICON_INACTIVE : ICON_ACTIVE),
        ));
      }
      if (sps.COMMUNITY_YOUTH_CLUB_selected && _pa.communityYouthClubAvailable) {
        supportOptions.add(_buildSupportOption(
          SupportOption.COMMUNITY_YOUTH_CLUB().description,
          checkboxState: _pa.COMMUNITY_YOUTH_CLUB_done,
          doneText: 'done ${formatDateAndTimeTodayYesterday(_pa.COMMUNITY_YOUTH_CLUB_done_date)}',
          onChanged: (bool newState) {
            setState(() {
              _pa.set_COMMUNITY_YOUTH_CLUB_done(newState);
            });
            return;
          },
          icon: _getPaddedIcon('assets/icons/youth_club.png', width: iconWidth, height: iconHeight, color: _pa.COMMUNITY_YOUTH_CLUB_done ? ICON_INACTIVE : ICON_ACTIVE),
        ));
      }
      if (sps.PHONE_CALL_PE_selected) {
        supportOptions.add(_buildSupportOption(
          SupportOption.PHONE_CALL_PE().description,
          checkboxState: _pa.PHONE_CALL_PE_done,
          doneText: 'done ${formatDateAndTimeTodayYesterday(_pa.PHONE_CALL_PE_done_date)}',
          onChanged: (bool newState) {
            setState(() {
              _pa.set_PHONE_CALL_PE_done(newState);
            });
            return;
          },
          icon: _getPaddedIcon('assets/icons/phonecall_pe.png', width: iconWidth, height: iconHeight, color: _pa.PHONE_CALL_PE_done ? ICON_INACTIVE : ICON_ACTIVE),
        ));
      }
      if (sps.HOME_VISIT_PE_selected && _pa.homeVisitPEPossible) {
        supportOptions.add(_buildSupportOption(
          SupportOption.HOME_VISIT_PE().description,
          checkboxState: _pa.HOME_VISIT_PE_done,
          doneText: 'done ${formatDateAndTimeTodayYesterday(_pa.HOME_VISIT_PE_done_date)}',
          onChanged: (bool newState) {
            setState(() {
              _pa.set_HOME_VISIT_PE_done(newState);
            });
            return;
          },
          icon: _getPaddedIcon('assets/icons/homevisit_pe.png', width: iconWidth, height: iconHeight, color: _pa.HOME_VISIT_PE_done ? ICON_INACTIVE : ICON_ACTIVE),
        ));
      }
      if (sps.SCHOOL_VISIT_PE_selected && _pa.schoolVisitPEPossible) {
        String schoolNameAndVillage = _patient.latestPreferenceAssessment?.school;
        schoolNameAndVillage = schoolNameAndVillage == null ? '' : '\n($schoolNameAndVillage)';
        supportOptions.add(_buildSupportOption(
          SupportOption.SCHOOL_VISIT_PE().description + schoolNameAndVillage,
          checkboxState: _pa.SCHOOL_VISIT_PE_done,
          doneText: 'done ${formatDateAndTimeTodayYesterday(_pa.SCHOOL_VISIT_PE_done_date)}',
          onChanged: (bool newState) {
            setState(() {
              _pa.set_SCHOOL_VISIT_PE_done(newState);
            });
            return;
          },
          icon: _getPaddedIcon('assets/icons/schooltalk_pe.png', width: iconWidth, height: iconHeight, color: _pa.SCHOOL_VISIT_PE_done ? ICON_INACTIVE : ICON_ACTIVE),
        ));
      }
      if (sps.PITSO_VISIT_PE_selected && _pa.pitsoPEPossible) {
        supportOptions.add(_buildSupportOption(
          SupportOption.PITSO_VISIT_PE().description,
          checkboxState: _pa.PITSO_VISIT_PE_done,
          doneText: 'done ${formatDateAndTimeTodayYesterday(_pa.PITSO_VISIT_PE_done_date)}',
          onChanged: (bool newState) {
            setState(() {
              _pa.set_PITSO_VISIT_PE_done(newState);
            });
            return;
          },
          icon: _getPaddedIcon('assets/icons/pitso.png', width: iconWidth, height: iconHeight, color: _pa.PITSO_VISIT_PE_done ? ICON_INACTIVE : ICON_ACTIVE),
        ));
      }
      if (sps.CONDOM_DEMO_selected) {
        supportOptions.add(_buildSupportOption(
          SupportOption.CONDOM_DEMO().description,
          checkboxState: _pa.CONDOM_DEMO_done,
          doneText: 'done ${formatDateAndTimeTodayYesterday(_pa.CONDOM_DEMO_done_date)}',
          onChanged: (bool newState) {
            setState(() {
              _pa.set_CONDOM_DEMO_done(newState);
            });
            return;
          },
        ));
      }
      if (sps.CONTRACEPTIVES_INFO_selected) {
        String contraceptivesPerson = _patient.latestPreferenceAssessment?.moreInfoContraceptives;
        contraceptivesPerson = contraceptivesPerson == null ? '' : '\n($contraceptivesPerson)';
        supportOptions.add(_buildSupportOption(
          SupportOption.CONTRACEPTIVES_INFO().description + contraceptivesPerson,
          checkboxState: _pa.CONTRACEPTIVES_INFO_done,
          doneText: 'done ${formatDateAndTimeTodayYesterday(_pa.CONTRACEPTIVES_INFO_done_date)}',
          onChanged: (bool newState) {
            setState(() {
              _pa.set_CONTRACEPTIVES_INFO_done(newState);
            });
            return;
          },
        ));
      }
      if (sps.VMMC_INFO_selected) {
        String vmmcPerson = _patient.latestPreferenceAssessment?.moreInfoVMMC;
        vmmcPerson = vmmcPerson == null ? '' : '\n($vmmcPerson)';
        supportOptions.add(_buildSupportOption(
          SupportOption.VMMC_INFO().description + vmmcPerson,
          checkboxState: _pa.VMMC_INFO_done,
          doneText: 'done ${formatDateAndTimeTodayYesterday(_pa.VMMC_INFO_done_date)}',
          onChanged: (bool newState) {
            setState(() {
              _pa.set_VMMC_INFO_done(newState);
            });
            return;
          },
        ));
      }
      if (sps.YOUNG_MOTHERS_GROUP_selected && _pa.youngMothersAvailable) {
        supportOptions.add(_buildSupportOption(
          SupportOption.YOUNG_MOTHERS_GROUP().description,
          checkboxState: _pa.YOUNG_MOTHERS_GROUP_done,
          doneText: 'done ${formatDateAndTimeTodayYesterday(_pa.YOUNG_MOTHERS_GROUP_done_date)}',
          onChanged: (bool newState) {
            setState(() {
              _pa.set_YOUNG_MOTHERS_GROUP_done(newState);
            });
            return;
          },
        ));
      }
      if (sps.FEMALE_WORTH_GROUP_selected && _pa.femaleWorthAvailable) {
        supportOptions.add(_buildSupportOption(
          SupportOption.FEMALE_WORTH_GROUP().description,
          checkboxState: _pa.FEMALE_WORTH_GROUP_done,
          doneText: 'done ${formatDateAndTimeTodayYesterday(_pa.FEMALE_WORTH_GROUP_done_date)}',
          onChanged: (bool newState) {
            setState(() {
              _pa.set_FEMALE_WORTH_GROUP_done(newState);
            });
            return;
          },
        ));
      }
      if (sps.LEGAL_AID_INFO_selected) {
        supportOptions.add(_buildSupportOption(
          SupportOption.LEGAL_AID_INFO().description,
          checkboxState: _pa.LEGAL_AID_INFO_done,
          doneText: 'done ${formatDateAndTimeTodayYesterday(_pa.LEGAL_AID_INFO_done_date)}',
          onChanged: (bool newState) {
            setState(() {
              _pa.set_LEGAL_AID_INFO_done(newState);
            });
            return;
          },
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
            "No preferences available for this participant. Start a new preference assessment below.",
            style: TextStyle(
              color: NO_DATA_TEXT,
            ),
          ),
        );
      } else {

        Widget _vhwInfo() {
          ARTRefillOption lastOption = _patient.latestPreferenceAssessment.lastRefillOption;
          if (lastOption == null || lastOption != ARTRefillOption.VHW()) {
            return Container();
          }
          return Column(
              children: [
                _buildRow('VHW Name', _patient.latestPreferenceAssessment.artRefillVHWName),
                _buildRow("VHW's Village", _patient.latestPreferenceAssessment.artRefillVHWVillage),
                _buildRow("VHW's Phone Number", _patient.latestPreferenceAssessment.artRefillVHWPhoneNumber),
              ],
          );
        }

        Widget _treatmentBuddyInfo() {
          ARTRefillOption lastOption = _patient.latestPreferenceAssessment.lastRefillOption;
          if (lastOption == null || lastOption != ARTRefillOption.TREATMENT_BUDDY()) {
            return Container();
          }
          return Column(
            children: [
              _buildRow("Treatment Buddy's ART Nr.", _patient.latestPreferenceAssessment.artRefillTreatmentBuddyART),
              _buildRow("Treatment Buddy's Village", _patient.latestPreferenceAssessment.artRefillTreatmentBuddyVillage),
              _buildRow("Treatment Buddy's Phone Number", _patient.latestPreferenceAssessment.artRefillTreatmentBuddyPhoneNumber),
            ],
          );
        }

        Widget _adherenceReminderInfo() {
          bool enabled = _patient.latestPreferenceAssessment.adherenceReminderEnabled;
          if (enabled == null || !enabled) {
            return _buildRow('Adherence Reminders', 'not wished');
          }
          return Column(
            children: [
              _buildRow('Adherence Reminder Frequency', _patient.latestPreferenceAssessment.adherenceReminderFrequency?.description),
              _buildRow('Adherence Reminder Notification Time', formatTime(_patient.latestPreferenceAssessment.adherenceReminderTime)),
              _buildRow('Adherence Reminder Message', _patient.latestPreferenceAssessment.adherenceReminderMessage?.description),
            ],
          );
        }

        Widget _refillReminderInfo() {
          bool enabled = _patient.latestPreferenceAssessment.artRefillReminderEnabled;
          if (enabled == null || !enabled) {
            return _buildRow('ART Refill Reminders', 'not wished');
          }
          return Column(
            children: [
              _buildRow('ART Refill Reminder Time', _patient.latestPreferenceAssessment.artRefillReminderDaysBefore?.description),
              _buildRow('ART Refill Reminder Message', _patient.latestPreferenceAssessment.artRefillReminderMessage?.description),
            ],
          );
        }

        Widget _vlNotificationInfo() {
          bool enabled = _patient.latestPreferenceAssessment.vlNotificationEnabled;
          if (enabled == null || !enabled) {
            return _buildRow('Viral Load Notifications', 'not wished');
          }
          return Column(
            children: [
              _buildRow('Viral Load Message (suppressed)', _patient.latestPreferenceAssessment.vlNotificationMessageSuppressed?.description),
              _buildRow('Viral Load Message (unsuppressed)', _patient.latestPreferenceAssessment.vlNotificationMessageUnsuppressed?.description),
            ],
          );
        }

        final double _spacingBetweenPreferences = 20.0;
        final double _spacingBetweenNotificationsInfos = 10.0;
        Widget _notificationsInfo() {
          if (!_patient.latestPreferenceAssessment.patientPhoneAvailable) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Text(
                'The participant did not have a phone with a Lesotho phone number at the time of the preference assessment. Thus, no notifications are sent to the participant.',
                style: TextStyle(color: TEXT_INACTIVE),
                textAlign: TextAlign.center,
              ),
            );
          }
          return Column(
            children: <Widget>[
              _adherenceReminderInfo(),
              SizedBox(height: _spacingBetweenNotificationsInfos),
              _refillReminderInfo(),
              SizedBox(height: _spacingBetweenNotificationsInfos),
              _vlNotificationInfo(),
            ],
          );
        }

        Widget _psychosocialSupportInfo() {
          final YesNoRefused answer = _patient.latestPreferenceAssessment.psychosocialShareSomethingAnswer;
          final bool shareSomething = answer != null && answer == YesNoRefused.YES();
          return Column(
            children: [
              _buildRow('Did the participant want to share something?', answer.description),
              shareSomething ? _buildRow('The participant shared:', _patient.latestPreferenceAssessment.psychosocialShareSomethingContent) : Container(),
              _buildRow('How was the participant doing?', _patient.latestPreferenceAssessment.psychosocialHowDoing),
            ],
          );
        }

        Widget _unsuppressedVlInfo() {
          final YesNoRefused answer = _patient.latestPreferenceAssessment.unsuppressedSafeEnvironmentAnswer;
          if (answer == null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Text(
                'The participant was suppressed at the time of the preference assessment. Thus, this section was not covered during the assessment.',
                style: TextStyle(color: TEXT_INACTIVE),
                textAlign: TextAlign.center,
              ),
            );
          }
          final bool notSafe = answer == YesNoRefused.NO();
          return Column(
            children: [
              _buildRow('Does the participant have a safe environment to take the medication?', answer.description),
              notSafe ? _buildRow('Why is the environment not safe?', _patient.latestPreferenceAssessment.unsuppressedWhyNotSafe) : Container(),
            ],
          );
        }

        return Column(
          children: [
            SizedBox(height: 5.0),
            _buildSubtitle('ART Refill'), Divider(),
            _buildRow('ART Refill', _patient.latestPreferenceAssessment.lastRefillOption?.description),
            _vhwInfo(),
            _treatmentBuddyInfo(),
            _buildRow('ART Supply Amount', _patient.latestPreferenceAssessment.artSupplyAmount?.description),
            SizedBox(height: _spacingBetweenPreferences),
            _buildSubtitle('Notifications'), Divider(),
            _notificationsInfo(),
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

    final PreferenceAssessment lastestPA = _patient.latestPreferenceAssessment;
    return _buildCard(
      title: 'Preferences',
      explanationText: lastestPA == null ? null : 'These are the participant\'s preferences as specified in the last preference assessment from ${formatDateAndTimeTodayYesterday(_patient.latestPreferenceAssessment.createdDate)}.',
      child: Container(
        width: double.infinity,
        child: _buildPreferencesCardContent(),
      ),
    );

  }


  /*
   * Helper Functions
   */

  Widget _buildCard({@required Widget child, String title, String explanationText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (title == null || title == '') ? Container() : _buildTitle(title),
        (explanationText == null || explanationText == '') ? Container() : _buildExplanation(explanationText),
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

  Widget _buildExplanation(String explanation) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
      child: Text(
        explanation,
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
    setState(() { _isFetchingViralLoads = true; });
    List<ViralLoad> viralLoadsFromDB;
    String message = 'No new viral loads found.';
    String title = 'Viral Loads Fetched';
    bool error = false;
    VoidCallback onNotificationButtonPress;
    try {
      viralLoadsFromDB = await downloadViralLoadsFromDatabase(patient);
      final DateTime fetchedDate = DateTime.now();
      for (ViralLoad vl in viralLoadsFromDB) {
        await DatabaseProvider().insertViralLoad(vl, createdDate: fetchedDate);
      }
      final int oldEntries = patient.viralLoads.length;
      patient.addViralLoads(viralLoadsFromDB);
      final int newEntries = patient.viralLoads.length - oldEntries;
      if (newEntries > 0) {
        message = '$newEntries new viral load result${newEntries > 1 ? 's' : ''} found.';
      }
      await storeLatestViralLoadFetchInSharedPrefs(patient.artNumber);
      lastVLFetchDate = formatDateAndTime(DateTime.now());
      final bool discrepancyFound = await checkForViralLoadDiscrepancies(patient);
      if (discrepancyFound) {
      }
    } catch (e, s) {
      error = true;
      title = 'Viral Load Fetch Failed';
      switch (e.runtimeType) {
        case VisibleImpactLoginFailedException:
          message = 'Login to VisibleImpact failed. Contact the development team.';
          break;
        case MultiplePatientsException:
          message = e.message;
          break;
        case SocketException:
          message = 'Make sure you are connected to the internet.';
          break;
        default:
          message = 'An unknown error occured. Contact the development team.';
          print('${e.runtimeType}: $e');
          print(s);
          onNotificationButtonPress = () {
            showErrorInPopup(e, s, context);
          };
      }
    }
    setState(() { _isFetchingViralLoads = false; });
    showFlushbar(message, title: title, error: error, onButtonPress: onNotificationButtonPress);
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
    await openKoboCollectApp();
  }

  Widget _makeButton(String buttonText, {Function() onPressed, bool flat: false, Widget widget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        flat
            ? PEBRAButtonFlat(buttonText, onPressed: onPressed, widget: widget)
            : PEBRAButtonRaised(buttonText, onPressed: onPressed, widget: widget),
      ],
    );
  }

}
