import 'package:flutter/material.dart';
import 'package:pebrapp/components/SizedButton.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/Utils.dart';

class PreferenceAssessmentScreen extends StatelessWidget {
  final String _patientART;

  PreferenceAssessmentScreen(this._patientART);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 224, 224, 224),
        appBar: AppBar(
          title: Text('Preference Assessment: ${this._patientART}'),
        ),
        body: Center(child: PreferenceAssessmentForm(_patientART)));
  }
}

class PreferenceAssessmentForm extends StatefulWidget {
  final String _patientART;

  PreferenceAssessmentForm(this._patientART);

  @override
  createState() => _PreferenceAssessmentFormState(_patientART);
}

class _PreferenceAssessmentFormState extends State<PreferenceAssessmentForm> {
  // fields
  final _formKey = GlobalKey<FormState>();
  PreferenceAssessment _pa = PreferenceAssessment.uninitialized();
  final _artRefillOptionSelections = List<ARTRefillOption>(4);
  final _artRefillOptionPersonAvailableSelections = List<bool>(3);
  int _questionsFlex = 3;
  int _answersFlex = 1;
  // TODO: add all necessary controller that we need to get the text from the form fields
  var _artRefillOptionPersonNameCtr = TextEditingController();
  var _artRefillOptionPersonPhoneNumberCtr = TextEditingController();
  var _patientPhoneNumberCtr = TextEditingController();
  var _adherenceReminderTimeCtr = TextEditingController();
  var _pePhoneNumberCtr = TextEditingController();

  // constructor
  _PreferenceAssessmentFormState(String patientART) {
    _pa.patientART = patientART;
  }

  /// Returns true for VHW, Treatment Buddy, Community Adherence Club selections.
  bool _availabilityRequiredForSelection(int currentOption) {
    final availabilityRequiredOptions = [
      ARTRefillOption.VHW,
      ARTRefillOption.TREATMENT_BUDDY,
      ARTRefillOption.COMMUNITY_ADHERENCE_CLUB,
    ];
    final currentSelection = _artRefillOptionSelections[currentOption];
    if (currentSelection == null) {
      return false;
    }
    return availabilityRequiredOptions.contains(currentSelection);
  }

  /// Returns true if the previously selected ART Refill Option is one of VHW,
  /// Treatment Buddy, or Community Adherence Club and that option has been
  /// selected as not available.
  bool _additionalARTRefillOptionRequired(int currentOption) {
    if (currentOption < 1) {
      return true;
    }
    final previousOptionAvailable = _artRefillOptionPersonAvailableSelections[currentOption - 1];
    if (previousOptionAvailable == null) {
      return false;
    }
    return (_availabilityRequiredForSelection(currentOption - 1) &&
        !previousOptionAvailable);
  }

