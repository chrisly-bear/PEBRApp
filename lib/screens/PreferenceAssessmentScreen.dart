import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonFlat.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/TransparentHeaderPage.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/ARTRefillOption.dart';
import 'package:pebrapp/database/beans/ARTRefillReminderDaysBeforeSelection.dart';
import 'package:pebrapp/database/beans/ARTRefillReminderMessage.dart';
import 'package:pebrapp/database/beans/ARTSupplyAmount.dart';
import 'package:pebrapp/database/beans/AdherenceReminderFrequency.dart';
import 'package:pebrapp/database/beans/AdherenceReminderMessage.dart';
import 'package:pebrapp/database/beans/CondomUsageNotDemonstratedReason.dart';
import 'package:pebrapp/database/beans/Gender.dart';
import 'package:pebrapp/database/beans/HomeVisitPENotPossibleReason.dart';
import 'package:pebrapp/database/beans/PEHomeDeliveryNotPossibleReason.dart';
import 'package:pebrapp/database/beans/PhoneAvailability.dart';
import 'package:pebrapp/database/beans/PitsoPENotPossibleReason.dart';
import 'package:pebrapp/database/beans/SchoolVisitPENotPossibleReason.dart';
import 'package:pebrapp/database/beans/SupportPreferencesSelection.dart';
import 'package:pebrapp/database/beans/VLSuppressedMessage.dart';
import 'package:pebrapp/database/beans/VLUnsuppressedMessage.dart';
import 'package:pebrapp/database/beans/YesNoRefused.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/database/models/UserData.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:pebrapp/utils/VisibleImpactUtils.dart';

class PreferenceAssessmentScreen extends StatelessWidget {
  final Patient _patient;

  PreferenceAssessmentScreen(this._patient);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        body: TransparentHeaderPage(
          title: 'Preference Assessment',
          subtitle: _patient.artNumber,
          child: PreferenceAssessmentForm(_patient),
          actions: <Widget>[IconButton(icon: Icon(Icons.close), onPressed: Navigator.of(context).pop)],
        ),
    );
  }
}

class PreferenceAssessmentForm extends StatefulWidget {
  final Patient _patient;

  PreferenceAssessmentForm(this._patient);

  @override
  createState() => _PreferenceAssessmentFormState(_patient);
}

class _PreferenceAssessmentFormState extends State<PreferenceAssessmentForm> {

  // fields
  final _formKey = GlobalKey<FormState>();
  int _questionsFlex = 1;
  int _answersFlex = 1;
  double _screenWidth = double.infinity;

  Patient _patient;
  // if this is true we will store another row in Patient table of the database
  bool _patientUpdated = false;
  PhoneAvailability _phoneAvailabilityBeforeAssessment;
  String _patientPhoneNumberBeforeAssessment;
  UserData _user;
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
  var _pePhoneNumberCtr = TextEditingController();
  var _homeVisitPENotPossibleReasonCtr = TextEditingController();
  var _schoolCtr = TextEditingController();
  var _schoolVisitPENotPossibleReasonCtr = TextEditingController();
  var _pitsoVisitPENotPossibleReasonCtr = TextEditingController();
  var _condomUsageNotDemonstratedReasonCtr = TextEditingController();
  var _contraceptivesMoreInfoCtr = TextEditingController();
  var _vmmcMoreInfoCtr = TextEditingController();
  var _psychoSocialShareCtr = TextEditingController();
  var _psychoSocialHowDoingCtr = TextEditingController();
  var _whyNotSafeEnvironmentCtr = TextEditingController();
  bool _adherenceReminderTimeValid = true;

  // constructor
  _PreferenceAssessmentFormState(Patient patient) {
    _patient = patient;
    _patientPhoneNumberCtr.text = _patient.phoneNumber ?? '';
    _phoneAvailabilityBeforeAssessment = _patient.phoneAvailability;
    _patientPhoneNumberBeforeAssessment = _patient.phoneNumber;
    _pa.patientART = patient.artNumber;
    DatabaseProvider().retrieveLatestUserData().then((UserData user) {
      _user = user;
      _pePhoneNumberCtr.text = _user.phoneNumber;
    });
  }

  /// Returns true for VHW, Treatment Buddy, Community Adherence Club selections.
  bool _availabilityRequiredForSelection(int currentOption) {
    final availabilityRequiredOptions = [
      ARTRefillOption.PE_HOME_DELIVERY(),
      ARTRefillOption.VHW(),
      ARTRefillOption.TREATMENT_BUDDY(),
      ARTRefillOption.COMMUNITY_ADHERENCE_CLUB(),
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
    _screenWidth = MediaQuery.of(context).size.width;
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildTitle('ART Refill'),
        _buildARTRefillCard(),
        _buildTitle('Notifications'),
        _buildNotificationsCard(),
        _buildTitle('Support'),
        _buildSupportCard(),
        _buildPsychosocialCard(),
        _buildUnsuppressedCard(),

        Center(child: _buildTitle('Next Preference Assessment')),
        Center(child: Text(formatDate(calculateNextAssessment(DateTime.now(), isSuppressed(_patient))), style: TextStyle(fontSize: 16.0))),
        SizedBox(height: 50), // padding at bottom
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
    remainingOptions.addAll(ARTRefillOption.allValues);
    for (var i = 0; i < optionNumber; i++) {
      remainingOptions.remove(_artRefillOptionSelections[i]);
    }

    var displayValue = _artRefillOptionSelections[optionNumber];

    return _makeQuestion(optionNumber == 0 ? 'How and where do you want to refill your ART mainly?' : 'Choose another option additionally',
        answer: DropdownButtonFormField<ARTRefillOption>(
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
            return DropdownMenuItem<ARTRefillOption>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
    );
  }

  Widget _artRefillOptionFollowUpQuestions(int optionNumber) {
    if (!_availabilityRequiredForSelection(optionNumber)) {
      return Container();
    }

    Widget _availableQuestion() {

      var displayValue = _artRefillOptionAvailable[optionNumber];

      String question;
      final ARTRefillOption aro = _artRefillOptionSelections[optionNumber];
      if (aro == ARTRefillOption.PE_HOME_DELIVERY()) {
        question = "This means, I, the PE, have to deliver the ART. Is this possible for me?";
      } else if (aro == ARTRefillOption.VHW()) {
        question = "This means, you want to get your ART at the VHW's home. Is there a VHW available nearby your village where you would pick up ART?";
      } else if (aro == ARTRefillOption.COMMUNITY_ADHERENCE_CLUB()) {
        question = "This means you want to get your ART mainly through a CAC. Is there currently a CAC in the participants' community available?";
      } else if (aro == ARTRefillOption.TREATMENT_BUDDY()) {
        question = "This means you want to get your ART mainly through a Treatment Buddy. Do you have a Treatment Buddy?";
      }

      return _makeQuestion(question,
          answer: DropdownButtonFormField<bool>(
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
      );
    }

    Widget _peHomeDeliverWhyNotPossibleQuestion() {
      if (_artRefillOptionAvailable[optionNumber] == null
          || _artRefillOptionSelections[optionNumber] != ARTRefillOption.PE_HOME_DELIVERY()
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
          || _artRefillOptionSelections[optionNumber] != ARTRefillOption.PE_HOME_DELIVERY()
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
          || _artRefillOptionSelections[optionNumber] != ARTRefillOption.VHW()
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
          || _artRefillOptionSelections[optionNumber] != ARTRefillOption.VHW()
          || !_artRefillOptionAvailable[optionNumber]) {
        return Container();
      }
      return _makeQuestion("VHW's village",
        answer: TextFormField(
          controller: _vhwVillageCtr,
          validator: (value) {
            if (value.isEmpty) {
              return "Please enter the VHW's village";
            }
          },
        ),
      );
    }

    Widget _vhwPhoneNumberQuestion() {
      if (_artRefillOptionAvailable[optionNumber] == null
          || _artRefillOptionSelections[optionNumber] != ARTRefillOption.VHW()
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
          || _artRefillOptionSelections[optionNumber] != ARTRefillOption.TREATMENT_BUDDY()
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
          || _artRefillOptionSelections[optionNumber] != ARTRefillOption.TREATMENT_BUDDY()
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
          || _artRefillOptionSelections[optionNumber] != ARTRefillOption.TREATMENT_BUDDY()
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
        color: DATA_SUBTITLE_TEXT,
        fontStyle: FontStyle.italic,
        fontSize: 15.0,
      ),)
    ]));
  }

