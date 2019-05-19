import 'package:flutter/material.dart';
import 'package:pebrapp/components/SizedButton.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/Gender.dart';
import 'package:pebrapp/database/beans/PhoneAvailability.dart';
import 'package:pebrapp/database/beans/SexualOrientation.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pebrapp/database/beans/NoConsentReason.dart';

class NewOrEditPatientScreen extends StatelessWidget {

  final Patient existingPatient;

  NewOrEditPatientScreen({this.existingPatient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 224, 224, 224),
        appBar: AppBar(
          title: existingPatient == null ?
          const Text('New Patient', key: Key('newOrEditPatientTitle'),) :
          Text('Edit Patient: ${existingPatient.artNumber}', key: Key('newOrEditPatientTitle')),
        ),
        body: Center(
          child: _NewOrEditPatientScreenBody(existingPatient),
        ));
  }
}

class _NewOrEditPatientScreenBody extends StatelessWidget {

  final Patient _existingPatient;

  _NewOrEditPatientScreenBody(this._existingPatient);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(child: _NewOrEditPatientForm(_existingPatient)),
    ]);
  }
}

// https://flutter.dev/docs/cookbook/forms/validation
class _NewOrEditPatientForm extends StatefulWidget {

  final Patient _existingPatient;

  _NewOrEditPatientForm(this._existingPatient);

  @override
  _NewOrEditPatientFormState createState() {
    return _NewOrEditPatientFormState(_existingPatient);
  }
}