  /// Checks if the name and phone number input fields in the ART Refill card
  /// are required.
  bool _namePhoneNumberRequired() {
    ARTRefillOption lastSelection;
    for (ARTRefillOption selection in _artRefillOptionSelections) {
      if (selection != null) {
        lastSelection = selection;
      }
    }
    final namePhoneNumberRequiredSelections = [
      ARTRefillOption.VHW,
      ARTRefillOption.TREATMENT_BUDDY,
      ARTRefillOption.COMMUNITY_ADHERENCE_CLUB,
    ];
    final lastSelectionPosition = _artRefillOptionSelections.indexOf(lastSelection);
    final availabilityForLastSelection = _artRefillOptionPersonAvailableSelections[lastSelectionPosition] ?? false;
    return (lastSelection != null &&
        namePhoneNumberRequiredSelections.contains(lastSelection) &&
        availabilityForLastSelection
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: ListView(
      children: <Widget>[
        _buildTitle('ART Refill'),
        _buildARTRefillCard(),
        _buildTitle('Notifications'),
        _buildNotificationsCard(),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [SizedButton('Export')]),
        _buildTitle('Support'),
        _buildSupportCard(),
        _buildTitle('EAC (Enhanced Adherence Counseling)'),
        _buildEACCard(),

        Center(child: _buildTitle('Next Preference Assessment')),
        Center(child: Text(formatDate(calculateNextAssessment(DateTime.now())))),
        Container(height: 50), // padding at bottom
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedButton(
            'Save',
            onPressed: _onSubmitForm,
          )
        ]),
        Container(height: 50), // padding at bottom
      ],
    )
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

  _buildARTRefillCard() {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: [
                _artRefillOption(0),
                _artRefillOptionPersonAvailableRow(0),
                _artRefillOption(1),
                _artRefillOptionPersonAvailableRow(1),
                _artRefillOption(2),
                _artRefillOptionPersonAvailableRow(2),
                _artRefillOption(3),
                _artRefillOptionPersonName(),
                _artRefillOptionPersonNumber(),
              ],
            )));
  }

  Widget _artRefillOption(int optionNumber) {
    if (!_additionalARTRefillOptionRequired(optionNumber)) {
      return Container();
    }
    var displayValue = _artRefillOptionSelections[optionNumber];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child:
            optionNumber == 0 ?
            Text('How and where do you want to refill your ART mainly?') :
            Text('Choose another option additionally')),
        Expanded(
            flex: _answersFlex,
            child: DropdownButtonFormField<ARTRefillOption>(
              value: displayValue,
              onChanged: (ARTRefillOption newValue) {
                setState(() {
                  _artRefillOptionSelections[optionNumber] = newValue;
                });
              },
              validator: (value) {
                if (value == null) { return 'Please answer this question'; }
              },
              items: <ARTRefillOption>[
                ARTRefillOption.CLINIC,
                ARTRefillOption.COMMUNITY_ADHERENCE_CLUB,
                ARTRefillOption.PE_HOME_DELIVERY,
                ARTRefillOption.TREATMENT_BUDDY,
                ARTRefillOption.VHW
              ].map<DropdownMenuItem<ARTRefillOption>>((ARTRefillOption value) {
                String description = artRefillOptionToString(value);
                return DropdownMenuItem<ARTRefillOption>(
                  value: value,
                  child: Text(description),
                );
              }).toList(),
            ))
      ],
    );
  }

  Widget _artRefillOptionPersonAvailableRow(int optionNumber) {
    if (!_availabilityRequiredForSelection(optionNumber)) {
      return Container();
    }
    var displayValue = _artRefillOptionPersonAvailableSelections[optionNumber];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child: Text('Is there a VHW available nearby?')),
        Expanded(
            flex: _answersFlex,
            child: DropdownButtonFormField<bool>(
              value: displayValue,
              onChanged: (bool newValue) {
                setState(() {
                  _artRefillOptionPersonAvailableSelections[optionNumber] = newValue;
                });
              },
              validator: (value) {
                if (value == null) { return 'Please answer this question'; }
              },
              items:
                  <bool>[true, false].map<DropdownMenuItem<bool>>((bool value) {
                String description;
                switch (value) {
                  case true:
                    description = 'Yes';
                    break;
                  case false:
                    description = 'No';
                    break;
                }
                return DropdownMenuItem<bool>(
                  value: value,
                  child: Text(description),
                );
              }).toList(),
            ))
      ],
    );
  }

  _artRefillOptionPersonName() {
    if (!_namePhoneNumberRequired()) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child:
            Text('VHW Name')),
        Expanded(
            flex: _answersFlex,
            child: TextFormField(
              controller: _artRefillOptionPersonNameCtr,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a name';
                }
              },
            ),)
      ],
    );
  }

  _artRefillOptionPersonNumber() {
    if (!_namePhoneNumberRequired()) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child:
            Text('VHW Phone Number')),
        Expanded(
          flex: _answersFlex,
          child: TextFormField(
            controller: _artRefillOptionPersonPhoneNumberCtr,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a phone number';
              }
            },
          ),)
      ],
    );
  }

  _buildNotificationsCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            _phoneAvailableQuestion(),
            _phoneNumberPatientQuestion(),
            _adherenceReminderSubtitle(),
            _adherenceReminderQuestion(),
            _adherenceReminderFrequencyQuestion(),
            _adherenceReminderTimeQuestion(),
            _adherenceReminderMessageQuestion(),
            _artRefillReminderSubtitle(),
            _artRefillReminderQuestion(),
            _artRefillReminderDaysBeforeQuestion(),
            _viralLoadNotificationSubtitle(),
            _viralLoadNotificationQuestion(),
            _viralLoadMessageSuppressedQuestion(),
            _viralLoadMessageUnsuppressedQuestion(),
            _phoneNumberPEPadding(),
            _phoneNumberPEQuestion(),
          ],
        ),
      ),
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

  Row _phoneAvailableQuestion() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child: Text(
                'Do you have regular access to a phone where you can receive confidential information?')),
        Expanded(
            flex: _answersFlex,
            child: DropdownButtonFormField<bool>(
              value: _pa.phoneAvailable,
              onChanged: (bool newValue) {
                setState(() {
                  _pa.phoneAvailable = newValue;
                });
              },
              validator: (value) {
                if (value == null) { return 'Please answer this question'; }
              },
              items:
                  <bool>[true, false].map<DropdownMenuItem<bool>>((bool value) {
                String description;
                switch (value) {
                  case true:
                    description = 'Yes';
                    break;
                  case false:
                    description = 'No';
                    break;
                }
                return DropdownMenuItem<bool>(
                  value: value,
                  child: Text(description),
                );
              }).toList(),
            ))
      ],
    );
  }

  Widget _phoneNumberPatientQuestion() {
    if (_pa.phoneAvailable == null || !_pa.phoneAvailable) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child:
            Text('Patient Phone Number')),
        Expanded(
          flex: _answersFlex,
          child: TextFormField(
            controller: _patientPhoneNumberCtr,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a phone number';
              }
            },
          ),)
      ],
    );
  }

  Widget _adherenceReminderSubtitle() {
    if (_pa.phoneAvailable == null || !_pa.phoneAvailable) {
      return Container();
    }
    return _makeSubtitle('Adherence Reminder');
  }

  Widget _adherenceReminderQuestion() {
    if (_pa.phoneAvailable == null || !_pa.phoneAvailable) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child: Text('Do you want to receive adherence reminders?')),
        Expanded(
            flex: _answersFlex,
            child: DropdownButtonFormField<bool>(
              value: _pa.adherenceReminderEnabled,
              onChanged: (bool newValue) {
                setState(() {
                  _pa.adherenceReminderEnabled = newValue;
                });
              },
              validator: (value) {
                if (value == null) { return 'Please answer this question'; }
              },
              items:
              <bool>[true, false].map<DropdownMenuItem<bool>>((bool value) {
                String description;
                switch (value) {
                  case true:
                    description = 'Yes';
                    break;
                  case false:
                    description = 'No';
                    break;
                }
                return DropdownMenuItem<bool>(
                  value: value,
                  child: Text(description),
                );
              }).toList(),
            ))
      ],
    );
  }

  Widget _adherenceReminderFrequencyQuestion() {
    if (_pa.phoneAvailable == null || !_pa.phoneAvailable ||
        _pa.adherenceReminderEnabled == null || !_pa.adherenceReminderEnabled) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child:
            Text('How often do you want to receive adherence reminders?')),
        Expanded(
            flex: _answersFlex,
            child: DropdownButtonFormField<AdherenceReminderFrequency>(
              value: _pa.adherenceReminderFrequency,
              onChanged: (AdherenceReminderFrequency newValue) {
                setState(() {
                  _pa.adherenceReminderFrequency = newValue;
                });
              },
              validator: (value) {
                if (value == null) { return 'Please answer this question'; }
              },
              items: AdherenceReminderFrequency.values.map<DropdownMenuItem<AdherenceReminderFrequency>>((AdherenceReminderFrequency value) {
                String description = adherenceReminderFrequencyToString(value);
                return DropdownMenuItem<AdherenceReminderFrequency>(
                  value: value,
                  child: Text(description),
                );
              }).toList(),
            ))
      ],
    );
  }

  Widget _adherenceReminderTimeQuestion() {
    if (_pa.phoneAvailable == null || !_pa.phoneAvailable ||
        _pa.adherenceReminderEnabled == null || !_pa.adherenceReminderEnabled) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child:
            Text('When during the day do you want to receive the adherence reminder?')),
        Expanded(
          flex: _answersFlex,
          child: TextFormField(
            controller: _adherenceReminderTimeCtr,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a phone number';
              }
            },
          ),)
      ],
    );
  }

  Widget _adherenceReminderMessageQuestion() {
    if (_pa.phoneAvailable == null || !_pa.phoneAvailable ||
        _pa.adherenceReminderEnabled == null || !_pa.adherenceReminderEnabled) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child:
            Text('Which adherence reminder do you want to receive?')),
        Expanded(
            flex: _answersFlex,
            child: DropdownButtonFormField<AdherenceReminderMessage>(
              value: _pa.adherenceReminderMessage, // TODO
              onChanged: (AdherenceReminderMessage newValue) {
                setState(() {
                  _pa.adherenceReminderMessage = newValue;
                });
              },
              validator: (value) {
                if (value == null) { return 'Please answer this question'; }
              },
              items: AdherenceReminderMessage.values.map<DropdownMenuItem<AdherenceReminderMessage>>((AdherenceReminderMessage value) {
                String description = adherenceReminderMessageToString(value);
                return DropdownMenuItem<AdherenceReminderMessage>(
                  value: value,
                  child: Text(description),
                );
              }).toList(),
            ))
      ],
    );
  }

  Widget _artRefillReminderSubtitle() {
    if (_pa.phoneAvailable == null || !_pa.phoneAvailable) {
      return Container();
    }
    return _makeSubtitle('ART Refill Reminder');
  }

  Widget _artRefillReminderQuestion() {
    if (_pa.phoneAvailable == null || !_pa.phoneAvailable) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child: Text('Do you want to receive ART refill reminders?')),
        Expanded(
            flex: _answersFlex,
            child: DropdownButtonFormField<bool>(
              value: _pa.artRefillReminderEnabled, // TODO
              onChanged: (bool newValue) {
                setState(() {
                  _pa.artRefillReminderEnabled = newValue;
                });
              },
              validator: (value) {
                if (value == null) { return 'Please answer this question'; }
              },
              items:
              <bool>[true, false].map<DropdownMenuItem<bool>>((bool value) {
                String description;
                switch (value) {
                  case true:
                    description = 'Yes';
                    break;
                  case false:
                    description = 'No';
                    break;
                }
                return DropdownMenuItem<bool>(
                  value: value,
                  child: Text(description),
                );
              }).toList(),
            ))
      ],
    );
  }

  Widget _artRefillReminderDaysBeforeQuestion() {
    if (_pa.phoneAvailable == null || !_pa.phoneAvailable ||
        _pa.artRefillReminderEnabled == null || !_pa.artRefillReminderEnabled) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child: Text('How many days before would you like to receive the reminder?')),
        Expanded(
            flex: _answersFlex,
            // TODO: replace with a number picker dropdown
            child: Container(height: 45,))
      ],
    );
  }

  Widget _viralLoadNotificationSubtitle() {
    if (_pa.phoneAvailable == null || !_pa.phoneAvailable) {
      return Container();
    }
    return _makeSubtitle('Viral Load Notification');
  }

  Widget _viralLoadNotificationQuestion() {
    if (_pa.phoneAvailable == null || !_pa.phoneAvailable) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child: Text('Do you want to receive a notification after a VL measurement?')),
        Expanded(
            flex: _answersFlex,
            child: DropdownButtonFormField<bool>(
              value: _pa.vlNotificationEnabled,
              onChanged: (bool newValue) {
                setState(() {
                  _pa.vlNotificationEnabled = newValue;
                });
              },
              validator: (value) {
                if (value == null) { return 'Please answer this question'; }
              },
              items:
              <bool>[true, false].map<DropdownMenuItem<bool>>((bool value) {
                String description;
                switch (value) {
                  case true:
                    description = 'Yes';
                    break;
                  case false:
                    description = 'No';
                    break;
                }
                return DropdownMenuItem<bool>(
                  value: value,
                  child: Text(description),
                );
              }).toList(),
            ))
      ],
    );
  }

  Widget _viralLoadMessageSuppressedQuestion() {
    if (_pa.phoneAvailable == null || !_pa.phoneAvailable ||
        _pa.vlNotificationEnabled == null || !_pa.vlNotificationEnabled) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child:
            Text('Which message do you want to receive if VL is suppressed?')),
        Expanded(
            flex: _answersFlex,
            child: DropdownButtonFormField<VLSuppressedMessage>(
              value: _pa.vlNotificationMessageSuppressed,
              onChanged: (VLSuppressedMessage newValue) {
                setState(() {
                  _pa.vlNotificationMessageSuppressed = newValue;
                });
              },
              validator: (value) {
                if (value == null) { return 'Please answer this question'; }
              },
              items: VLSuppressedMessage.values.map<DropdownMenuItem<VLSuppressedMessage>>((VLSuppressedMessage value) {
                String description = vlSuppressedMessageToString(value);
                return DropdownMenuItem<VLSuppressedMessage>(
                  value: value,
                  child: Text(description),
                );
              }).toList(),
            ))
      ],
    );
  }

  Widget _viralLoadMessageUnsuppressedQuestion() {
    if (_pa.phoneAvailable == null || !_pa.phoneAvailable ||
        _pa.vlNotificationEnabled == null || !_pa.vlNotificationEnabled) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child:
            Text('Which message do you want to receive if VL is unsuppressed?')),
        Expanded(
            flex: _answersFlex,
            child: DropdownButtonFormField<VLUnsuppressedMessage>(
              value: _pa.vlNotificationMessageUnsuppressed,
              onChanged: (VLUnsuppressedMessage newValue) {
                setState(() {
                  _pa.vlNotificationMessageUnsuppressed = newValue;
                });
              },
              validator: (value) {
                if (value == null) { return 'Please answer this question'; }
              },
              items: VLUnsuppressedMessage.values.map<DropdownMenuItem<VLUnsuppressedMessage>>((VLUnsuppressedMessage value) {
                String description = vlUnsuppressedMessageToString(value);
                return DropdownMenuItem<VLUnsuppressedMessage>(
                  value: value,
                  child: Text(description),
                );
              }).toList(),
            ))
      ],
    );
  }

  Widget _phoneNumberPEPadding() {
    if (_pa.phoneAvailable == null || !_pa.phoneAvailable) {
      return Container();
    }
    return Container(height: 20,);
  }

  Widget _phoneNumberPEQuestion() {
    if (_pa.phoneAvailable == null || !_pa.phoneAvailable) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child:
            Text('PE Phone Number')),
        Expanded(
          flex: _answersFlex,
          child: TextFormField(
            controller: _pePhoneNumberCtr,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a phone number';
              }
            },
          ),)
      ],
    );
  }

  _buildSupportCard() {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: [
              _supportPreferencesQuestion(),
            ],
          ),
        ));
  }

  Column _supportPreferencesQuestion() {
    return Column(children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(
              flex: _questionsFlex,
              child: Text(
                  'What kind of support do you mainly wish? (tick all that apply)')),
          Expanded(
            flex: _answersFlex,
            child: CheckboxListTile(
                // secondary: const Icon(Icons.local_hospital),
                title: Text(SupportPreferencesSelection.saturdayClinicClubDescription),
//                  dense: true,
                value: _pa.supportPreferences.saturdayClinicClubSelected,
                onChanged: (bool newValue) => this.setState(() {
                      _pa.supportPreferences.saturdayClinicClubSelected =
                          newValue;
                    })),
          )
        ],
      ),
      Row(
        children: <Widget>[
          Expanded(flex: _questionsFlex, child: Container()),
          Expanded(
            flex: _answersFlex,
            child: CheckboxListTile(
                // secondary: const Icon(Icons.local_hospital),
                title: Text(SupportPreferencesSelection.communityYouthClubDescription),
//                  dense: true,
                value: _pa.supportPreferences.communityYouthClubSelected,
                onChanged: (bool newValue) => this.setState(() {
                      _pa.supportPreferences.communityYouthClubSelected =
                          newValue;
                    })),
          )
        ],
      ),
      Row(
        children: <Widget>[
          Expanded(flex: _questionsFlex, child: Container()),
          Expanded(
            flex: _answersFlex,
            child: CheckboxListTile(
                // secondary: const Icon(Icons.local_hospital),
                title: Text(SupportPreferencesSelection.phoneCallPEDescription),
//                  dense: true,
                value: _pa.supportPreferences.phoneCallPESelected,
                onChanged: (bool newValue) => this.setState(() {
                      _pa.supportPreferences.phoneCallPESelected = newValue;
                    })),
          )
        ],
      ),
      Row(
        children: <Widget>[
          Expanded(flex: _questionsFlex, child: Container()),
          Expanded(
            flex: _answersFlex,
            child: CheckboxListTile(
                // secondary: const Icon(Icons.local_hospital),
                title: Text(SupportPreferencesSelection.homeVisitPEDescription),
//                  dense: true,
                value: _pa.supportPreferences.homeVisitPESelected,
                onChanged: (bool newValue) => this.setState(() {
                      _pa.supportPreferences.homeVisitPESelected = newValue;
                    })),
          )
        ],
      ),
      Row(
        children: <Widget>[
          Expanded(flex: _questionsFlex, child: Container()),
          Expanded(
            flex: _answersFlex,
            child: CheckboxListTile(
                // secondary: const Icon(Icons.local_hospital),
                title: Text(SupportPreferencesSelection.nurseAtClinicDescription),
//                  dense: true,
                value: _pa.supportPreferences.nurseAtClinicSelected,
                onChanged: (bool newValue) => this.setState(() {
                      _pa.supportPreferences.nurseAtClinicSelected = newValue;
                    })),
          )
        ],
      ),
      Row(
        children: <Widget>[
          Expanded(flex: _questionsFlex, child: Container()),
          Expanded(
            flex: _answersFlex,
            child: CheckboxListTile(
              // secondary: const Icon(Icons.local_hospital),
                title: Text(SupportPreferencesSelection.schoolTalkPEDescription),
//                  dense: true,
                value: _pa.supportPreferences.schoolTalkPESelected,
                onChanged: (bool newValue) => this.setState(() {
                  _pa.supportPreferences.schoolTalkPESelected = newValue;
                })),
          )
        ],
      ),
      Row(
        children: <Widget>[
          Expanded(flex: _questionsFlex, child: Container()),
          Expanded(
            flex: _answersFlex,
            child: CheckboxListTile(
                // secondary: const Icon(Icons.local_hospital),
                title: Text(SupportPreferencesSelection.noneDescription),
//                  dense: true,
                value: _pa.supportPreferences.areAllDeselected,
                onChanged: (bool newValue) {
                  if (newValue) {
                    this.setState(() {
                      _pa.supportPreferences.deselectAll();
                    });
                  }
                }),
          )
        ],
      ),
    ]);
  }

  _buildEACCard() {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
          children: [
            _eacSupportOption(),
      ],
    ),
        ));
  }

  Row _eacSupportOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child:
            Text('In case of unsuppressed VL, how do you want your EAC?')),
        Expanded(
            flex: _answersFlex,
            child: DropdownButtonFormField<EACOption>(
              value: _pa.eacOption,
              onChanged: (EACOption newValue) {
                setState(() {
                  _pa.eacOption = newValue;
                });
              },
              validator: (value) {
                if (value == null) { return 'Please answer this question'; }
              },
              items: EACOption.values.map<DropdownMenuItem<EACOption>>((EACOption value) {
                String description = eacOptionToString(value);
                return DropdownMenuItem<EACOption>(
                  value: value,
                  child: Text(description),
                );
              }).toList(),
            ))
      ],
    );
  }

  _onSubmitForm() async {
    if (_formKey.currentState.validate()) {
      _pa.artRefillOption1 = _artRefillOptionSelections[0];
      _pa.artRefillOption2 = _artRefillOptionSelections[1];
      _pa.artRefillOption3 = _artRefillOptionSelections[2];
      _pa.artRefillOption4 = _artRefillOptionSelections[3];
      print(
          'NEW PREFERENCE ASSESSMENT (_id will be given by SQLite database):\n$_pa');
      await PatientBloc.instance.sinkPreferenceAssessmentData(_pa);
      Navigator.of(context).pop(); // close Preference Assessment screen
      showFlushBar(context, 'Preference Assessment saved');
    } else {
      showFlushBar(context, "Errors exist in the assessment form. Please check the form.");
    }
  }
}
