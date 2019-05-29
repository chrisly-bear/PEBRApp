import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/database/beans/ARTRefillReminderMessage.dart';
import 'package:pebrapp/database/beans/ARTSupplyAmount.dart';
import 'package:pebrapp/database/beans/PEHomeDeliveryNotPossibleReason.dart';
import 'package:pebrapp/database/beans/SupportPreferencesSelection.dart';
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
  int _questionsFlex = 1;
  int _answersFlex = 1;

  PreferenceAssessment _pa = PreferenceAssessment.uninitialized();
  final _artRefillOptionSelections = List<ARTRefillOption>(5);
  final _artRefillOptionAvailable = List<bool>(4);
  var _peHomeDeliverWhyNotPossibleReasonOtherCtr = TextEditingController();
  var _vhwNameCtr = TextEditingController();
  var _vhwVillageCtr = TextEditingController();
  var _vhwPhoneNumberCtr = TextEditingController();
  var _treatmentBuddyARTNumberCtr = TextEditingController();
  var _treatmentBuddyVillageCtr = TextEditingController();
  var _treatmentBuddyPhoneNumberCtr = TextEditingController();
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
      ARTRefillOption.PE_HOME_DELIVERY,
      ARTRefillOption.VHW,
      ARTRefillOption.TREATMENT_BUDDY,
      ARTRefillOption.COMMUNITY_ADHERENCE_CLUB,
    ];
    // not required if current refill option is not selected
    final currentSelection = _artRefillOptionSelections[currentOption];
    if (currentSelection == null) {
      return false;
    }
    final bool previousAvailable = currentOption == 0 ? false : (_artRefillOptionAvailable[currentOption - 1] == null ? false : _artRefillOptionAvailable[currentOption - 1]);
    return (!previousAvailable && availabilityRequiredOptions.contains(currentSelection));
  }

  /// Returns true if the previously selected ART Refill Option is one of PE,
  /// VHW, Treatment Buddy, or Community Adherence Club and that option has been
  /// selected as not available.
  bool _additionalARTRefillOptionRequired(int currentOption) {
    if (currentOption < 1) {
      return true;
    }
    final previousOptionAvailable = _artRefillOptionAvailable[currentOption - 1];
    if (previousOptionAvailable == null) {
      return false;
    }
    return (_availabilityRequiredForSelection(currentOption - 1) &&
        !previousOptionAvailable);
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
            children: [PEBRAButtonRaised('Export')]),
        _buildTitle('Support'),
        _buildSupportCard(),

        Center(child: _buildTitle('Next Preference Assessment')),
        Center(child: Text(formatDate(calculateNextAssessment(DateTime.now())))),
        Container(height: 50), // padding at bottom
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          PEBRAButtonRaised(
            'Save',
            onPressed: _onSubmitForm,
          )
        ]),
        Container(height: 50), // padding at bottom
      ],
    )
    );
  }

  // TODO: refactor all form-related things such as this or '_makeQuestion()' to utils/FormUtils.dart
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
                _artRefillOptionFollowUpQuestions(0),
                _artRefillOption(1),
                _artRefillOptionFollowUpQuestions(1),
                _artRefillOption(2),
                _artRefillOptionFollowUpQuestions(2),
                _artRefillOption(3),
                _artRefillOptionFollowUpQuestions(3),
                _artRefillOption(4),
                _artRefillSupplyAmountQuestion(),
              ],
            )));
  }

  Widget _artRefillOption(int optionNumber) {
    if (!_additionalARTRefillOptionRequired(optionNumber)) {
      return Container();
    }

    // remove options depending on previous selections
    List<ARTRefillOption> remainingOptions = List<ARTRefillOption>();
    remainingOptions.addAll(ARTRefillOption.values);
    for (var i = 0; i < optionNumber; i++) {
      remainingOptions.remove(_artRefillOptionSelections[i]);
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
                if (newValue != _artRefillOptionSelections[optionNumber]) {
                  setState(() {
                    _artRefillOptionSelections[optionNumber] = newValue;
                    // reset any following selections
                    for (var i = optionNumber + 1; i <
                        _artRefillOptionSelections.length; i++) {
                      _artRefillOptionSelections[i] = null;
                      _artRefillOptionAvailable[i - 1] = null;
                    }
                  });
                }
              },
              validator: (value) {
                if (value == null) { return 'Please answer this question'; }
              },
              items: remainingOptions.map<DropdownMenuItem<ARTRefillOption>>((ARTRefillOption value) {
                String description = artRefillOptionToString(value);
                return DropdownMenuItem<ARTRefillOption>(
                  value: value,
                  child: Text(description),
                );
              }).toList(),
            ),
        )
      ],
    );
  }

  Widget _artRefillOptionFollowUpQuestions(int optionNumber) {
    if (!_availabilityRequiredForSelection(optionNumber)) {
      return Container();
    }

    Widget _availableQuestion() {

      var displayValue = _artRefillOptionAvailable[optionNumber];

      String question;
      switch (_artRefillOptionSelections[optionNumber]) {
        case ARTRefillOption.PE_HOME_DELIVERY:
          question = "This means, I, the PE, have to deliver the ART. Is this possible for me?";
          break;
        case ARTRefillOption.VHW:
          question = "This means, you want to get your ART at the VHW's home. Is there a VHW available nearby your village where you would pick up ART?";
          break;
        case ARTRefillOption.COMMUNITY_ADHERENCE_CLUB:
          question = "This means you want to get your ART mainly through a CAC. Is there currently a CAC in the participants' community available?";
          break;
        case ARTRefillOption.TREATMENT_BUDDY:
          question = "This means you want to get your ART mainly through a Treatment Buddy. Do you have a Treatment Buddy?";
          break;
        default:
          question = "Is this option available?";
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
              flex: _questionsFlex,
              child: Text(question)),
          Expanded(
              flex: _answersFlex,
              child: DropdownButtonFormField<bool>(
                value: displayValue,
                onChanged: (bool newValue) {
                    if (newValue != _artRefillOptionAvailable[optionNumber]) {
                      setState(() {
                        _artRefillOptionAvailable[optionNumber] = newValue;
                        // reset any following selections
                        _artRefillOptionSelections[optionNumber+1] = null;
                        for (var i = optionNumber + 1; i < _artRefillOptionAvailable.length; i++) {
                          _artRefillOptionAvailable[i] = null;
                          _artRefillOptionSelections[i+1] = null;
                        }
                      });
                    }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please answer this question';
                  }
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
              ),
          ),
        ],
      );
    }

    Widget _peHomeDeliverWhyNotPossibleQuestion() {
      if (_artRefillOptionAvailable[optionNumber] == null
          || _artRefillOptionSelections[optionNumber] != ARTRefillOption.PE_HOME_DELIVERY
          || _artRefillOptionAvailable[optionNumber]) {
        return Container();
      }
      return _makeQuestion('Why is this not possible for me?',
        answer: DropdownButtonFormField<PEHomeDeliveryNotPossibleReason>(
          value: _pa.artRefillPENotPossibleReason,
          onChanged: (PEHomeDeliveryNotPossibleReason newValue) {
            setState(() {
              _pa.artRefillPENotPossibleReason = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question';
            }
          },
          items:
          PEHomeDeliveryNotPossibleReason.allValues.map<DropdownMenuItem<PEHomeDeliveryNotPossibleReason>>((PEHomeDeliveryNotPossibleReason value) {
            return DropdownMenuItem<PEHomeDeliveryNotPossibleReason>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
      );
    }

    Widget _peHomeDeliverWhyNotPossibleReasonOtherQuestion() {
      if (_artRefillOptionAvailable[optionNumber] == null
          || _artRefillOptionSelections[optionNumber] != ARTRefillOption.PE_HOME_DELIVERY
          || _artRefillOptionAvailable[optionNumber]
          || _pa.artRefillPENotPossibleReason == null
          || _pa.artRefillPENotPossibleReason != PEHomeDeliveryNotPossibleReason.OTHER()) {
        return Container();
      }
      return _makeQuestion('Other, specify',
          answer: TextFormField(
            controller: _peHomeDeliverWhyNotPossibleReasonOtherCtr,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please specify the reason';
              }
            },
          ),
      );
    }

    Widget _vhwNameQuestion() {
      if (_artRefillOptionAvailable[optionNumber] == null
          || _artRefillOptionSelections[optionNumber] != ARTRefillOption.VHW
          || !_artRefillOptionAvailable[optionNumber]) {
        return Container();
      }
      return _makeQuestion('What is the name of this VHW?',
        answer: TextFormField(
          controller: _vhwNameCtr,
          validator: (value) {
            if (value.isEmpty) {
              return "Please enter the VHW's name";
            }
          },
        ),
      );
    }

    Widget _vhwVillageQuestion() {
      if (_artRefillOptionAvailable[optionNumber] == null
          || _artRefillOptionSelections[optionNumber] != ARTRefillOption.VHW
          || !_artRefillOptionAvailable[optionNumber]) {
        return Container();
      }
      return _makeQuestion("VHW's village",
        answer: TextFormField(
          controller: _vhwVillageCtr,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please specify the reason';
            }
          },
        ),
      );
    }

    Widget _vhwPhoneNumberQuestion() {
      if (_artRefillOptionAvailable[optionNumber] == null
          || _artRefillOptionSelections[optionNumber] != ARTRefillOption.VHW
          || !_artRefillOptionAvailable[optionNumber]) {
        return Container();
      }
      return _makeQuestion("VHW's cellphone number",
        answer: TextFormField(
          controller: _vhwPhoneNumberCtr,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter the phone number';
            }
          },
        ),
      );
    }

    Widget _treatmentBuddyARTNumberQuestion() {
      if (_artRefillOptionAvailable[optionNumber] == null
          || _artRefillOptionSelections[optionNumber] != ARTRefillOption.TREATMENT_BUDDY
          || !_artRefillOptionAvailable[optionNumber]) {
        return Container();
      }
      return _makeQuestion("What is your Treatment Buddy's ART number?",
        answer: TextFormField(
          controller: _treatmentBuddyARTNumberCtr,
          validator: (value) {
            if (value.isEmpty) {
              return "Please enter the Treatment Buddy's ART Number";
            }
          },
        ),
      );
    }

    Widget _treatmentBuddyVillageQuestion() {
      if (_artRefillOptionAvailable[optionNumber] == null
          || _artRefillOptionSelections[optionNumber] != ARTRefillOption.TREATMENT_BUDDY
          || !_artRefillOptionAvailable[optionNumber]) {
        return Container();
      }
      return _makeQuestion("Where does your Treatment Buddy live?",
        answer: TextFormField(
          controller: _treatmentBuddyVillageCtr,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter the home town of the Treatment Buddy';
            }
          },
        ),
      );
    }

    Widget _treatmentBuddyPhoneNumberQuestion() {
      if (_artRefillOptionAvailable[optionNumber] == null
          || _artRefillOptionSelections[optionNumber] != ARTRefillOption.TREATMENT_BUDDY
          || !_artRefillOptionAvailable[optionNumber]) {
        return Container();
      }
      return _makeQuestion("What is your Treatment Buddy's cellphone number?",
        answer: TextFormField(
          controller: _treatmentBuddyPhoneNumberCtr,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter the phone number';
            }
          },
        ),
      );
    }

    return Column(
      children: <Widget>[
        _availableQuestion(),
        _peHomeDeliverWhyNotPossibleQuestion(),
        _peHomeDeliverWhyNotPossibleReasonOtherQuestion(),
        _vhwNameQuestion(),
        _vhwVillageQuestion(),
        _vhwPhoneNumberQuestion(),
        _treatmentBuddyARTNumberQuestion(),
        _treatmentBuddyVillageQuestion(),
        _treatmentBuddyPhoneNumberQuestion(),
      ],
    );

  }

  Widget _artRefillSupplyAmountQuestion() {
    return _makeQuestion('What would be your preferred amount of ART supply to take home?',
        answer: DropdownButtonFormField<ARTSupplyAmount>(
          value: _pa.artSupplyAmount,
          onChanged: (ARTSupplyAmount newValue) {
            setState(() {
              _pa.artSupplyAmount = newValue;
            });
          },
          validator: (value) {
            if (value == null) { return 'Please answer this question'; }
          },
          items: ARTSupplyAmount.allValues.map<DropdownMenuItem<ARTSupplyAmount>>((ARTSupplyAmount value) {
            return DropdownMenuItem<ARTSupplyAmount>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
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
            _artRefillReminderMessageQuestion(),
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
              value: _pa.adherenceReminderMessage,
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
              value: _pa.artRefillReminderEnabled,
              onChanged: (bool newValue) {
                setState(() {
                  _pa.artRefillReminderEnabled = newValue;
                  // initialize the artRefillReminderDaysBefore object
                  _pa.artRefillReminderDaysBefore = newValue ? ARTRefillReminderDaysBeforeSelection() : null;
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
    return Column(children: <Widget>[
      _makeQuestion('How many days before would you like to receive the reminder? (tick all that apply)',
        answer: CheckboxListTile(
            title: Text(ARTRefillReminderDaysBeforeSelection.sevenDaysBeforeDescription),
            value: _pa.artRefillReminderDaysBefore.sevenDaysBeforeSelected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.artRefillReminderDaysBefore.sevenDaysBeforeSelected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
            title: Text(ARTRefillReminderDaysBeforeSelection.threeDaysBeforeDescription),
            value: _pa.artRefillReminderDaysBefore.threeDaysBeforeSelected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.artRefillReminderDaysBefore.threeDaysBeforeSelected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
            title: Text(ARTRefillReminderDaysBeforeSelection.twoDaysBeforeDescription),
            value: _pa.artRefillReminderDaysBefore.twoDaysBeforeSelected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.artRefillReminderDaysBefore.twoDaysBeforeSelected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
//            secondary: const Icon(Icons.local_hospital),
            title: Text(ARTRefillReminderDaysBeforeSelection.oneDayBeforeDescription),
//            dense: true,
            value: _pa.artRefillReminderDaysBefore.oneDayBeforeSelected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.artRefillReminderDaysBefore.oneDayBeforeSelected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
            title: Text(ARTRefillReminderDaysBeforeSelection.zeroDaysBeforeDescription),
            value: _pa.artRefillReminderDaysBefore.zeroDaysBeforeSelected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.artRefillReminderDaysBefore.zeroDaysBeforeSelected = newValue;
            })),
      ),
    ]);
  }

  Widget _artRefillReminderMessageQuestion() {
    if (_pa.phoneAvailable == null || !_pa.phoneAvailable ||
        _pa.artRefillReminderEnabled == null || !_pa.artRefillReminderEnabled) {
      return Container();
    }
    return _makeQuestion('What message do you want to receive as an ART refill reminder?',
      answer: DropdownButtonFormField<ARTRefillReminderMessage>(
        value: _pa.artRefillReminderMessage,
        onChanged: (ARTRefillReminderMessage newValue) {
          setState(() {
            _pa.artRefillReminderMessage = newValue;
          });
        },
        validator: (value) {
          if (value == null) { return 'Please answer this question'; }
        },
        items: ARTRefillReminderMessage.allValues.map<DropdownMenuItem<ARTRefillReminderMessage>>((ARTRefillReminderMessage value) {
          return DropdownMenuItem<ARTRefillReminderMessage>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
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
      _makeQuestion('What kind of support do you mainly wish? (tick all that apply)',
        answer: CheckboxListTile(
            secondary: _getPaddedIcon('assets/icons/nurse_clinic_fett.png'),
            title: Text(SupportPreferencesSelection.NURSE_CLINIC_DESCRIPTION),
//            dense: true,
            value: _pa.supportPreferences.NURSE_CLINIC_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.NURSE_CLINIC_selected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
            secondary: _getPaddedIcon('assets/icons/saturday_clinic_club_black.png'),
            title: Text(SupportPreferencesSelection.SATURDAY_CLINIC_CLUB_DESCRIPTION),
            value: _pa.supportPreferences.SATURDAY_CLINIC_CLUB_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.SATURDAY_CLINIC_CLUB_selected =
                  newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
            secondary: _getPaddedIcon('assets/icons/youth_club_black.png'),
            title: Text(SupportPreferencesSelection.COMMUNITY_YOUTH_CLUB_DESCRIPTION),
            value: _pa.supportPreferences.COMMUNITY_YOUTH_CLUB_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.COMMUNITY_YOUTH_CLUB_selected =
                  newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
            secondary: _getPaddedIcon('assets/icons/phonecall_pe_black.png'),
            title: Text(SupportPreferencesSelection.PHONE_CALL_PE_DESCRIPTION),
            value: _pa.supportPreferences.PHONE_CALL_PE_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.PHONE_CALL_PE_selected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
            secondary: _getPaddedIcon('assets/icons/homevisit_pe_black.png'),
            title: Text(SupportPreferencesSelection.HOME_VISIT_PE_DESCRIPTION),
            value: _pa.supportPreferences.HOME_VISIT_PE_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.HOME_VISIT_PE_selected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
            secondary: _getPaddedIcon('assets/icons/schooltalk_pe_black.png'),
            title: Text(SupportPreferencesSelection.SCHOOL_VISIT_PE_DESCRIPTION),
            value: _pa.supportPreferences.SCHOOL_VISIT_PE_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.SCHOOL_VISIT_PE_selected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
            secondary: _getPaddedIcon('assets/icons/pitso_black.png'),
            title: Text(SupportPreferencesSelection.PITSO_VISIT_PE_DESCRIPTION),
            value: _pa.supportPreferences.PITSO_VISIT_PE_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.PITSO_VISIT_PE_selected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
//            secondary: Container(width: 0.0),
            title: Text(SupportPreferencesSelection.CONDOM_DEMO_DESCRIPTION),
            value: _pa.supportPreferences.CONDOM_DEMO_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.CONDOM_DEMO_selected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
//            secondary: Container(width: 0.0),
            title: Text(SupportPreferencesSelection.CONTRACEPTIVES_INFO_DESCRIPTION),
            value: _pa.supportPreferences.CONTRACEPTIVES_INFO_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.CONTRACEPTIVES_INFO_selected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
//            secondary: Container(width: 0.0),
            title: Text(SupportPreferencesSelection.VMMC_INFO_DESCRIPTION),
            value: _pa.supportPreferences.VMMC_INFO_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.VMMC_INFO_selected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
//            secondary: Container(width: 0.0),
            title: Text(SupportPreferencesSelection.YOUNG_MOTHERS_GROUP_DESCRIPTION),
            value: _pa.supportPreferences.YOUNG_MOTHERS_GROUP_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.YOUNG_MOTHERS_GROUP_selected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
//            secondary: Container(width: 0.0),
            title: Text(SupportPreferencesSelection.FEMALE_WORTH_GROUP_DESCRIPTION),
            value: _pa.supportPreferences.FEMALE_WORTH_GROUP_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.FEMALE_WORTH_GROUP_selected = newValue;
            })),
      ),
      _makeQuestionCustom(
        question: Container(
            alignment: Alignment.centerRight,
            child: FlatButton.icon(
              icon: Icon(Icons.public, size: 18.0),
              onPressed: () { launchURL('https://play.google.com/store/apps/details?id=ls.nokaneng.app'); },
              label: Text('Download Nokaneng App'),
            )),
        answer: CheckboxListTile(
//            secondary: Container(width: 0.0),
            title: Text(SupportPreferencesSelection.LEGAL_AID_INFO_DESCRIPTION),
            value: _pa.supportPreferences.LEGAL_AID_INFO_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.LEGAL_AID_INFO_selected = newValue;
            })),
      ),
      _makeQuestionCustom(
          question: Container(
              alignment: Alignment.centerRight,
              child: FlatButton.icon(
                icon: Icon(Icons.public, size: 18.0),
                onPressed: () { launchURL('http://ls.tuneme.org/'); },
                label: Text('Open tuneme.org'),
              )),
          answer: CheckboxListTile(
//              secondary: Container(width: 0.0),
              title: Text(SupportPreferencesSelection.TUNE_ME_ORG_DESCRIPTION),
              value: _pa.supportPreferences.TUNE_ME_ORG_selected,
              onChanged: (bool newValue) => this.setState(() {
                _pa.supportPreferences.TUNE_ME_ORG_selected = newValue;
              }))
      ),
      _makeQuestionCustom(
        question: Container(
            alignment: Alignment.centerRight,
            child: FlatButton.icon(
              icon: Icon(Icons.public, size: 18.0),
              onPressed: () { launchURL('https://www.facebook.com/antiStigma123/'); },
              label: Text('Open Ntlafatso Foundation'),
            )),
        answer: CheckboxListTile(
//            secondary: Container(width: 0.0),
            title: Text(SupportPreferencesSelection.NTLAFATSO_FOUNDATION_DESCRIPTION),
            value: _pa.supportPreferences.NTLAFATSO_FOUNDATION_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.NTLAFATSO_FOUNDATION_selected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
            secondary: _getPaddedIcon('assets/icons/no_support_fett.png'),
            title: Text(SupportPreferencesSelection.NONE_DESCRIPTION),
            value: _pa.supportPreferences.areAllDeselected,
            onChanged: (bool newValue) {
              if (newValue) {
                this.setState(() {
                  _pa.supportPreferences.deselectAll();
                });
              }
            }),
      )]);
  }

  Widget _makeQuestion(String question, {@required Widget answer}) {
    return _makeQuestionCustom(
      question: Text(question),
      answer: answer,
    );
  }

  Widget _makeQuestionCustom({@required Widget question, @required Widget answer}) {
    return Row(
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child: question
        ),
        Expanded(
            flex: _answersFlex,
            child: answer
        ),
      ],
    );
  }

  ClipRect _getPaddedIcon(String assetLocation, {Color color}) {
    return ClipRect(
        clipBehavior: Clip.antiAlias,
        child: SizedOverflowBox(
            size: Size(32.0, 30.0),
            child: Image(
              height: 30.0,
              color: color,
              image: AssetImage(
                  assetLocation),
            )));
  }

  _onSubmitForm() async {
    if (_formKey.currentState.validate()) {
      _pa.artRefillOption1 = _artRefillOptionSelections[0];
      _pa.artRefillOption2 = _artRefillOptionSelections[1];
      _pa.artRefillOption3 = _artRefillOptionSelections[2];
      _pa.artRefillOption4 = _artRefillOptionSelections[3];
      _pa.artRefillOption5 = _artRefillOptionSelections[4];

      if (_artRefillOptionSelections.contains(ARTRefillOption.PE_HOME_DELIVERY)
          && !_artRefillOptionAvailable[_artRefillOptionSelections.indexOf(ARTRefillOption.PE_HOME_DELIVERY)]
          && _pa.artRefillPENotPossibleReason == PEHomeDeliveryNotPossibleReason.OTHER()) {
        _pa.artRefillPENotPossibleReasonOther = _peHomeDeliverWhyNotPossibleReasonOtherCtr.text;
      }
      if (_artRefillOptionSelections.contains(ARTRefillOption.VHW)
          && _artRefillOptionAvailable[_artRefillOptionSelections.indexOf(ARTRefillOption.VHW)]) {
        _pa.artRefillVHWName = _vhwNameCtr.text;
        _pa.artRefillVHWVillage = _vhwVillageCtr.text;
        _pa.artRefillVHWPhoneNumber = _vhwPhoneNumberCtr.text;
      }
      if (_artRefillOptionSelections.contains(ARTRefillOption.TREATMENT_BUDDY)
          && _artRefillOptionAvailable[_artRefillOptionSelections.indexOf(ARTRefillOption.TREATMENT_BUDDY)]) {
        _pa.artRefillTreatmentBuddyART = _treatmentBuddyARTNumberCtr.text;
        _pa.artRefillTreatmentBuddyVillage = _treatmentBuddyVillageCtr.text;
        _pa.artRefillTreatmentBuddyPhoneNumber = _treatmentBuddyPhoneNumberCtr.text;
      }
      if (_pa.phoneAvailable) {
        _pa.patientPhoneNumber = _patientPhoneNumberCtr.text;
        _pa.pePhoneNumber = _pePhoneNumberCtr.text;
        if (_pa.adherenceReminderEnabled) {
          _pa.adherenceReminderTime = _adherenceReminderTimeCtr.text;
        }
      }
      if (!_pa.phoneAvailable) {
        // reset all phone related fields
        _pa.patientPhoneNumber = null;
        _pa.adherenceReminderEnabled = null;
        _pa.adherenceReminderFrequency = null;
        _pa.adherenceReminderMessage = null;
        _pa.adherenceReminderTime = null;
        _pa.artRefillReminderEnabled = null;
        _pa.artRefillReminderDaysBefore = null;
        _pa.vlNotificationEnabled = null;
        _pa.vlNotificationMessageSuppressed = null;
        _pa.vlNotificationMessageUnsuppressed = null;
        _pa.pePhoneNumber = null;
      }
      if (_pa.adherenceReminderEnabled == null || !_pa.adherenceReminderEnabled) {
        _pa.adherenceReminderFrequency = null;
        _pa.adherenceReminderTime = null;
        _pa.adherenceReminderMessage = null;
      }
      if (_pa.artRefillReminderEnabled == null || !_pa.artRefillReminderEnabled) {
        _pa.artRefillReminderDaysBefore = null;
        _pa.artRefillReminderMessage = null;
      }
      if (_pa.vlNotificationEnabled == null || !_pa.vlNotificationEnabled) {
        _pa.vlNotificationMessageSuppressed = null;
        _pa.vlNotificationMessageUnsuppressed = null;
      }

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