  Widget _phoneAvailableQuestion() {
    return _makeQuestion('Do you have regular access to a phone where you can receive confidential information?',
        answer: DropdownButtonFormField<PhoneAvailability>(
          value: _patient.phoneAvailability,
          onChanged: (PhoneAvailability newValue) {
            setState(() {
              _patient.phoneAvailability = newValue;
            });
            // if the new value is different from before we should update the patient table in the database
            _patientUpdated = _phoneAvailabilityBeforeAssessment != newValue;
          },
          validator: (value) {
            if (value == null) { return 'Please answer this question'; }
          },
          items:
          PhoneAvailability.allValues.map<DropdownMenuItem<PhoneAvailability>>((PhoneAvailability value) {
            return DropdownMenuItem<PhoneAvailability>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
    );
  }

  Widget _phoneNumberPatientQuestion() {
    if (_patient.phoneAvailability == null || _patient.phoneAvailability != PhoneAvailability.YES()) {
      return Container();
    }
    return _makeQuestion('Patient Phone Number',
        answer: TextFormField(
          controller: _patientPhoneNumberCtr,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter a phone number';
            }
          },
        ),
    );
  }

  Widget _adherenceReminderSubtitle() {
    if (_patient.phoneAvailability == null || _patient.phoneAvailability != PhoneAvailability.YES()) {
      return Container();
    }
    return _makeSubtitle('Adherence Reminder');
  }

  Widget _adherenceReminderQuestion() {
    if (_patient.phoneAvailability == null || _patient.phoneAvailability != PhoneAvailability.YES()) {
      return Container();
    }
    return _makeQuestion('Do you want to receive adherence reminders?',
      answer: DropdownButtonFormField<bool>(
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
      ),
    );
  }

  Widget _adherenceReminderFrequencyQuestion() {
    if (_patient.phoneAvailability == null || _patient.phoneAvailability != PhoneAvailability.YES() ||
        _pa.adherenceReminderEnabled == null || !_pa.adherenceReminderEnabled) {
      return Container();
    }
    return _makeQuestion('How often do you want to receive adherence reminders?',
      answer: DropdownButtonFormField<AdherenceReminderFrequency>(
        value: _pa.adherenceReminderFrequency,
        onChanged: (AdherenceReminderFrequency newValue) {
          setState(() {
            _pa.adherenceReminderFrequency = newValue;
          });
        },
        validator: (value) {
          if (value == null) { return 'Please answer this question'; }
        },
        items: AdherenceReminderFrequency.allValues.map<DropdownMenuItem<AdherenceReminderFrequency>>((AdherenceReminderFrequency value) {
          return DropdownMenuItem<AdherenceReminderFrequency>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _adherenceReminderTimeQuestion() {
    if (_patient.phoneAvailability == null || _patient.phoneAvailability != PhoneAvailability.YES() ||
        _pa.adherenceReminderEnabled == null || !_pa.adherenceReminderEnabled) {
      return Container();
    }
    return _makeQuestion('When during the day do you want to receive the adherence reminder?',
      answer: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlatButton(
              padding: EdgeInsets.all(0.0),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  _pa.adherenceReminderTime == null ? 'Select Time' : formatTime(_pa.adherenceReminderTime),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              onPressed: () async {
                TimeOfDay time = await showTimePicker(context: context, initialTime: TimeOfDay(hour: 12, minute: 0));
                if (time != null) {
                  setState(() {
                    _pa.adherenceReminderTime = time;
                  });
                }
              },
            ),
            Divider(color: CUSTOM_FORM_FIELD_UNDERLINE, height: 1.0,),
            _adherenceReminderTimeValid ? Container() : Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                'Please select a time',
                style: TextStyle(
                  color: CUSTOM_FORM_FIELD_ERROR_TEXT,
                  fontSize: 12.0,
                ),
              ),
            ),
          ]
      ),
    );
  }

  Widget _adherenceReminderMessageQuestion() {
    if (_patient.phoneAvailability == null || _patient.phoneAvailability != PhoneAvailability.YES() ||
        _pa.adherenceReminderEnabled == null || !_pa.adherenceReminderEnabled) {
      return Container();
    }

    return _makeQuestion('Which adherence reminder do you want to receive?',
      answer: DropdownButtonFormField<AdherenceReminderMessage>(
        value: _pa.adherenceReminderMessage,
        onChanged: (AdherenceReminderMessage newValue) {
          setState(() {
            _pa.adherenceReminderMessage = newValue;
          });
        },
        validator: (value) {
          if (value == null) { return 'Please answer this question'; }
        },
        items: AdherenceReminderMessage.allValues.map<DropdownMenuItem<AdherenceReminderMessage>>((AdherenceReminderMessage value) {
          return DropdownMenuItem<AdherenceReminderMessage>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _artRefillReminderSubtitle() {
    if (_patient.phoneAvailability == null || _patient.phoneAvailability != PhoneAvailability.YES()) {
      return Container();
    }
    return _makeSubtitle('ART Refill Reminder');
  }

  Widget _artRefillReminderQuestion() {
    if (_patient.phoneAvailability == null || _patient.phoneAvailability != PhoneAvailability.YES()) {
      return Container();
    }
    return _makeQuestion('Do you want to receive ART refill reminders?',
      answer: DropdownButtonFormField<bool>(
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
      ),
    );
  }

  Widget _artRefillReminderDaysBeforeQuestion() {
    if (_patient.phoneAvailability == null || _patient.phoneAvailability != PhoneAvailability.YES() ||
        _pa.artRefillReminderEnabled == null || !_pa.artRefillReminderEnabled) {
      return Container();
    }
    return Column(children: <Widget>[
      _makeQuestion('How many days before would you like to receive the reminder? (tick all that apply)',
        answer: CheckboxListTile(
            title: Text(ARTRefillReminderDaysBeforeSelection.SEVEN_DAYS_BEFORE),
            value: _pa.artRefillReminderDaysBefore.SEVEN_DAYS_BEFORE_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.artRefillReminderDaysBefore.SEVEN_DAYS_BEFORE_selected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
            title: Text(ARTRefillReminderDaysBeforeSelection.THREE_DAYS_BEFORE),
            value: _pa.artRefillReminderDaysBefore.THREE_DAYS_BEFORE_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.artRefillReminderDaysBefore.THREE_DAYS_BEFORE_selected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
            title: Text(ARTRefillReminderDaysBeforeSelection.TWO_DAYS_BEFORE),
            value: _pa.artRefillReminderDaysBefore.TWO_DAYS_BEFORE_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.artRefillReminderDaysBefore.TWO_DAYS_BEFORE_selected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
//            secondary: const Icon(Icons.local_hospital),
            title: Text(ARTRefillReminderDaysBeforeSelection.ONE_DAY_BEFORE),
//            dense: true,
            value: _pa.artRefillReminderDaysBefore.ONE_DAY_BEFORE_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.artRefillReminderDaysBefore.ONE_DAY_BEFORE_selected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
            title: Text(ARTRefillReminderDaysBeforeSelection.ZERO_DAYS_BEFORE),
            value: _pa.artRefillReminderDaysBefore.ZERO_DAYS_BEFORE_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.artRefillReminderDaysBefore.ZERO_DAYS_BEFORE_selected = newValue;
            })),
      ),
    ]);
  }

  Widget _artRefillReminderMessageQuestion() {
    if (_patient.phoneAvailability == null || _patient.phoneAvailability != PhoneAvailability.YES() ||
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
    if (_patient.phoneAvailability == null || _patient.phoneAvailability != PhoneAvailability.YES()) {
      return Container();
    }
    return _makeSubtitle('Viral Load Notification');
  }

  Widget _viralLoadNotificationQuestion() {
    if (_patient.phoneAvailability == null || _patient.phoneAvailability != PhoneAvailability.YES()) {
      return Container();
    }
    return _makeQuestion('Do you want to receive a notification after a VL measurement?',
      answer: DropdownButtonFormField<bool>(
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
      ),
    );
  }

  Widget _viralLoadMessageSuppressedQuestion() {
    if (_patient.phoneAvailability == null || _patient.phoneAvailability != PhoneAvailability.YES() ||
        _pa.vlNotificationEnabled == null || !_pa.vlNotificationEnabled) {
      return Container();
    }
    return _makeQuestion('Which message do you want to receive if VL is suppressed?',
      answer: DropdownButtonFormField<VLSuppressedMessage>(
        value: _pa.vlNotificationMessageSuppressed,
        onChanged: (VLSuppressedMessage newValue) {
          setState(() {
            _pa.vlNotificationMessageSuppressed = newValue;
          });
        },
        validator: (value) {
          if (value == null) { return 'Please answer this question'; }
        },
        items: VLSuppressedMessage.allValues.map<DropdownMenuItem<VLSuppressedMessage>>((VLSuppressedMessage value) {
          return DropdownMenuItem<VLSuppressedMessage>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _viralLoadMessageUnsuppressedQuestion() {
    if (_patient.phoneAvailability == null || _patient.phoneAvailability != PhoneAvailability.YES() ||
        _pa.vlNotificationEnabled == null || !_pa.vlNotificationEnabled) {
      return Container();
    }
    return _makeQuestion('Which message do you want to receive if VL is unsuppressed?',
      answer: DropdownButtonFormField<VLUnsuppressedMessage>(
        value: _pa.vlNotificationMessageUnsuppressed,
        onChanged: (VLUnsuppressedMessage newValue) {
          setState(() {
            _pa.vlNotificationMessageUnsuppressed = newValue;
          });
        },
        validator: (value) {
          if (value == null) { return 'Please answer this question'; }
        },
        items: VLUnsuppressedMessage.allValues.map<DropdownMenuItem<VLUnsuppressedMessage>>((VLUnsuppressedMessage value) {
          return DropdownMenuItem<VLUnsuppressedMessage>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _phoneNumberPEPadding() {
    if (_patient.phoneAvailability == null || _patient.phoneAvailability != PhoneAvailability.YES()) {
      return Container();
    }
    return Container(height: 20,);
  }

  Widget _phoneNumberPEQuestion() {
    if (_patient.phoneAvailability == null || _patient.phoneAvailability != PhoneAvailability.YES()) {
      return Container();
    }
    return _makeQuestion('PE Phone Number',
      answer: TextFormField(
        controller: _pePhoneNumberCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a phone number';
          }
        },
      ),
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
            secondary: _getPaddedIcon('assets/icons/nurse_clinic.png'),
            title: Text(SupportPreferencesSelection.NURSE_CLINIC_DESCRIPTION),
//            dense: true,
            value: _pa.supportPreferences.NURSE_CLINIC_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.NURSE_CLINIC_selected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
            secondary: _getPaddedIcon('assets/icons/saturday_clinic_club.png'),
            title: Text(SupportPreferencesSelection.SATURDAY_CLINIC_CLUB_DESCRIPTION),
            value: _pa.supportPreferences.SATURDAY_CLINIC_CLUB_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.SATURDAY_CLINIC_CLUB_selected =
                  newValue;
            })),
      ),
      _saturdayClinicClubFollowUpQuestions(),
      _makeQuestion('',
        answer: CheckboxListTile(
            secondary: _getPaddedIcon('assets/icons/youth_club.png'),
            title: Text(SupportPreferencesSelection.COMMUNITY_YOUTH_CLUB_DESCRIPTION),
            value: _pa.supportPreferences.COMMUNITY_YOUTH_CLUB_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.COMMUNITY_YOUTH_CLUB_selected =
                  newValue;
            })),
      ),
      _communityYouthClubFollowUpQuestions(),
      _makeQuestion('',
        answer: CheckboxListTile(
            secondary: _getPaddedIcon('assets/icons/phonecall_pe.png'),
            title: Text(SupportPreferencesSelection.PHONE_CALL_PE_DESCRIPTION),
            value: _pa.supportPreferences.PHONE_CALL_PE_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.PHONE_CALL_PE_selected = newValue;
            })),
      ),
      _makeQuestion('',
        answer: CheckboxListTile(
            secondary: _getPaddedIcon('assets/icons/homevisit_pe.png'),
            title: Text(SupportPreferencesSelection.HOME_VISIT_PE_DESCRIPTION),
            value: _pa.supportPreferences.HOME_VISIT_PE_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.HOME_VISIT_PE_selected = newValue;
            })),
      ),
      _homeVisitPEFollowUpQuestions(),
      _makeQuestion('',
        answer: CheckboxListTile(
            secondary: _getPaddedIcon('assets/icons/schooltalk_pe.png'),
            title: Text(SupportPreferencesSelection.SCHOOL_VISIT_PE_DESCRIPTION),
            value: _pa.supportPreferences.SCHOOL_VISIT_PE_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.SCHOOL_VISIT_PE_selected = newValue;
            })),
      ),
      _schoolVisitPEFollowUpQuestions(),
      _makeQuestion('',
        answer: CheckboxListTile(
            secondary: _getPaddedIcon('assets/icons/pitso.png'),
            title: Text(SupportPreferencesSelection.PITSO_VISIT_PE_DESCRIPTION),
            value: _pa.supportPreferences.PITSO_VISIT_PE_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.PITSO_VISIT_PE_selected = newValue;
            })),
      ),
      _pitsoVisitPEFollowUpQuestions(),
      _makeQuestion('',
        answer: CheckboxListTile(
//            secondary: Container(width: 0.0),
            title: Text(SupportPreferencesSelection.CONDOM_DEMO_DESCRIPTION),
            value: _pa.supportPreferences.CONDOM_DEMO_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.CONDOM_DEMO_selected = newValue;
            })),
      ),
      _condomDemoFollowUpQuestions(),
      _makeQuestion('',
        answer: CheckboxListTile(
//            secondary: Container(width: 0.0),
            title: Text(SupportPreferencesSelection.CONTRACEPTIVES_INFO_DESCRIPTION),
            value: _pa.supportPreferences.CONTRACEPTIVES_INFO_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.CONTRACEPTIVES_INFO_selected = newValue;
            })),
      ),
      _contraceptivesInfoFollowUpQuestions(),
      _makeQuestion('',
        answer: CheckboxListTile(
//            secondary: Container(width: 0.0),
            title: Text(SupportPreferencesSelection.VMMC_INFO_DESCRIPTION),
            value: _pa.supportPreferences.VMMC_INFO_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.VMMC_INFO_selected = newValue;
            })),
      ),
      _vmmcInfoFollowUpQuestions(),
      _patient.gender == Gender.FEMALE() || _patient.gender == Gender.TRANSGENDER() ? _makeQuestion('',
        answer: CheckboxListTile(
//            secondary: Container(width: 0.0),
            title: Text(SupportPreferencesSelection.YOUNG_MOTHERS_GROUP_DESCRIPTION),
            value: _pa.supportPreferences.YOUNG_MOTHERS_GROUP_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.YOUNG_MOTHERS_GROUP_selected = newValue;
            })),
      ) : Container(),
      _youngMothersFollowUpQuestions(),
      _patient.gender == Gender.FEMALE() || _patient.gender == Gender.TRANSGENDER() ? _makeQuestion('',
        answer: CheckboxListTile(
//            secondary: Container(width: 0.0),
            title: Text(SupportPreferencesSelection.FEMALE_WORTH_GROUP_DESCRIPTION),
            value: _pa.supportPreferences.FEMALE_WORTH_GROUP_selected,
            onChanged: (bool newValue) => this.setState(() {
              _pa.supportPreferences.FEMALE_WORTH_GROUP_selected = newValue;
            })),
      ) : Container(),
      _femaleWorthFollowUpQuestions(),
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
      _legalAidFollowUpQuestions(),
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
      _tuneMeFollowUpQuestions(),
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
      _ntlafatsoFollowUpQuestions(),
      _makeQuestion('',
        answer: CheckboxListTile(
            secondary: _getPaddedIcon('assets/icons/no_support.png'),
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

  Widget _saturdayClinicClubFollowUpQuestions() {
    if (!_pa.supportPreferences.SATURDAY_CLINIC_CLUB_selected) {
      return Container();
    }
    return _makeQuestion(
      'Is there currently a functioning Saturday Clinic Club at the health facility?',
      answer: DropdownButtonFormField<bool>(
        value: _pa.saturdayClinicClubAvailable,
        onChanged: (bool newValue) {
          setState(() {
            _pa.saturdayClinicClubAvailable = newValue;
          });
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
    );
  }

  Widget _communityYouthClubFollowUpQuestions() {
    if (!_pa.supportPreferences.COMMUNITY_YOUTH_CLUB_selected) {
      return Container();
    }
    return _makeQuestion(
      'Is there currently a functioning Community Youth Club where the participant could attend?',
      answer: DropdownButtonFormField<bool>(
        value: _pa.communityYouthClubAvailable,
        onChanged: (bool newValue) {
          setState(() {
            _pa.communityYouthClubAvailable = newValue;
          });
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
    );
  }

  Widget _homeVisitPEFollowUpQuestions() {
    if (!_pa.supportPreferences.HOME_VISIT_PE_selected) {
      return Container();
    }

    Widget _possibleQuestion() {
      return _makeQuestion(
        'This means, I, the PE, need to make a home-visit. Is this possible for me?',
        answer: DropdownButtonFormField<bool>(
          value: _pa.homeVisitPEPossible,
          onChanged: (bool newValue) {
            setState(() {
              _pa.homeVisitPEPossible = newValue;
            });
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
      );
    }

    Widget _notPossibleReasonQuestion() {
      if (_pa.homeVisitPEPossible == null || _pa.homeVisitPEPossible) {
        return Container();
      }
      return _makeQuestion('Why is this not possible for me?',
        answer: DropdownButtonFormField<HomeVisitPENotPossibleReason>(
          value: _pa.homeVisitPENotPossibleReason,
          onChanged: (HomeVisitPENotPossibleReason newValue) {
            setState(() {
              _pa.homeVisitPENotPossibleReason = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question';
            }
          },
          items:
          HomeVisitPENotPossibleReason.allValues.map<DropdownMenuItem<HomeVisitPENotPossibleReason>>((HomeVisitPENotPossibleReason value) {
            return DropdownMenuItem<HomeVisitPENotPossibleReason>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
      );
    }

    Widget _notPossibleReasonOtherQuestion() {
      if (_pa.homeVisitPEPossible == null || _pa.homeVisitPEPossible
          || _pa.homeVisitPENotPossibleReason == null
          || _pa.homeVisitPENotPossibleReason != HomeVisitPENotPossibleReason.OTHER()) {
        return Container();
      }
      return _makeQuestion('Other, specify',
          answer: TextFormField(
            controller: _homeVisitPENotPossibleReasonCtr,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please specify a reason';
              }
            },
          )
      );
    }

    return Column(children: [
      _possibleQuestion(),
      _notPossibleReasonQuestion(),
      _notPossibleReasonOtherQuestion(),
    ]);
  }

  Widget _schoolVisitPEFollowUpQuestions() {
    if (!_pa.supportPreferences.SCHOOL_VISIT_PE_selected) {
      return Container();
    }

    Widget _possibleQuestion() {
      return _makeQuestion(
        'This means, I, the PE, need to make a school visit for a health talk. Is this possible for me?',
        answer: DropdownButtonFormField<bool>(
          value: _pa.schoolVisitPEPossible,
          onChanged: (bool newValue) {
            setState(() {
              _pa.schoolVisitPEPossible = newValue;
            });
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
      );
    }

    Widget _schoolQuestion() {
      if (_pa.schoolVisitPEPossible == null || !_pa.schoolVisitPEPossible) {
        return Container();
      }
      return _makeQuestion('Which School is the participant attending (put name and village of the school)',
          answer: TextFormField(
            controller: _schoolCtr,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please specify a school and village';
              }
            },
          )
      );
    }

    Widget _notPossibleReasonQuestion() {
      if (_pa.schoolVisitPEPossible == null || _pa.schoolVisitPEPossible) {
        return Container();
      }
      return _makeQuestion('Why is this not possible for me?',
        answer: DropdownButtonFormField<SchoolVisitPENotPossibleReason>(
          value: _pa.schoolVisitPENotPossibleReason,
          onChanged: (SchoolVisitPENotPossibleReason newValue) {
            setState(() {
              _pa.schoolVisitPENotPossibleReason = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question';
            }
          },
          items:
          SchoolVisitPENotPossibleReason.allValues.map<DropdownMenuItem<SchoolVisitPENotPossibleReason>>((SchoolVisitPENotPossibleReason value) {
            return DropdownMenuItem<SchoolVisitPENotPossibleReason>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
      );
    }

    Widget _notPossibleReasonOtherQuestion() {
      if (_pa.schoolVisitPEPossible == null || _pa.schoolVisitPEPossible
          || _pa.schoolVisitPENotPossibleReason == null
          || _pa.schoolVisitPENotPossibleReason != SchoolVisitPENotPossibleReason.OTHER()) {
        return Container();
      }
      return _makeQuestion('Other, specify',
          answer: TextFormField(
            controller: _schoolVisitPENotPossibleReasonCtr,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please specify a reason';
              }
            },
          )
      );
    }

    return Column(children: [
      _possibleQuestion(),
      _schoolQuestion(),
      _notPossibleReasonQuestion(),
      _notPossibleReasonOtherQuestion(),
    ]);
  }

  Widget _pitsoVisitPEFollowUpQuestions() {
    if (!_pa.supportPreferences.PITSO_VISIT_PE_selected) {
      return Container();
    }

    Widget _possibleQuestion() {
      return _makeQuestion(
        'This means, I, the PE, need to go to a pitso for a health talk. Is this possible for me?',
        answer: DropdownButtonFormField<bool>(
          value: _pa.pitsoPEPossible,
          onChanged: (bool newValue) {
            setState(() {
              _pa.pitsoPEPossible = newValue;
            });
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
      );
    }

    Widget _notPossibleReasonQuestion() {
      if (_pa.pitsoPEPossible == null || _pa.pitsoPEPossible) {
        return Container();
      }
      return _makeQuestion('Why is this not possible for me?',
        answer: DropdownButtonFormField<PitsoPENotPossibleReason>(
          value: _pa.pitsoPENotPossibleReason,
          onChanged: (PitsoPENotPossibleReason newValue) {
            setState(() {
              _pa.pitsoPENotPossibleReason = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question';
            }
          },
          items:
          PitsoPENotPossibleReason.allValues.map<DropdownMenuItem<PitsoPENotPossibleReason>>((PitsoPENotPossibleReason value) {
            return DropdownMenuItem<PitsoPENotPossibleReason>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
      );
    }

    Widget _notPossibleReasonOtherQuestion() {
      if (_pa.pitsoPEPossible == null || _pa.pitsoPEPossible
          || _pa.pitsoPENotPossibleReason == null
          || _pa.pitsoPENotPossibleReason != PitsoPENotPossibleReason.OTHER()) {
        return Container();
      }
      return _makeQuestion('Other, specify',
          answer: TextFormField(
            controller: _pitsoVisitPENotPossibleReasonCtr,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please specify a reason';
              }
            },
          )
      );
    }

    return Column(children: [
      _possibleQuestion(),
      _notPossibleReasonQuestion(),
      _notPossibleReasonOtherQuestion(),
    ]);
  }

  Widget _condomDemoFollowUpQuestions() {
    if (!_pa.supportPreferences.CONDOM_DEMO_selected) {
      return Container();
    }

    Widget _possibleQuestion() {
      return _makeQuestion(
        'Have you demonstrated condom usage?',
        answer: DropdownButtonFormField<bool>(
          value: _pa.condomUsageDemonstrated,
          onChanged: (bool newValue) {
            setState(() {
              _pa.condomUsageDemonstrated = newValue;
            });
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
      );
    }

    Widget _notPossibleReasonQuestion() {
      if (_pa.condomUsageDemonstrated == null || _pa.condomUsageDemonstrated) {
        return Container();
      }
      return _makeQuestion('Why not?',
        answer: DropdownButtonFormField<CondomUsageNotDemonstratedReason>(
          value: _pa.condomUsageNotDemonstratedReason,
          onChanged: (CondomUsageNotDemonstratedReason newValue) {
            setState(() {
              _pa.condomUsageNotDemonstratedReason = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please answer this question';
            }
          },
          items:
          CondomUsageNotDemonstratedReason.allValues.map<DropdownMenuItem<CondomUsageNotDemonstratedReason>>((CondomUsageNotDemonstratedReason value) {
            return DropdownMenuItem<CondomUsageNotDemonstratedReason>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
      );
    }

    Widget _notPossibleReasonOtherQuestion() {
      if (_pa.condomUsageDemonstrated == null || _pa.condomUsageDemonstrated
          || _pa.condomUsageNotDemonstratedReason == null
          || _pa.condomUsageNotDemonstratedReason != CondomUsageNotDemonstratedReason.OTHER()) {
        return Container();
      }
      return _makeQuestion('Other, specify',
          answer: TextFormField(
            controller: _condomUsageNotDemonstratedReasonCtr,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please specify a reason';
              }
            },
          )
      );
    }

    return Column(children: [
      _possibleQuestion(),
      _notPossibleReasonQuestion(),
      _notPossibleReasonOtherQuestion(),
    ]);
  }

  Widget _contraceptivesInfoFollowUpQuestions() {
    if (!_pa.supportPreferences.CONTRACEPTIVES_INFO_selected) {
      return Container();
    }
    return _makeQuestion('To which person will you link the participant for more information about contraceptives?',
        answer: TextFormField(
          controller: _contraceptivesMoreInfoCtr,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please specify a person';
            }
          },
        )
    );
  }

  Widget _vmmcInfoFollowUpQuestions() {
    if (!_pa.supportPreferences.VMMC_INFO_selected) {
      return Container();
    }
    return _makeQuestion('To which person will you link the participant for more information about VMMC?',
        answer: TextFormField(
          controller: _vmmcMoreInfoCtr,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please specify a person';
            }
          },
        )
    );
  }

  Widget _youngMothersFollowUpQuestions() {
    if (!_pa.supportPreferences.YOUNG_MOTHERS_GROUP_selected || !(_patient.gender == Gender.FEMALE() || _patient.gender == Gender.TRANSGENDER())) {
      return Container();
    }
    return _makeQuestion(
      'Is there currently a functioning mothers-to-mothers group at the health facility?',
      answer: DropdownButtonFormField<bool>(
        value: _pa.youngMothersAvailable,
        onChanged: (bool newValue) {
          setState(() {
            _pa.youngMothersAvailable = newValue;
          });
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
    );
  }

  Widget _femaleWorthFollowUpQuestions() {
    if (!_pa.supportPreferences.FEMALE_WORTH_GROUP_selected || !(_patient.gender == Gender.FEMALE() || _patient.gender == Gender.TRANSGENDER())) {
      return Container();
    }
    return _makeQuestion(
      'Is there currently a functioning WORTH group at the health facility?',
      answer: DropdownButtonFormField<bool>(
        value: _pa.femaleWorthAvailable,
        onChanged: (bool newValue) {
          setState(() {
            _pa.femaleWorthAvailable = newValue;
          });
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
    );
  }

  Widget _legalAidFollowUpQuestions() {
    if (!_pa.supportPreferences.LEGAL_AID_INFO_selected) {
      return Container();
    }
    return _makeQuestion(
      'Does the participant have a functioning smartphone?',
      answer: DropdownButtonFormField<bool>(
        value: _pa.legalAidSmartphoneAvailable,
        onChanged: (bool newValue) {
          if (!newValue) {
            _showDialog('No Smartphone Available', 'Give patient a legal aid leaflet.');
          }
          setState(() {
            _pa.legalAidSmartphoneAvailable = newValue;
          });
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
    );
  }

  Widget _tuneMeFollowUpQuestions() {
    if (!_pa.supportPreferences.TUNE_ME_ORG_selected) {
      return Container();
    }
    return _makeQuestion(
      'Does the participant have a functioning smartphone?',
      answer: DropdownButtonFormField<bool>(
        value: _pa.tuneMeSmartphoneAvailable,
        onChanged: (bool newValue) {
          setState(() {
            _pa.tuneMeSmartphoneAvailable = newValue;
          });
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
    );
  }

  Widget _ntlafatsoFollowUpQuestions() {
    if (!_pa.supportPreferences.NTLAFATSO_FOUNDATION_selected) {
      return Container();
    }
    return _makeQuestion(
      'Does the participant have a functioning smartphone?',
      answer: DropdownButtonFormField<bool>(
        value: _pa.ntlafatsoSmartphoneAvailable,
        onChanged: (bool newValue) {
          setState(() {
            _pa.ntlafatsoSmartphoneAvailable = newValue;
          });
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
    );
  }

  _buildPsychosocialCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle('Psychosocial Support'),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: [
                _shareSomethingQuestion(),
                _shareSomethingContentQuestion(),
                _howDoingQuestion(),
              ],
            ),
          ),
        ),
      ]
    );
  }

  Widget _shareSomethingQuestion() {
    return _makeQuestion('Is there anything you would like to share with me today?',
      answer: DropdownButtonFormField<YesNoRefused>(
        value: _pa.psychosocialShareSomethingAnswer,
        onChanged: (YesNoRefused newValue) {
          setState(() {
            _pa.psychosocialShareSomethingAnswer = newValue;
          });
        },
        validator: (value) {
          if (value == null) { return 'Please answer this question'; }
        },
        items: YesNoRefused.allValues.map<DropdownMenuItem<YesNoRefused>>((YesNoRefused value) {
          return DropdownMenuItem<YesNoRefused>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      )
    );
  }

  Widget _shareSomethingContentQuestion() {
    if (_pa.psychosocialShareSomethingAnswer == null || _pa.psychosocialShareSomethingAnswer != YesNoRefused.YES()) {
      return Container();
    }
    return _makeQuestion('What would like to share with me today?',
        answer: TextFormField(
          controller: _psychoSocialShareCtr,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please specify';
            }
          },
        )
    );
  }

  Widget _howDoingQuestion() {
    return _makeQuestion('How do you think you are doing today?',
        answer: TextFormField(
          controller: _psychoSocialHowDoingCtr,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please specify';
            }
          },
        )
    );
  }

  _buildUnsuppressedCard() {
    if (_patient.mostRecentViralLoad?.isSuppressed ?? false) {
      return Column();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle('Unsuppressed Viral Load'),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: [
                _safeEnvironmentQuestion(),
                _whyNotSafeEnvironmentQuestion(),
              ],
            ),
          ),
        ),
      ]
    );
  }

  Widget _safeEnvironmentQuestion() {
    return _makeQuestion('Do you have a safe environment to take your medication?',
        answer: DropdownButtonFormField<YesNoRefused>(
          value: _pa.unsuppressedSafeEnvironmentAnswer,
          onChanged: (YesNoRefused newValue) {
            setState(() {
              _pa.unsuppressedSafeEnvironmentAnswer = newValue;
            });
          },
          validator: (value) {
            if (value == null) { return 'Please answer this question'; }
          },
          items: YesNoRefused.allValues.map<DropdownMenuItem<YesNoRefused>>((YesNoRefused value) {
            return DropdownMenuItem<YesNoRefused>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        )
    );
  }

  Widget _whyNotSafeEnvironmentQuestion() {
    if (_pa.unsuppressedSafeEnvironmentAnswer == null || _pa.unsuppressedSafeEnvironmentAnswer != YesNoRefused.NO()) {
      return Container();
    }
    return _makeQuestion('Why do you not have a safe environment to take your medication?',
        answer: TextFormField(
          controller: _whyNotSafeEnvironmentCtr,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please specify';
            }
          },
        )
    );
  }

  void _showDialog(String title, String body) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            FlatButton(
              child: Row(children: [Text('OK', textAlign: TextAlign.center)]),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _makeQuestion(String question, {@required Widget answer}) {
    return _makeQuestionCustom(
      question: Text(question),
      answer: answer,
    );
  }

  Widget _makeQuestionCustom({@required Widget question, @required Widget answer}) {

    if (_screenWidth < 400.0) {
      final double _spacingBetweenQuestions = 8.0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: _spacingBetweenQuestions),
          question,
          answer,
          SizedBox(height: _spacingBetweenQuestions),
        ],
      );
    }

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

  bool _validateAdherenceReminderTime() {
    // if the adherence reminder time is not selected when it should be show
    // the error message under the adherence reminder time field and return
    // false.
    if (_patient.phoneAvailability != null && _patient.phoneAvailability == PhoneAvailability.YES() &&
        _pa.adherenceReminderEnabled != null && _pa.adherenceReminderEnabled &&
        _pa.adherenceReminderTime == null) {
      setState(() {
        _adherenceReminderTimeValid = false;
      });
      return false;
    }
    setState(() {
      _adherenceReminderTimeValid = true;
    });
    return true;
  }

  _onSubmitForm() async {
    if (_formKey.currentState.validate() & _validateAdherenceReminderTime()) {
      _pa.artRefillOption1 = _artRefillOptionSelections[0];
      _pa.artRefillOption2 = _artRefillOptionSelections[1];
      _pa.artRefillOption3 = _artRefillOptionSelections[2];
      _pa.artRefillOption4 = _artRefillOptionSelections[3];
      _pa.artRefillOption5 = _artRefillOptionSelections[4];

      if (_artRefillOptionSelections.contains(ARTRefillOption.PE_HOME_DELIVERY())
          && !_artRefillOptionAvailable[_artRefillOptionSelections.indexOf(ARTRefillOption.PE_HOME_DELIVERY())]
          && _pa.artRefillPENotPossibleReason == PEHomeDeliveryNotPossibleReason.OTHER()) {
        _pa.artRefillPENotPossibleReasonOther = _peHomeDeliverWhyNotPossibleReasonOtherCtr.text;
      }
      if (_artRefillOptionSelections.contains(ARTRefillOption.VHW())
          && _artRefillOptionAvailable[_artRefillOptionSelections.indexOf(ARTRefillOption.VHW())]) {
        _pa.artRefillVHWName = _vhwNameCtr.text;
        _pa.artRefillVHWVillage = _vhwVillageCtr.text;
        _pa.artRefillVHWPhoneNumber = _vhwPhoneNumberCtr.text;
      }
      if (_artRefillOptionSelections.contains(ARTRefillOption.TREATMENT_BUDDY())
          && _artRefillOptionAvailable[_artRefillOptionSelections.indexOf(ARTRefillOption.TREATMENT_BUDDY())]) {
        _pa.artRefillTreatmentBuddyART = _treatmentBuddyARTNumberCtr.text;
        _pa.artRefillTreatmentBuddyVillage = _treatmentBuddyVillageCtr.text;
        _pa.artRefillTreatmentBuddyPhoneNumber = _treatmentBuddyPhoneNumberCtr.text;
      }
      if (_patient.phoneAvailability == PhoneAvailability.YES()) {
        if (_patientPhoneNumberBeforeAssessment != _patientPhoneNumberCtr.text) {
          _patient.phoneNumber = _patientPhoneNumberCtr.text;
          _patientUpdated = true;
        }
        if (!_pa.adherenceReminderEnabled) {
          _pa.adherenceReminderTime = null;
        }
      }
      if (_patient.phoneAvailability != PhoneAvailability.YES()) {
        // reset all phone related fields
        _patient.phoneNumber = null;
        _pa.adherenceReminderEnabled = null;
        _pa.adherenceReminderFrequency = null;
        _pa.adherenceReminderMessage = null;
        _pa.adherenceReminderTime = null;
        _pa.artRefillReminderEnabled = null;
        _pa.artRefillReminderDaysBefore = null;
        _pa.vlNotificationEnabled = null;
        _pa.vlNotificationMessageSuppressed = null;
        _pa.vlNotificationMessageUnsuppressed = null;
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
      if (!_pa.supportPreferences.SATURDAY_CLINIC_CLUB_selected) {
        _pa.saturdayClinicClubAvailable = null;
      }
      if (!_pa.supportPreferences.COMMUNITY_YOUTH_CLUB_selected) {
        _pa.communityYouthClubAvailable = null;
      }
      if (!_pa.supportPreferences.HOME_VISIT_PE_selected) {
        _pa.homeVisitPEPossible = null;
        _pa.homeVisitPENotPossibleReason = null;
        _pa.homeVisitPENotPossibleReasonOther = null;
      }
      if (_pa.homeVisitPEPossible != null && !_pa.homeVisitPEPossible
          && _pa.homeVisitPENotPossibleReason != null
          && _pa.homeVisitPENotPossibleReason == HomeVisitPENotPossibleReason.OTHER()) {
        _pa.homeVisitPENotPossibleReasonOther = _homeVisitPENotPossibleReasonCtr.text;
      }
      if (!_pa.supportPreferences.SCHOOL_VISIT_PE_selected) {
        _pa.schoolVisitPEPossible = null;
        _pa.schoolVisitPENotPossibleReason = null;
        _pa.schoolVisitPENotPossibleReasonOther = null;
      }
      if (_pa.schoolVisitPEPossible != null) {
        if (_pa.schoolVisitPEPossible) {
          _pa.school = _schoolCtr.text;
        }
        if (!_pa.schoolVisitPEPossible && _pa.schoolVisitPENotPossibleReason != null
        && _pa.schoolVisitPENotPossibleReason == SchoolVisitPENotPossibleReason.OTHER()) {
          _pa.schoolVisitPENotPossibleReasonOther = _schoolVisitPENotPossibleReasonCtr.text;
        }
      }
      if (!_pa.supportPreferences.PITSO_VISIT_PE_selected) {
        _pa.pitsoPEPossible = null;
        _pa.pitsoPENotPossibleReason = null;
        _pa.pitsoPENotPossibleReasonOther = null;
      }
      if (_pa.pitsoPEPossible != null && !_pa.pitsoPEPossible
          && _pa.pitsoPENotPossibleReason != null
          && _pa.pitsoPENotPossibleReason == PitsoPENotPossibleReason.OTHER()) {
        _pa.pitsoPENotPossibleReasonOther = _pitsoVisitPENotPossibleReasonCtr.text;
      }
      if (!_pa.supportPreferences.CONDOM_DEMO_selected) {
        _pa.condomUsageDemonstrated = null;
        _pa.condomUsageNotDemonstratedReason = null;
        _pa.condomUsageNotDemonstratedReasonOther = null;
      }
      if (_pa.condomUsageDemonstrated != null && !_pa.condomUsageDemonstrated
          && _pa.condomUsageNotDemonstratedReason != null
          && _pa.condomUsageNotDemonstratedReason == CondomUsageNotDemonstratedReason.OTHER()) {
        _pa.condomUsageNotDemonstratedReasonOther = _condomUsageNotDemonstratedReasonCtr.text;
      }
      if (_pa.supportPreferences.CONTRACEPTIVES_INFO_selected) {
        _pa.moreInfoContraceptives = _contraceptivesMoreInfoCtr.text;
      }
      if (_pa.supportPreferences.VMMC_INFO_selected) {
        _pa.moreInfoVMMC = _vmmcMoreInfoCtr.text;
      }
      if (!_pa.supportPreferences.YOUNG_MOTHERS_GROUP_selected) {
        _pa.youngMothersAvailable = null;
      }
      if (!_pa.supportPreferences.FEMALE_WORTH_GROUP_selected) {
        _pa.femaleWorthAvailable = null;
      }
      if (!_pa.supportPreferences.LEGAL_AID_INFO_selected) {
        _pa.legalAidSmartphoneAvailable = null;
      }
      if (!_pa.supportPreferences.TUNE_ME_ORG_selected) {
        _pa.tuneMeSmartphoneAvailable = null;
      }
      if (!_pa.supportPreferences.NTLAFATSO_FOUNDATION_selected) {
        _pa.ntlafatsoSmartphoneAvailable = null;
      }
      if (_pa.psychosocialShareSomethingAnswer == YesNoRefused.YES()) {
        _pa.psychosocialShareSomethingContent = _psychoSocialShareCtr.text;
      }
      _pa.psychosocialHowDoing = _psychoSocialHowDoingCtr.text;
      if (_pa.unsuppressedSafeEnvironmentAnswer != null && _pa.unsuppressedSafeEnvironmentAnswer == YesNoRefused.NO()) {
        _pa.unsuppressedWhyNotSafe = _whyNotSafeEnvironmentCtr.text;
      }

      print('NEW PREFERENCE ASSESSMENT (_id will be given by SQLite database):\n$_pa');
      await PatientBloc.instance.sinkPreferenceAssessmentData(_pa);
      if (_patientUpdated) {
        print('PATIENT UPDATED, INSERTING NEW PATIENT ROW FOR ${_patient.artNumber}');
        await PatientBloc.instance.sinkPatientData(_patient);
      }
      final String newPEPhoneNumber = _pePhoneNumberCtr.text;
      if (newPEPhoneNumber != _user.phoneNumber) {
        _user.phoneNumber = newPEPhoneNumber;
        DatabaseProvider().insertUserData(_user);
      }
      uploadNotificationsPreferences(_patient, _pa);
      Navigator.of(context).pop(); // close Preference Assessment screen
      showFlushbar('Preference Assessment saved');
    } else {
      showFlushbar("Errors exist in the assessment form. Please check the form.");
    }
  }
}
