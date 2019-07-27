import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/Gender.dart';
import 'package:pebrapp/database/beans/PhoneAvailability.dart';
import 'package:pebrapp/database/beans/SexualOrientation.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/utils/InputFormatters.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:pebrapp/utils/VisibleImpactUtils.dart';

// TODO: implement this screen. Think about what fields have to be changeable for a patient.
class EditPatientScreen extends StatelessWidget {

  final Patient _existingPatient;

  EditPatientScreen(this._existingPatient);

  @override
  Widget build(BuildContext context) {
    return PopupScreen(
      title: 'Edit Patient',
      subtitle: _existingPatient.artNumber,
      child: _EditPatientForm(_existingPatient),
    );
  }
}

// https://flutter.dev/docs/cookbook/forms/validation
class _EditPatientForm extends StatefulWidget {

  final Patient _existingPatient;

  _EditPatientForm(this._existingPatient);

  @override
  _EditPatientFormState createState() {
    return _EditPatientFormState(_existingPatient);
  }
}

class _EditPatientFormState extends State<_EditPatientForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  final _formKey = GlobalKey<FormState>();

  final _questionsFlex = 1;
  final _answersFlex = 1;
  double _screenWidth = double.infinity;
  String _existingPhoneNumber;

  final Patient _existingPatient;
  TextEditingController _villageCtr = TextEditingController();
  TextEditingController _phoneNumberCtr = TextEditingController();

  _EditPatientFormState(this._existingPatient) {
    _villageCtr.text = _existingPatient.village;
    _existingPhoneNumber = _existingPatient.phoneNumber;
    if (_existingPhoneNumber != null) {
      _phoneNumberCtr.text = _existingPhoneNumber.substring(5);
    }
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    return Form(
      key: _formKey,
      child: Column(
          children: [
            _personalInformationCard(),
            SizedBox(height: 16.0),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              PEBRAButtonRaised(
                'Save',
                onPressed: _isLoading ? null : _onSubmitForm,
              ),
            ]),
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

  // ----------
  // QUESTIONS
  // ----------

  Widget _genderQuestion() {
    return _makeQuestion('Gender',
      answer: DropdownButtonFormField<Gender>(
        value: _existingPatient.gender,
        onChanged: (Gender newValue) {
          setState(() {
            _existingPatient.gender = newValue;
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
    return _makeQuestion('Sexual Orientation',
      answer: DropdownButtonFormField<SexualOrientation>(
        value: _existingPatient.sexualOrientation,
        onChanged: (SexualOrientation newValue) {
          setState(() {
            _existingPatient.sexualOrientation = newValue;
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
    return _makeQuestion('Village',
      answer: TextFormField(
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
    return _makeQuestion('Do you have regular access to a phone (with Lesotho number) where you can receive confidential information?',
      answer: DropdownButtonFormField<PhoneAvailability>(
        value: _existingPatient.phoneAvailability,
        onChanged: (PhoneAvailability newValue) {
          setState(() {
            _existingPatient.phoneAvailability = newValue;
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
    if (_existingPatient.phoneAvailability == null || _existingPatient.phoneAvailability != PhoneAvailability.YES()) {
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

  // ----------
  // OTHER
  // ----------

  _onSubmitForm() async {
    // Validate will return true if the form is valid, or false if the form is invalid.
    if (_formKey.currentState.validate()) {
      // TODO: check that all fields are updated
      if (_existingPatient.phoneAvailability == PhoneAvailability.YES()) {
        final String newPatientPhoneNumber = '+266-${_phoneNumberCtr.text}';
        if (_existingPhoneNumber != newPatientPhoneNumber) {
          _existingPatient.phoneNumber = newPatientPhoneNumber;
          uploadPatientPhoneNumber(_existingPatient, reUploadNotifications: true);
        }
      } else {
        final String newPatientPhoneNumber = null;
        if (_existingPhoneNumber != newPatientPhoneNumber) {
          _existingPatient.phoneNumber = newPatientPhoneNumber;
          uploadPatientPhoneNumber(_existingPatient, reUploadNotifications: true);
        }
      }
      _existingPatient.village = _villageCtr.text;
      await DatabaseProvider().insertPatient(_existingPatient);
      Navigator.of(context).popUntil((Route<dynamic> route) {
        return (route.settings.name == '/patient' || route.settings.name == '/');
      });
      final String finishNotification = 'Changes saved';
      showFlushbar(finishNotification);
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
        Expanded(
          flex: _answersFlex,
          child: answer,
        ),
      ],
    );
  }

}