class _NewOrEditPatientFormState extends State<_NewOrEditPatientForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  final _formKey = GlobalKey<FormState>();

  final _questionsFlex = 1;
  final _answersFlex = 1;

  static final currentYear = DateTime.now().year;

  static final int birthYearOptionsStart = 1980;
  static final int birthYearOptionsEnd = currentYear;
  List<int> birthYearOptions = List<int>.generate(birthYearOptionsEnd - birthYearOptionsStart + 1, (i) => birthYearOptionsStart + i);

  static final int minAgeForEligibility = 16;
  static final int maxAgeForEligibility = 30;
  static final int minYearForEligibility = currentYear - maxAgeForEligibility;
  static final int maxYearForEligibility = currentYear - minAgeForEligibility;
  bool get _eligible => _birthYear != null && _birthYear >= minYearForEligibility && _birthYear <= maxYearForEligibility;

  final Patient _existingPatient;
  bool _editModeOn;
  bool _patientIsActivated = false;
  int _birthYear;
  Gender _gender;
  SexualOrientation _sexualOrientation;
  PhoneAvailability _phoneAvailable;
  bool _consentGiven;
  NoConsentReason _noConsentReason;
  bool _baselineViralLoadAvailable;
  TextEditingController _artNumberCtr = TextEditingController();
  TextEditingController _stickerNumberCtr = TextEditingController();
  TextEditingController _villageCtr = TextEditingController();
  TextEditingController _districtCtr = TextEditingController();
  TextEditingController _phoneNumberCtr = TextEditingController();
  TextEditingController _noConsentReasonOtherCtr = TextEditingController();

  _NewOrEditPatientFormState(this._existingPatient) {
    _editModeOn = _existingPatient != null;
    _patientIsActivated = _existingPatient?.isActivated ?? false;
    _artNumberCtr.text = _editModeOn ? _existingPatient?.artNumber : null;
    _villageCtr.text = _editModeOn ? _existingPatient?.village : null;
    _districtCtr.text = _editModeOn ? _existingPatient?.district : null;
    _phoneNumberCtr.text = _editModeOn ? _existingPatient?.phoneNumber : null;
  }

  List<String> _artNumbersInDB;
  bool get _isLoading { return _artNumbersInDB == null; }

  @override
  initState() {
    print('~~~ _NewOrEditPatientFormState.initState ~~~');
    super.initState();
    DatabaseProvider().retrievePatientsART().then((artNumbers) {
      setState(() {
        _artNumbersInDB = artNumbers;
      });
    });
  }

  @override
  void didUpdateWidget(_NewOrEditPatientForm oldWidget) {
    print('~~~ _NewOrEditPatientFormState.didUpdateWidget ~~~');
    super.didUpdateWidget(oldWidget);
  }

  @override
  void reassemble() {
    print('~~~ _NewOrEditPatientFormState.reassemble ~~~');
    super.reassemble();
  }

  @override
  void didChangeDependencies() {
    print('~~~ _NewOrEditPatientFormState.didChangeDependencies ~~~');
    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    print('~~~ _NewOrEditPatientFormState.deactivate ~~~');
    super.deactivate();
  }

  @override
  void dispose() {
    print('~~~ _NewOrEditPatientFormState.dispose ~~~');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('~~~ _NewOrEditPatientFormState.build ~~~');
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
              SizedButton(
                'Save',
                onPressed: _isLoading ? null : _onSubmitForm,
              ),
            ]),
            SizedBox(height: 16.0),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedButton(
                'Open KoBoCollect',
                onPressed: _openKoBoCollect,
              ),
            ]),
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
    if (_editModeOn || !_eligible) {
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
    if (!_eligible || _consentGiven == null || !_consentGiven) {
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
    if (_editModeOn) {
      return Container();
    }
    return _makeQuestion('ART Number',
      child: TextFormField(
        enabled: !_editModeOn,
        controller: _artNumberCtr,
        validator: (value) {
          if (_editModeOn) {
            return null;
          }
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
    if (_editModeOn) {
      return Container();
    }
    return _makeQuestion('Sticker Number',
      child: TextFormField(
        enabled: !_editModeOn,
        controller: _stickerNumberCtr,
        validator: (value) {
          if (_editModeOn) {
            return null;
          }
          if (value.isEmpty) {
            return 'Please enter the sticker number';
          }
        },
      ),
    );
  }

  Widget _yearOfBirthQuestion() {
    if (_editModeOn) {
      return Container();
    }
    return _makeQuestion('Year of Birth',
        child: DropdownButtonFormField<int>(
          value: _birthYear,
          onChanged: (int newValue) {
            setState(() {
              _birthYear = newValue;
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
    // always show field in edit mode -> !editModeOn
    // only show field if eligible -> !_eligible
    if (!_editModeOn && (!_eligible || _consentGiven == null || !_consentGiven)) {
      return Container();
    }
    return _makeQuestion(
      'Gender',
      child: DropdownButtonFormField<Gender>(
        value: _gender,
        onChanged: (Gender newValue) {
          setState(() {
            _gender = newValue;
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
    // always show field in edit mode -> !editModeOn
    // only show field if eligible -> !_eligible
    if (!_editModeOn && (!_eligible || _consentGiven == null || !_consentGiven)) {
      return Container();
    }
    return _makeQuestion(
      'Sexual Orientation',
      child: DropdownButtonFormField<SexualOrientation>(
        value: _sexualOrientation,
        onChanged: (SexualOrientation newValue) {
          setState(() {
            _sexualOrientation = newValue;
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
    // always show field in edit mode -> !editModeOn
    // only show field if eligible -> !_eligible
    if (!_editModeOn && (!_eligible || _consentGiven == null || !_consentGiven)) {
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
    // always show field in edit mode -> !editModeOn
    // only show field if eligible -> !_eligible
    if (!_editModeOn && (!_eligible || _consentGiven == null || !_consentGiven)) {
      return Container();
    }
    return _makeQuestion('Do you have regular access to a phone (with Lesotho number) where you can receive confidential information?',
      child: DropdownButtonFormField<PhoneAvailability>(
        value: _phoneAvailable,
        onChanged: (PhoneAvailability newValue) {
          setState(() {
            _phoneAvailable = newValue;
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
    if (!_editModeOn && (!_eligible || _consentGiven == null || !_consentGiven || _phoneAvailable == null || _phoneAvailable != PhoneAvailability.YES())) {
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
    if (_editModeOn) {
      return Container();
    }
    return _makeQuestion('Has the patient signed the consent form?',
      child: DropdownButtonFormField<bool>(
        value: _consentGiven,
        onChanged: (bool newValue) {
          setState(() {
            _consentGiven = newValue;
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
    if (_editModeOn || _consentGiven == null || _consentGiven) {
      return Container();
    }
    return _makeQuestion('Reason for refusal',
      child: DropdownButtonFormField<NoConsentReason>(
        value: _noConsentReason,
        onChanged: (NoConsentReason newValue) {
          setState(() {
            _noConsentReason = newValue;
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
    if (_editModeOn || _consentGiven == null || _consentGiven || _noConsentReason == null || _noConsentReason != NoConsentReason.OTHER()) {
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
        value: _baselineViralLoadAvailable,
        onChanged: (bool newValue) {
          if (!newValue) {
            _showDialog('No Viral Load Available', 'Send the participant to the nurse for blood draw today!');
          }
          setState(() {
            _baselineViralLoadAvailable = newValue;
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

  // ----------
  // OTHER
  // ----------

  Widget _eligibilityDisclaimer() {
    if (_birthYear == null || _eligible) {
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

  _onSubmitForm() async {
    Patient newPatient;
    // Validate will return true if the form is valid, or false if the form is invalid.
    if (_formKey.currentState.validate()) {
      if (_editModeOn) { // editing an existing patient
        newPatient = _existingPatient;
        newPatient.village = _villageCtr.text;
        newPatient.district = _districtCtr.text;
        newPatient.phoneNumber = _phoneNumberCtr.text;
        newPatient.isActivated = _patientIsActivated;
        print('EDITED PATIENT:\n$newPatient');
      } else { // creating a new patient
        newPatient = Patient(_artNumberCtr.text, _districtCtr.text, _phoneNumberCtr.text, _villageCtr.text, _patientIsActivated);
        print('NEW PATIENT:\n$newPatient');
      }
      await PatientBloc.instance.sinkPatientData(newPatient);
      Navigator.of(context).popUntil((Route<dynamic> route) {
        return (route.settings.name == '/patient' || route.settings.name == '/');
      });
      final String finishNotification = _editModeOn
          ? 'Changes saved'
          : 'New patient created successfully';
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

}
