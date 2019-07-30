import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/Gender.dart';
import 'package:pebrapp/database/beans/PhoneAvailability.dart';
import 'package:pebrapp/database/beans/SexualOrientation.dart';
import 'package:pebrapp/database/beans/ViralLoadSource.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/InputFormatters.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:pebrapp/database/beans/NoConsentReason.dart';

class NewPatientScreen extends StatefulWidget {

  @override
  _NewPatientFormState createState() {
    return _NewPatientFormState();
  }
}

class _NewPatientFormState extends State<NewPatientScreen> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  final _formKey = GlobalKey<FormState>();

  final _questionsFlex = 1;
  final _answersFlex = 1;

  static final int minAgeForEligibility = 15;
  static final int maxAgeForEligibility = 24;
  static final DateTime now = DateTime.now();
  static final DateTime minBirthdayForEligibility = DateTime(now.year - maxAgeForEligibility - 1, now.month, now.day + 1);
  static final DateTime maxBirthdayForEligibility = DateTime(now.year - minAgeForEligibility, now.month, now.day);
  bool get _eligible => _newPatient.birthday != null && !_newPatient.birthday.isBefore(minBirthdayForEligibility) && !_newPatient.birthday.isAfter(maxBirthdayForEligibility);
  bool get _notEligibleAfterBirthdaySpecified => _newPatient.birthday != null && !_eligible;

  Patient _newPatient = Patient(isActivated: true);
  ViralLoad _viralLoadBaseline = ViralLoad(source: ViralLoadSource.MANUAL_INPUT(), failed: false);
  bool _isLowerThanDetectable;

  TextEditingController _artNumberCtr = TextEditingController();
  TextEditingController _stickerNumberCtr = TextEditingController();
  TextEditingController _villageCtr = TextEditingController();
  TextEditingController _phoneNumberCtr = TextEditingController();
  TextEditingController _noConsentReasonOtherCtr = TextEditingController();
  TextEditingController _viralLoadBaselineResultCtr = TextEditingController();
  TextEditingController _viralLoadBaselineLabNumberCtr = TextEditingController();

  // this field is used to display an error when the form is validated and if
  // the viral load baseline date is not selected
  bool _viralLoadBaselineDateValid = true;
  bool _patientBirthdayValid = true;

  List<String> _artNumbersInDB;
  List<String> _stickerNumbersInDB;
  bool _isLoading = true;

  double _screenWidth;

  // stepper state
  bool _patientSaved = false;
  bool _kobocollectOpened = false;
  bool _stepperFinished = false;
  int currentStep = 0;

  @override
  initState() {
    super.initState();
    DatabaseProvider().retrieveLatestPatients(retrieveNonEligibles: false, retrieveNonConsents: false).then((List<Patient> patients) {
      setState(() {
        _artNumbersInDB = patients.map((Patient p) => p.artNumber).toList();
        _stickerNumbersInDB = patients.map((Patient p) => p.stickerNumber).toList();
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    _screenWidth = MediaQuery.of(context).size.width;

    final Form patientCharacteristicsStep = Form(
      key: _formKey,
      child: Column(
        children: [
          _personalInformationCard(),
          _eligibilityDisclaimer(),
          _consentCard(),
          _additionalInformationCard(),
          _viralLoadBaselineCard(),
          _notEligibleDisclaimer(),
        ],
      ),
    );

    final String bullet = '‣';
    final Widget baselineAssessmentStep = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Open the KoBoCollect app and fill in the following questionnaires:\n'
            '$bullet  Enrollment questionnaire\n'
            '$bullet  Satisfaction questionnaire\n'
            '$bullet  Quality of Life questionnaire\n'
            '$bullet  Adherence questionnaire',
          style: TextStyle(height: 1.8),
        ),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [PEBRAButtonRaised('Open KoBoCollect', onPressed: _onOpenKoboCollectPressed)],
        ),
        SizedBox(height: 20.0),
      ],
    );

    Widget finishStep() {
      if (_patientSaved && (_kobocollectOpened || !(_newPatient.consentGiven ?? true))) {
        return Container(
          width: double.infinity,
          child: Text("All done! You can close this screen by tapping ✓ below."),
        );
      }
      return
        Container(width: double.infinity, child: Text('Please complete the previous steps!'));
    }

    List<Step> steps = [
      Step(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Patient Characteristics', style: TextStyle(fontWeight: currentStep == 0 ? FontWeight.bold : FontWeight.normal)),
            SizedBox(width: 10.0),
            _isLoading ? SizedBox(height: 10.0, width: 10.0, child: CircularProgressIndicator()) : Container(),
          ],
        ),
        isActive: _patientSaved,
        state: _patientSaved ? StepState.complete : StepState.indexed,
        content: patientCharacteristicsStep,
      ),
      Step(
        title: Text('Baseline Assessment', style: TextStyle(fontWeight: currentStep == 1 ? FontWeight.bold : FontWeight.normal)),
        isActive: _kobocollectOpened,
        state: _kobocollectOpened || !(_newPatient.consentGiven ?? true) ? StepState.complete : StepState.indexed,
        content: baselineAssessmentStep,
      ),
      Step(
        title: Text('Finish', style: TextStyle(fontWeight: currentStep == 2 ? FontWeight.bold : FontWeight.normal)),
        isActive: _stepperFinished,
        state: _stepperFinished ? StepState.complete : StepState.indexed,
        content: finishStep(),
      ),
    ];

    goTo(int step) {
      if (step == 0 && _patientSaved) {
        // do not allow going back to first step if the patient has already
        // been saved
        return;
      }
      if (step == 1 && !(_newPatient.consentGiven ?? true)) {
        // skip going to step 'baseline assessment' if no consent is given and
        // we are coming from step 'patient characteristics'
        if (currentStep == 0) {
          setState(() => currentStep = step + 1);
        }
        // do not allow going to step 'baseline assessment' if no consent is
        // given
        return;
      }
      setState(() => currentStep = step);
    }

    next() async {
      switch (currentStep) {
        // patient characteristics form
        case 0:
          if (await _onSubmitForm()) {
            setState(() { _patientSaved = true; });
            goTo(1);
          }
          break;
        // baseline assessment
        case 1:
          goTo(2);
          break;
        // finish
        case 2:
          if (_patientSaved) {
            setState(() { _stepperFinished = true; });
            _closeScreen();
          }
      }
    }

    cancel() {
      if (currentStep > 0) {
        goTo(currentStep - 1);
      } else if (currentStep == 0) {
        _closeScreen();
      }
    }

    Widget stepper() {
      return Stepper(
        steps: steps,
//      type: StepperType.horizontal,
        currentStep: currentStep,
        onStepTapped: goTo,
        onStepContinue: (_isLoading || (currentStep == 2 && (!_patientSaved ||
            (!_kobocollectOpened && (_newPatient.consentGiven ?? false)))))
            ? null
            : next,
        onStepCancel: (currentStep == 1 && _patientSaved ||
            (currentStep == 2 && !(_newPatient.consentGiven ?? true)))
            ? null
            : cancel,
        controlsBuilder: (BuildContext context,
            {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
          final Color navigationButtonsColor = Colors.blue;
          return Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                currentStep == 0 || currentStep == 1
                ? SizedBox()
                : Container(
                  decoration: BoxDecoration(
                    color: onStepCancel == null
                        ? BUTTON_INACTIVE
                        : (currentStep == 0
                        ? STEPPER_ABORT
                        : navigationButtonsColor),
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: IconButton(
                    color: Colors.white,
                    onPressed: onStepCancel,
                    icon: Icon(currentStep == 0 ? Icons.close : Icons
                        .keyboard_arrow_up),
                  ),
                ),
                SizedBox(width: 20.0),
                Container(
                  decoration: BoxDecoration(
                    color: onStepContinue == null
                        ? BUTTON_INACTIVE
                        : (currentStep == 2
                        ? STEPPER_FINISH
                        : navigationButtonsColor),
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: IconButton(
                    color: Colors.white,
                    onPressed: onStepContinue,
                    icon: Icon(currentStep == 2 ? Icons.check : Icons
                        .keyboard_arrow_down),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return PopupScreen(
      title: 'New Patient',
      actions: _patientSaved ? [] : null,
      child: stepper(),
      scrollable: false,
    );

  }

  // ----------
  // CARDS
  // ----------

  Widget _personalInformationCard() {
    return _buildCard('Personal Information',
      withTopPadding: false,
      child: Column(
        children: [
          _artNumberQuestion(),
          _birthdayQuestion(),
        ],
      ),
    );
  }

  Widget _consentCard() {
    if (_notEligibleAfterBirthdaySpecified) {
      return Container();
    }
    return _buildCard('Consent',
      child: Column(
        children: [
          _consentGivenQuestion(),
          _noConsentReasonQuestion(),
          _noConsentReasonOtherQuestion(),
        ],
      ),
    );
  }

  Widget _additionalInformationCard() {
    if (_notEligibleAfterBirthdaySpecified || _newPatient.consentGiven == null || !_newPatient.consentGiven) {
      return SizedBox();
    }
    return _buildCard('Additional Information',
      child: Column(
        children: [
          _stickerNumberQuestion(),
          _genderQuestion(),
          _sexualOrientationQuestion(),
          _villageQuestion(),
          _phoneAvailabilityQuestion(),
          _phoneNumberQuestion(),
        ],
      ),
    );
  }

  Widget _viralLoadBaselineCard() {
    if (_notEligibleAfterBirthdaySpecified || _newPatient.consentGiven == null || !_newPatient.consentGiven) {
      return Container();
    }
    const double _spaceBetweenQuestions = 5.0;
    return _buildCard('Viral Load Baseline',
      child: Column(
        children: [
          _viralLoadBaselineAvailableQuestion(),
          SizedBox(height: _spaceBetweenQuestions),
          _viralLoadBaselineDateQuestion(),
          SizedBox(height: _spaceBetweenQuestions),
          _viralLoadBaselineLowerThanDetectableQuestion(),
          SizedBox(height: _spaceBetweenQuestions),
          _viralLoadBaselineResultQuestion(),
          SizedBox(height: _spaceBetweenQuestions),
          _viralLoadBaselineLabNumberQuestion(),
        ],
      ),
    );
  }

  // ----------
  // QUESTIONS
  // ----------

  Widget _artNumberQuestion() {
    return _makeQuestion('ART Number',
      answer: TextFormField(
        controller: _artNumberCtr,
        inputFormatters: [
          WhitelistingTextInputFormatter(RegExp('[A-Za-z0-9]')),
          LengthLimitingTextInputFormatter(8),
          ARTNumberTextInputFormatter(),
        ],
        validator: (String value) {
          if (_artNumberExists(value)) {
            return 'Patient with this ART number already exists';
          }
          return validateARTNumber(value);
          },
      ),
    );
  }

  Widget _stickerNumberQuestion() {
    return _makeQuestion('Sticker Number',
      answer: TextFormField(
        decoration: InputDecoration(
          errorMaxLines: 2,
          prefixText: 'P',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          WhitelistingTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        controller: _stickerNumberCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter the sticker number';
          } else if (value.length != 3) {
            return 'Exactly 3 digits required';
          } else if (_stickerNumberExists('P$value')) {
            return 'Patient with this sticker number already exists';
          }
          return null;
        },
      ),
    );
  }

  Widget _birthdayQuestion() {
    return _makeQuestion('Birthday',
        answer: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlatButton(
              padding: EdgeInsets.all(0.0),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  _newPatient.birthday == null ? '' : '${formatDateConsistent(_newPatient.birthday)} (age ${calculateAge(_newPatient.birthday)})',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              onPressed: () async {
                DateTime date = await showDatePicker(
                  context: context,
                  initialDate: _newPatient.birthday ?? minBirthdayForEligibility,
                  firstDate: minBirthdayForEligibility,
                  lastDate: maxBirthdayForEligibility,
                );
                if (date != null) {
                  setState(() {
                    _newPatient.birthday = date;
                  });
                }
              },
            ),
            Divider(color: CUSTOM_FORM_FIELD_UNDERLINE, height: 1.0,),
            _patientBirthdayValid ? Container() : Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                'Please select a date',
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

  Widget _genderQuestion() {
    return _makeQuestion(
      'Gender',
      answer: DropdownButtonFormField<Gender>(
        value: _newPatient.gender,
        onChanged: (Gender newValue) {
          setState(() {
            _newPatient.gender = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
          return null;
        },
        items: Gender.allValues.map<DropdownMenuItem<Gender>>((Gender value) {
          return DropdownMenuItem<Gender>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _sexualOrientationQuestion() {
    return _makeQuestion(
      'Sexual Orientation',
      answer: DropdownButtonFormField<SexualOrientation>(
        value: _newPatient.sexualOrientation,
        onChanged: (SexualOrientation newValue) {
          setState(() {
            _newPatient.sexualOrientation = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
          return null;
        },
        items: SexualOrientation.allValues.map<DropdownMenuItem<SexualOrientation>>((SexualOrientation value) {
          return DropdownMenuItem<SexualOrientation>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _villageQuestion() {
    return _makeQuestion(
      'Village',
      answer: TextFormField(
          controller: _villageCtr,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter a village';
            }
            return null;
          },
        ),
      );
  }

  Widget _phoneAvailabilityQuestion() {
    return _makeQuestion('Do you have regular access to a phone (with Lesotho number) where you can receive confidential information?',
      answer: DropdownButtonFormField<PhoneAvailability>(
        value: _newPatient.phoneAvailability,
        onChanged: (PhoneAvailability newValue) {
          setState(() {
            _newPatient.phoneAvailability = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
          return null;
        },
        items: PhoneAvailability.allValues.map<DropdownMenuItem<PhoneAvailability>>((PhoneAvailability value) {
          return DropdownMenuItem<PhoneAvailability>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _phoneNumberQuestion() {
    if (_newPatient.phoneAvailability == null || _newPatient.phoneAvailability != PhoneAvailability.YES()) {
      return Container();
    }
    return _makeQuestion('Phone Number',
        answer: TextFormField(
          decoration: InputDecoration(
            prefixText: '+266-',
          ),
          controller: _phoneNumberCtr,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            WhitelistingTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
            LesothoPhoneNumberTextInputFormatter(),
          ],
          validator: validatePhoneNumber,
        ),
    );
  }

  Widget _consentGivenQuestion() {
    return _makeQuestion('Has the patient signed the consent form?',
      answer: DropdownButtonFormField<bool>(
        value: _newPatient.consentGiven,
        onChanged: (bool newValue) {
          setState(() {
            _newPatient.consentGiven = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
          return null;
        },
        items: [true, false].map<DropdownMenuItem<bool>>((bool value) {
          String description = value ? 'Yes' : 'No';
          return DropdownMenuItem<bool>(
            value: value,
            child: Text(description),
          );
        }).toList(),
      ),
    );
  }

  Widget _noConsentReasonQuestion() {
    if (_newPatient.consentGiven == null || _newPatient.consentGiven) {
      return Container();
    }
    return _makeQuestion('Reason for refusal',
      answer: DropdownButtonFormField<NoConsentReason>(
        value: _newPatient.noConsentReason,
        onChanged: (NoConsentReason newValue) {
          setState(() {
            _newPatient.noConsentReason = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
          return null;
        },
        items: NoConsentReason.allValues.map<DropdownMenuItem<NoConsentReason>>((NoConsentReason value) {
          return DropdownMenuItem<NoConsentReason>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _noConsentReasonOtherQuestion() {
    if (_newPatient.consentGiven == null || _newPatient.consentGiven || _newPatient.noConsentReason == null || _newPatient.noConsentReason != NoConsentReason.OTHER()) {
      return Container();
    }
    return _makeQuestion('Other, specify',
      answer: TextFormField(
        controller: _noConsentReasonOtherCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify the reasons';
          }
          return null;
        },
      ),
    );
  }

  Widget _viralLoadBaselineAvailableQuestion() {
    return _makeQuestion('Is there any viral load within the last 12 months available (laboratory report, bukana, patient file)?',
      answer: DropdownButtonFormField<bool>(
        value: _newPatient.isVLBaselineAvailable,
        onChanged: (bool newValue) {
          if (!newValue) {
            _showDialog('No Viral Load Available', 'Send the participant to the nurse for blood draw today!');
          }
          setState(() {
            _newPatient.isVLBaselineAvailable = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
          return null;
        },
        items: [true, false].map<DropdownMenuItem<bool>>((bool value) {
          String description = value ? 'Yes' : 'No';
          return DropdownMenuItem<bool>(
            value: value,
            child: Text(description),
          );
        }).toList(),
      ),
    );
  }

  Widget _viralLoadBaselineDateQuestion() {
    if (_newPatient.isVLBaselineAvailable == null || !_newPatient.isVLBaselineAvailable) {
      return Container();
    }
    return _makeQuestion('Date of the most recent available viral load (put the date when blood was taken)',
      answer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlatButton(
            padding: EdgeInsets.all(0.0),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                _viralLoadBaseline.dateOfBloodDraw == null ? '' : formatDateConsistent(_viralLoadBaseline.dateOfBloodDraw),
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            onPressed: () async {
              final now = DateTime.now();
              DateTime date = await showDatePicker(
                context: context,
                initialDate: _viralLoadBaseline.dateOfBloodDraw ?? DateTime(now.year, now.month, now.day),
                firstDate: DateTime(now.year - 1, now.month, now.day),
                lastDate: DateTime(now.year, now.month, now.day),
              );
              if (date != null) {
                setState(() {
                  _viralLoadBaseline.dateOfBloodDraw = date;
                });
              }
            },
          ),
          Divider(color: CUSTOM_FORM_FIELD_UNDERLINE, height: 1.0,),
          _viralLoadBaselineDateValid ? Container() : Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              'Please select a date',
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

  Widget _viralLoadBaselineLowerThanDetectableQuestion() {
    if (_newPatient.isVLBaselineAvailable == null || !_newPatient.isVLBaselineAvailable) {
      return Container();
    }
    return _makeQuestion('Was that viral load result lower than detectable limit (<20 copies/mL)?',
      answer: DropdownButtonFormField<bool>(
        value: _isLowerThanDetectable,
        onChanged: (bool newValue) {
          setState(() {
            _isLowerThanDetectable = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please answer this question.';
          }
          return null;
        },
        items: [true, false].map<DropdownMenuItem<bool>>((bool value) {
          String description = value ? 'Yes' : 'No';
          return DropdownMenuItem<bool>(
            value: value,
            child: Text(description),
          );
        }).toList(),
      ),
    );
  }

  Widget _viralLoadBaselineResultQuestion() {
    if (_newPatient.isVLBaselineAvailable == null || !_newPatient.isVLBaselineAvailable || _isLowerThanDetectable == null || _isLowerThanDetectable) {
      return Container();
    }
    return _makeQuestion('Result of that viral load (in c/mL)',
      answer: TextFormField(
        inputFormatters: [
          WhitelistingTextInputFormatter.digitsOnly,
        ],
        keyboardType: TextInputType.numberWithOptions(),
        controller: _viralLoadBaselineResultCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter the viral load baseline result';
          } else if (int.parse(value) < 20) {
            return 'Value must be ≥ 20 (otherwise it is lower than detectable limit)';
          }
          return null;
        },
      ),
    );
  }

  Widget _viralLoadBaselineLabNumberQuestion() {
    if (_newPatient.isVLBaselineAvailable == null || !_newPatient.isVLBaselineAvailable) {
      return Container();
    }
    return _makeQuestion('Lab number of that viral load',
      answer: TextFormField(
        controller: _viralLoadBaselineLabNumberCtr,
        decoration: InputDecoration(
          errorMaxLines: 2,
        ),
        inputFormatters: [
          WhitelistingTextInputFormatter(RegExp(r'[a-zA-Z0-9]')),
          LengthLimitingTextInputFormatter(13),
          LabNumberTextInputFormatter(),
        ],
        validator: validateLabNumber,
      ),
    );
  }

  // ----------
  // OTHER
  // ----------

  Widget _eligibilityDisclaimer() {
    if (_newPatient.birthday != null) {
      return Container();
    }
    return
      Padding(
        padding: EdgeInsets.only(top: 15.0),
        child:
        Text('Only patients between ages $minAgeForEligibility and $maxAgeForEligibility are eligible.',
          textAlign: TextAlign.left,
        ),
      );
  }

  Widget _notEligibleDisclaimer() {
    if (_newPatient.birthday == null || _eligible) {
      return Container();
    }
    return
      Padding(
        padding: EdgeInsets.only(top: 15.0),
        child:
        Text('This patient is not eligible for the study. Only patients born '
            'between ${formatDateConsistent(minBirthdayForEligibility)} and '
            '${formatDateConsistent(maxBirthdayForEligibility)} are '
            'eligible. The patient will not appear in the PEBRApp.',
          textAlign: TextAlign.left,
        ),
      );
  }

  bool _validateViralLoadBaselineDate() {
    // if the viral load baseline date is not selected when it should be show
    // the error message under the viral load baseline date field and return
    // false.
    if (_eligible && _newPatient.consentGiven != null && _newPatient.consentGiven && _newPatient.isVLBaselineAvailable != null && _newPatient.isVLBaselineAvailable && _viralLoadBaseline.dateOfBloodDraw == null) {
      setState(() {
        _viralLoadBaselineDateValid = false;
      });
      return false;
    }
    setState(() {
      _viralLoadBaselineDateValid = true;
    });
    return true;
  }

  bool _validatePatientBirthday() {
    // if the birthday is not specified show the error message under the
    // birthday field and return false.
    if (_newPatient.birthday == null) {
      setState(() {
        _patientBirthdayValid = false;
      });
      return false;
    }
    setState(() {
      _patientBirthdayValid = true;
    });
    return true;
  }

  /// Returns true if the form validation succeeds and the patient was saved
  /// successfully.
  Future<bool> _onSubmitForm() async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState.validate() & _validatePatientBirthday() & _validateViralLoadBaselineDate()) {

      final DateTime now = DateTime.now();

      _newPatient.enrollmentDate = now;
      _newPatient.isEligible = _eligible;
      _newPatient.artNumber = _artNumberCtr.text;
      _newPatient.stickerNumber = (_newPatient.consentGiven ?? false) ? 'P${_stickerNumberCtr.text}' : null;
      _newPatient.village = _villageCtr.text;
      _newPatient.phoneNumber = '+266-${_phoneNumberCtr.text}';
      _newPatient.noConsentReasonOther = _noConsentReasonOtherCtr.text;
      _newPatient.village = _villageCtr.text;
      _newPatient.village = _villageCtr.text;
      _newPatient.village = _villageCtr.text;
      _newPatient.checkLogicAndResetUnusedFields();

      if (_newPatient.isEligible && _newPatient.consentGiven) {
        await DatabaseProvider().insertRequiredAction(RequiredAction(_newPatient.artNumber, RequiredActionType.ADHERENCE_QUESTIONNAIRE_2P5M_REQUIRED, addMonths(now, 2, addHalfMonth: true)));
        await DatabaseProvider().insertRequiredAction(RequiredAction(_newPatient.artNumber, RequiredActionType.ADHERENCE_QUESTIONNAIRE_5M_REQUIRED, addMonths(now, 5)));
        await DatabaseProvider().insertRequiredAction(RequiredAction(_newPatient.artNumber, RequiredActionType.ADHERENCE_QUESTIONNAIRE_9M_REQUIRED, addMonths(now, 9)));
        await DatabaseProvider().insertRequiredAction(RequiredAction(_newPatient.artNumber, RequiredActionType.SATISFACTION_QUESTIONNAIRE_5M_REQUIRED, addMonths(now, 5)));
        await DatabaseProvider().insertRequiredAction(RequiredAction(_newPatient.artNumber, RequiredActionType.SATISFACTION_QUESTIONNAIRE_9M_REQUIRED, addMonths(now, 9)));
        await DatabaseProvider().insertRequiredAction(RequiredAction(_newPatient.artNumber, RequiredActionType.QUALITY_OF_LIFE_QUESTIONNAIRE_5M_REQUIRED, addMonths(now, 5)));
        await DatabaseProvider().insertRequiredAction(RequiredAction(_newPatient.artNumber, RequiredActionType.QUALITY_OF_LIFE_QUESTIONNAIRE_9M_REQUIRED, addMonths(now, 9)));
        await DatabaseProvider().insertRequiredAction(RequiredAction(_newPatient.artNumber, RequiredActionType.VIRAL_LOAD_9M_REQUIRED, addMonths(now, 9)));
      }

      if (_newPatient.isEligible && _newPatient.consentGiven){
        if (_newPatient.isVLBaselineAvailable) {
          _viralLoadBaseline.patientART = _artNumberCtr.text;
          _viralLoadBaseline.viralLoad = _isLowerThanDetectable ? 0 : int.parse(_viralLoadBaselineResultCtr.text);
          _viralLoadBaseline.labNumber = _viralLoadBaselineLabNumberCtr.text == '' ? null : _viralLoadBaselineLabNumberCtr.text;
          _viralLoadBaseline.checkLogicAndResetUnusedFields();
          await DatabaseProvider().insertViralLoad(_viralLoadBaseline);
          _newPatient.viralLoads = [_viralLoadBaseline];
        } else {
          // if no baseline viral load is available, send the patient to blood draw
          RequiredAction vlRequired = RequiredAction(_artNumberCtr.text, RequiredActionType.VIRAL_LOAD_MEASUREMENT_REQUIRED, DateTime.fromMillisecondsSinceEpoch(0));
          DatabaseProvider().insertRequiredAction(vlRequired);
          PatientBloc.instance.sinkRequiredActionData(vlRequired, false);
        }
      }

      await _newPatient.initializeRequiredActionsField();
      await DatabaseProvider().insertPatient(_newPatient);
      await PatientBloc.instance.sinkNewPatientData(_newPatient);
      setState(() {
        _isLoading = false;
      });
      return true;
    }
    setState(() {
      _isLoading = false;
    });
    return false;
  }

  void _closeScreen() {
    Navigator.of(context).popUntil((Route<dynamic> route) {
      return (route.settings.name == '/');
    });
  }

  Future<void> _onOpenKoboCollectPressed() async {
    setState(() { _kobocollectOpened = true; });
    await openKoboCollectApp();
  }

  Widget _buildCard(String title, {@required Widget child, bool withTopPadding: true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: withTopPadding ? 20.0 : 0.0),
        _buildTitle(title),
        SizedBox(height: 10.0),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 0.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _makeQuestion(String question, {@required Widget answer}) {

    if (_screenWidth < 400.0) {
      final double _spacingBetweenQuestions = 8.0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: _spacingBetweenQuestions),
          Text(question),
          answer,
          SizedBox(height: _spacingBetweenQuestions),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: _questionsFlex,
          child: Text(question),
        ),
        SizedBox(width: 10.0),
        Expanded(
          flex: _answersFlex,
          child: answer,
        ),
      ],
    );
    
  }

  bool _artNumberExists(artNumber) {
    return _artNumbersInDB.contains(artNumber);
  }

  bool _stickerNumberExists(stickerNumber) {
    return _stickerNumbersInDB.contains(stickerNumber);
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

}
