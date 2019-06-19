import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/database/beans/Gender.dart';
import 'package:pebrapp/database/beans/PhoneAvailability.dart';
import 'package:pebrapp/database/beans/SexualOrientation.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/Utils.dart';

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

  final Patient _existingPatient;
  TextEditingController _villageCtr = TextEditingController();
  TextEditingController _phoneNumberCtr = TextEditingController();

  _EditPatientFormState(this._existingPatient) {
    _villageCtr.text = _existingPatient?.village;
    _phoneNumberCtr.text = _existingPatient?.phoneNumber;
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
    return _makeQuestion(
      'Gender',
      child: DropdownButtonFormField<Gender>(
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
    return _makeQuestion(
      'Sexual Orientation',
      child: DropdownButtonFormField<SexualOrientation>(
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
    return _makeQuestion('Do you have regular access to a phone (with Lesotho number) where you can receive confidential information?',
      child: DropdownButtonFormField<PhoneAvailability>(
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
        child: TextFormField(
          decoration: InputDecoration(
            prefixText: '+266',
          ),
          controller: _phoneNumberCtr,
          onEditingComplete: () {
            _phoneNumberCtr.text = _formatPhoneNumber(_phoneNumberCtr.text);
          },
          keyboardType: TextInputType.phone,
          inputFormatters: [
            WhitelistingTextInputFormatter(RegExp('[0-9\\s\-]')),
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter a phone number';
            } else if (value.replaceAll(RegExp('[\\s\-]'), '').length != 8) {
              return 'Exactly 8 digits required';
            }
          },
        ),
    );
  }

  // ----------
  // OTHER
  // ----------

  /// Removes all non-number characters and inserts dashes to make number more
  /// readable. E.g. 12345678 becomes 12-345-678.
  ///
  /// Does not trim the number and only inserts two dashes. So if you pass it a
  /// long number string, the number will stay long. E.g. 1234567890123 becomes
  /// 12-345-67890123.
  ///
  /// If a [countryCode] is passed it will be prefixed with a dash. E.g.
  /// countryCode='266' returns +266-12-345-678.
  String _formatPhoneNumber(String phoneNumber, {String countryCode}) {
    String onlyNumbers = phoneNumber.replaceAll(RegExp('[^0-9]'), '');
    String formattedNumber;
    if (onlyNumbers.length >= 2) {
      formattedNumber = onlyNumbers.substring(0, 2) + '-' + onlyNumbers.substring(2, onlyNumbers.length);
    }
    if (onlyNumbers.length >= 5) {
      formattedNumber = onlyNumbers.substring(0, 2) + '-' + onlyNumbers.substring(2, 5) + '-' + onlyNumbers.substring(5, onlyNumbers.length);
    }
    if (countryCode != null && countryCode.isNotEmpty) {
      String countryCodeOnlyNumbers = countryCode.replaceAll(RegExp('[^0-9]'), '');
      formattedNumber = '+$countryCodeOnlyNumbers-$formattedNumber';
    }
    return formattedNumber;
  }

  _onSubmitForm() async {
    Patient newPatient;
    // Validate will return true if the form is valid, or false if the form is invalid.
    if (_formKey.currentState.validate()) {
      // TODO: check that all fields are updated
      await PatientBloc.instance.sinkPatientData(newPatient);
      Navigator.of(context).popUntil((Route<dynamic> route) {
        return (route.settings.name == '/patient' || route.settings.name == '/');
      });
      final String finishNotification = 'Changes saved';
      showFlushBar(context, finishNotification);
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

}
