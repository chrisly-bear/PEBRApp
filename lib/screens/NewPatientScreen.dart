import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/Gender.dart';
import 'package:pebrapp/database/beans/PhoneAvailability.dart';
import 'package:pebrapp/database/beans/SexualOrientation.dart';
import 'package:pebrapp/database/beans/ViralLoadSource.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pebrapp/database/beans/NoConsentReason.dart';

class NewPatientScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 224, 224, 224),
        appBar: AppBar(
          title: const Text('New Patient', key: Key('newOrEditPatientTitle'),),
        ),
        body: Center(
          child: _NewPatientScreenBody(),
        ));
  }
}

class _NewPatientScreenBody extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(child: _NewPatientForm()),
    ]);
  }
}

// https://flutter.dev/docs/cookbook/forms/validation
class _NewPatientForm extends StatefulWidget {

  @override
  _NewPatientFormState createState() {
    return _NewPatientFormState();
  }
}

class _NewPatientFormState extends State<_NewPatientForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  final _formKey = GlobalKey<FormState>();

  final _questionsFlex = 1;
  final _answersFlex = 1;

  static final currentYear = DateTime.now().year;

  static final int birthYearOptionsStart = 1990;
  static final int birthYearOptionsEnd = currentYear;
  List<int> birthYearOptions = List<int>.generate(birthYearOptionsEnd - birthYearOptionsStart + 1, (i) => birthYearOptionsStart + i);

  static final int minAgeForEligibility = 15;
  static final int maxAgeForEligibility = 18;
  static final int minYearForEligibility = currentYear - maxAgeForEligibility;
  static final int maxYearForEligibility = currentYear - minAgeForEligibility;
  bool get _eligible => _newPatient.yearOfBirth != null && _newPatient.yearOfBirth >= minYearForEligibility && _newPatient.yearOfBirth <= maxYearForEligibility;

  Patient _newPatient = Patient(isActivated: true);
  ViralLoad _viralLoadBaseline = ViralLoad(source: ViralLoadSource.MANUAL_INPUT(), isBaseline: true);

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

  List<String> _artNumbersInDB;
  bool get _isLoading { return _artNumbersInDB == null; }

  @override
  initState() {
    super.initState();
    DatabaseProvider().retrievePatientsART(retrieveNonEligibles: false, retrieveNonConsents: false).then((artNumbers) {
      setState(() {
        _artNumbersInDB = artNumbers;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
          children: [
            _personalInformationCard(),
            _consentCard(),
            _viralLoadBaselineCard(),
            _eligibilityDisclaimer(),
            SizedBox(height: 16.0),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              PEBRAButtonRaised(
                'Save',
                onPressed: _isLoading ? null : _onSubmitForm,
              ),
            ]),
            SizedBox(height: 16.0),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              PEBRAButtonRaised(
                'Open KoBoCollect',
                onPressed: _openKoBoCollect,
              ),
            ]),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
              child: Text('Open the KoBoCollect app to fill in the baseline assessment form.', textAlign: TextAlign.center,),
            ),
            SizedBox(height: 16.0),
          ],
      ),
    );
  }

  // ----------
  // CARDS
  // ----------

  Widget _personalInformationCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle('Personal Information'),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: [
                _artNumberQuestion(),
                _stickerNumberQuestion(),
                _yearOfBirthQuestion(),
                _genderQuestion(),
                _sexualOrientationQuestion(),
                _villageQuestion(),
                _phoneAvailabilityQuestion(),
                _phoneNumberQuestion(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _consentCard() {
    if (!_eligible) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle('Consent'),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: [
                _consentGivenQuestion(),
                _noConsentReasonQuestion(),
                _noConsentReasonOtherQuestion(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _viralLoadBaselineCard() {
    if (!_eligible || _newPatient.consentGiven == null || !_newPatient.consentGiven) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle('Viral Load Baseline'),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: [
                _viralLoadBaselineAvailableQuestion(),
                _viralLoadBaselineDateQuestion(),
                _viralLoadBaselineLowerThanDetectableQuestion(),
                _viralLoadBaselineResultQuestion(),
                _viralLoadBaselineLabNumberQuestion(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ----------
  // QUESTIONS
  // ----------

  Widget _artNumberQuestion() {
    return _makeQuestion('ART Number',
      child: TextFormField(
        controller: _artNumberCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter an ART number';
          } else if (_artNumberExists(value)) {
            return 'This ART number exists already in the database';
          }
        },
      ),
    );
  }

  Widget _stickerNumberQuestion() {
    return _makeQuestion('Sticker Number',
      child: TextFormField(
        controller: _stickerNumberCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter the sticker number';
          }
        },
      ),
    );
  }

  Widget _yearOfBirthQuestion() {
    return _makeQuestion('Year of Birth',
        child: DropdownButtonFormField<int>(
          value: _newPatient.yearOfBirth,
          onChanged: (int newValue) {
            setState(() {
              _newPatient.yearOfBirth = newValue;
            });
          },
          validator: (value) {
            if (value == null) { return 'Please select a year of birth.'; }
          },
          items: birthYearOptions.map<DropdownMenuItem<int>>((int value) {
            String description = value.toString();
            return DropdownMenuItem<int>(
              value: value,
              child: Text(
                description,
                style: TextStyle(
                  color: value <= maxYearForEligibility && value >= minYearForEligibility ? Colors.black : Colors.grey,
                ),
              ),
            );
          }).toList(),
        ),
    );
  }

  Widget _genderQuestion() {
    if (!_eligible || _newPatient.consentGiven == null || !_newPatient.consentGiven) {
      return Container();
    }
    return _makeQuestion(
      'Gender',
      child: DropdownButtonFormField<Gender>(
        value: _newPatient.gender,
        onChanged: (Gender newValue) {
          setState(() {
            _newPatient.gender = newValue;
          });
        },
        validator: (value) {
          if (value == null) { return 'Please answer this question.'; }
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
    if (!_eligible || _newPatient.consentGiven == null || !_newPatient.consentGiven) {
      return Container();
    }
    return _makeQuestion(
      'Sexual Orientation',
      child: DropdownButtonFormField<SexualOrientation>(
        value: _newPatient.sexualOrientation,
        onChanged: (SexualOrientation newValue) {
          setState(() {
            _newPatient.sexualOrientation = newValue;
          });
        },
        validator: (value) {
          if (value == null) { return 'Please answer this question.'; }
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
    if (!_eligible || _newPatient.consentGiven == null || !_newPatient.consentGiven) {
      return Container();
    }
    return _makeQuestion(
      'Village',
      child: TextFormField(
          controller: _villageCtr,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter a village';
            }
          },
        ),
      );
  }

  Widget _phoneAvailabilityQuestion() {
    if (!_eligible || _newPatient.consentGiven == null || !_newPatient.consentGiven) {
      return Container();
    }
    return _makeQuestion('Do you have regular access to a phone (with Lesotho number) where you can receive confidential information?',
      child: DropdownButtonFormField<PhoneAvailability>(
        value: _newPatient.phoneAvailability,
        onChanged: (PhoneAvailability newValue) {
          setState(() {
            _newPatient.phoneAvailability = newValue;
          });
        },
        validator: (value) {
          if (value == null) { return 'Please answer this question.'; }
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
    if (!_eligible || _newPatient.consentGiven == null || !_newPatient.consentGiven || _newPatient.phoneAvailability == null || _newPatient.phoneAvailability != PhoneAvailability.YES()) {
      return Container();
    }
    return _makeQuestion('Phone Number',
        child: TextFormField(
          controller: _phoneNumberCtr,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter a phone number';
            }
          },
        ),
    );
  }

  Widget _consentGivenQuestion() {
    return _makeQuestion('Has the patient signed the consent form?',
      child: DropdownButtonFormField<bool>(
        value: _newPatient.consentGiven,
        onChanged: (bool newValue) {
          setState(() {
            _newPatient.consentGiven = newValue;
          });
        },
        validator: (value) {
          if (value == null) { return 'Please answer this question.'; }
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
      child: DropdownButtonFormField<NoConsentReason>(
        value: _newPatient.noConsentReason,
        onChanged: (NoConsentReason newValue) {
          setState(() {
            _newPatient.noConsentReason = newValue;
          });
        },
        validator: (value) {
          if (value == null) { return 'Please answer this question.'; }
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
      child: TextFormField(
        controller: _noConsentReasonOtherCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please specify the reasons';
          }
        },
      ),
    );
  }

  Widget _viralLoadBaselineAvailableQuestion() {
    return _makeQuestion('Is there any viral load within the last 12 months available (laboratory report, bukana, patient file)?',
      child: DropdownButtonFormField<bool>(
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
          if (value == null) { return 'Please answer this question.'; }
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
    return _makeQuestion('Date of most recent viral load (put the date when blood was taken)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlatButton(
            padding: EdgeInsets.all(0.0),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                _viralLoadBaseline.dateOfBloodDraw == null ? 'Select Date' : formatDateConsistent(_viralLoadBaseline.dateOfBloodDraw),
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            onPressed: () async {
              final now = DateTime.now();
              DateTime date = await _showDatePicker(context, 'Viral Load Baseline Date', initialDate: _viralLoadBaseline.dateOfBloodDraw ?? DateTime(now.year, now.month, now.day));
              if (date != null) {
                setState(() {
                  _viralLoadBaseline.dateOfBloodDraw = date;
                });
              }
            },
          ),
          Divider(color: Colors.black87, height: 1.0,),
          _viralLoadBaselineDateValid ? Container() : Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              'Please select a date',
              style: TextStyle(
                color: Colors.red,
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
    return _makeQuestion('Was the viral load baseline result lower than detectable limit (<20 copies/mL)?',
      child: DropdownButtonFormField<bool>(
        value: _viralLoadBaseline.isLowerThanDetectable,
        onChanged: (bool newValue) {
          setState(() {
            _viralLoadBaseline.isLowerThanDetectable = newValue;
          });
        },
        validator: (value) {
          if (value == null) { return 'Please answer this question.'; }
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
    if (_newPatient.isVLBaselineAvailable == null || !_newPatient.isVLBaselineAvailable || _viralLoadBaseline.isLowerThanDetectable == null || _viralLoadBaseline.isLowerThanDetectable) {
      return Container();
    }
    return _makeQuestion('What was the result of the viral load baseline (in c/mL)',
      child: TextFormField(
        inputFormatters: [
          WhitelistingTextInputFormatter(RegExp('[0-9]')),
//          LengthLimitingTextInputFormatter(5),
        ],
        keyboardType: TextInputType.numberWithOptions(),
        controller: _viralLoadBaselineResultCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter the viral load baseline result';
          }
        },
      ),
    );
  }

  Widget _viralLoadBaselineLabNumberQuestion() {
    if (_newPatient.isVLBaselineAvailable == null || !_newPatient.isVLBaselineAvailable) {
      return Container();
    }
    return _makeQuestion('Lab number of the viral load baseline',
      child: TextFormField(
        controller: _viralLoadBaselineLabNumberCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter the lab number of the viral load result';
          }
        },
      ),
    );
  }

  // ----------
  // OTHER
  // ----------

  Widget _eligibilityDisclaimer() {
    if (_newPatient.yearOfBirth == null || _eligible) {
      return Container();
    }
    return
      Padding(
        padding: EdgeInsets.all(15.0),
        child:
        Text('This patient is not eligible for the study. Only patients born '
            'between $minYearForEligibility and $maxYearForEligibility are '
            'eligible.\nPlease, save the patient anyway for study evaluation '
            'reasons. The patient will not appear in the PEBRApp though.',
          textAlign: TextAlign.center,
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

  _onSubmitForm() async {
    if (_formKey.currentState.validate() & _validateViralLoadBaselineDate()) {

      _newPatient.enrolmentDate = DateTime.now().toUtc();
      _newPatient.isEligible = _eligible;
      _newPatient.artNumber = _artNumberCtr.text;
      _newPatient.stickerNumber = _stickerNumberCtr.text;
      _newPatient.village = _villageCtr.text;
      _newPatient.phoneNumber = _phoneNumberCtr.text;
      _newPatient.noConsentReasonOther = _noConsentReasonOtherCtr.text;
      _newPatient.village = _villageCtr.text;
      _newPatient.village = _villageCtr.text;
      _newPatient.village = _villageCtr.text;
      _newPatient.checkLogicAndResetUnusedFields();

      if (_newPatient.isEligible && _newPatient.consentGiven && _newPatient.isVLBaselineAvailable != null && _newPatient.isVLBaselineAvailable) {
        _viralLoadBaseline.patientART = _artNumberCtr.text;
        _viralLoadBaseline.viralLoad = _viralLoadBaseline.isLowerThanDetectable ? null : int.parse(_viralLoadBaselineResultCtr.text);
        _viralLoadBaseline.labNumber = _viralLoadBaselineLabNumberCtr.text;
        _viralLoadBaseline.checkLogicAndResetUnusedFields();
        await PatientBloc.instance.sinkViralLoadData(_viralLoadBaseline);
        _newPatient.viralLoadBaselineManual = _viralLoadBaseline;
      }

      await PatientBloc.instance.sinkPatientData(_newPatient);
      Navigator.of(context).popUntil((Route<dynamic> route) {
        return (route.settings.name == '/patient' || route.settings.name == '/');
      });
      final String finishNotification = 'New patient created successfully';
      showFlushBar(context, finishNotification);
    }
  }

  _openKoBoCollect() async {
    const appUrl = 'android-app://org.koboc.collect.android';
    const marketUrl = 'market://details?id=org.koboc.collect.android';
    if (await canLaunch(appUrl)) {
      await launch(appUrl);
    } else if (await canLaunch(marketUrl)) {
      await launch(marketUrl);
    } else {
      showFlushBar(context, "Could not find KoBoCollect app. Make sure KoBoCollect is installed.");
    }
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

  Widget _makeQuestion(String question, {@required Widget child}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: _questionsFlex,
          child: Text(question),
        ),
        Expanded(
          flex: _answersFlex,
          child: child,
        ),
      ],
    );
  }

  bool _artNumberExists(artNumber) {
    return _artNumbersInDB.contains(artNumber);
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

  Future<DateTime> _showDatePicker(BuildContext context, String title, {DateTime initialDate}) async {
    DateTime now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 1, now.month, now.day),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget widget) {
        return Center(
          child: Card(
            color: Color.fromARGB(255, 224, 224, 224),
            child: Container(
              width: 400,
              height: 620,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    widget,
                  ]
              ),
            ),
          ),
        );
      });
  }

}
