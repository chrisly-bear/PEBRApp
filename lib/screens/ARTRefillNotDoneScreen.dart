import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/ARTRefillNotDoneReason.dart';
import 'package:pebrapp/database/beans/RefillType.dart';
import 'package:pebrapp/database/models/ARTRefill.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/Utils.dart';

class ARTRefillNotDoneScreen extends StatelessWidget {
  final Patient _patient;

  ARTRefillNotDoneScreen(this._patient);

  @override
  Widget build(BuildContext context) {
    return PopupScreen(
      title: 'ART Refill Not Done',
      subtitle: _patient.artNumber,
      child: ARTRefillNotDoneForm(_patient),
    );
  }
}

class ARTRefillNotDoneForm extends StatefulWidget {
  final Patient _patient;

  ARTRefillNotDoneForm(this._patient);

  @override
  createState() => _ARTRefillNotDoneFormState(_patient);
}

class _ARTRefillNotDoneFormState extends State<ARTRefillNotDoneForm> {
  // fields
  final _formKey = GlobalKey<FormState>();
  final int _questionsFlex = 1;
  final int _answersFlex = 1;
  double _screenWidth = double.infinity;

  Patient _patient;
  ARTRefill _artRefill;
  TextEditingController _causeOfDeathCtr = TextEditingController();
  TextEditingController _hospitalizedClinicCtr = TextEditingController();
  TextEditingController _otherClinicCtr = TextEditingController();
  TextEditingController _notTakingARTAnymoreCtr = TextEditingController();

  // constructor
  _ARTRefillNotDoneFormState(Patient patient) {
    _patient = patient;
    _artRefill = ARTRefill(patient.artNumber, RefillType.NOT_DONE());
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    const double _spacing = 20.0;
    return Form(
        key: _formKey,
        child: Column(
      children: <Widget>[
        SizedBox(height: _spacing),
        _buildQuestionCard(),
        SizedBox(height: _spacing),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            _artRefill.notDoneReason == null || _artRefill.notDoneReason == ARTRefillNotDoneReason.STOCK_OUT_OR_FAILED_DELIVERY()
              ? ''
              : 'Patient will be deactivated and appear greyed out in the main screen.',
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: _spacing),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          PEBRAButtonRaised(
            'Save',
            onPressed: _onSubmitForm,
          )
        ]),
        SizedBox(height: _spacing),
      ],
    )
    );
  }

  _buildQuestionCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            _whyRefillNotDoneQuestion(),
            _dateOfDeathQuestion(),
            _causeOfDeathQuestion(),
            _hospitalizedClinicQuestion(),
            _otherClinicQuestion(),
            _transferDateQuestion(),
            _notTakingARTAnymoreQuestion(),
          ],
        ),
      ),
    );
  }

  Widget _whyRefillNotDoneQuestion() {
    return _makeQuestion('Why was this ART Refill not done?',
      answer: DropdownButtonFormField<ARTRefillNotDoneReason>(
        value: _artRefill.notDoneReason,
        onChanged: (ARTRefillNotDoneReason newValue) {
          setState(() {
            _artRefill.notDoneReason = newValue;
          });
        },
        validator: (value) {
          if (value == null) { return 'Please answer this question'; }
        },
        items:
        ARTRefillNotDoneReason.allValues.map<DropdownMenuItem<ARTRefillNotDoneReason>>((ARTRefillNotDoneReason value) {
          return DropdownMenuItem<ARTRefillNotDoneReason>(
            value: value,
            child: Text(value.description),
          );
        }).toList(),
      ),
    );
  }

  Widget _dateOfDeathQuestion() {
    if (_artRefill.notDoneReason != ARTRefillNotDoneReason.PATIENT_DIED()) {
      return Container();
    }
    return _makeQuestion('Date of Death',
      answer: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlatButton(
              padding: EdgeInsets.all(0.0),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  _artRefill.dateOfDeath == null ? 'Select Date' : formatDateConsistent(_artRefill.dateOfDeath),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              onPressed: () async {
                final now = DateTime.now();
                DateTime date = await _showDatePicker(context, 'Date of Death', initialDate: _artRefill.dateOfDeath ?? DateTime(now.year, now.month, now.day));
                if (date != null) {
                  setState(() {
                    _artRefill.dateOfDeath = date;
                  });
                }
              },
            ),
            Divider(color: CUSTOM_FORM_FIELD_UNDERLINE, height: 1.0,),
          ]
      ),
    );
  }

  Widget _causeOfDeathQuestion() {
    if (_artRefill.notDoneReason != ARTRefillNotDoneReason.PATIENT_DIED()) {
      return Container();
    }
    return _makeQuestion('Cause of Death',
      answer: TextFormField(
        controller: _causeOfDeathCtr,
      ),
    );
  }
  
  Widget _hospitalizedClinicQuestion() {
    if (_artRefill.notDoneReason != ARTRefillNotDoneReason.PATIENT_HOSPITALIZED()) {
      return Container();
    }
    return _makeQuestion('Where is the patient hospitalized?',
      answer: TextFormField(
        controller: _hospitalizedClinicCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter the name of the clinic';
          }
        },
      ),
    );
  }
  
  Widget _otherClinicQuestion() {
    if (_artRefill.notDoneReason != ARTRefillNotDoneReason.ART_FROM_OTHER_CLINIC_LESOTHO() && _artRefill.notDoneReason != ARTRefillNotDoneReason.ART_FROM_OTHER_CLINIC_SA()) {
      return Container();
    }
    return _makeQuestion('Clinic Name:',
      answer: TextFormField(
        controller: _otherClinicCtr,
      ),
    );
  }

  Widget _transferDateQuestion() {
    if (_artRefill.notDoneReason != ARTRefillNotDoneReason.ART_FROM_OTHER_CLINIC_LESOTHO()
        && _artRefill.notDoneReason != ARTRefillNotDoneReason.ART_FROM_OTHER_CLINIC_SA()) {
      return Container();
    }
    return _makeQuestion('Date of Transfer',
      answer: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlatButton(
              padding: EdgeInsets.all(0.0),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  _artRefill.transferDate == null ? 'Select Date' : formatDateConsistent(_artRefill.transferDate),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              onPressed: () async {
                final now = DateTime.now();
                DateTime date = await _showDatePicker(context, 'Date of Transfer', initialDate: _artRefill.transferDate ?? DateTime(now.year, now.month, now.day));
                if (date != null) {
                  setState(() {
                    _artRefill.transferDate = date;
                  });
                }
              },
            ),
            Divider(color: CUSTOM_FORM_FIELD_UNDERLINE, height: 1.0,),
          ]
      ),
    );
  }

  Widget _notTakingARTAnymoreQuestion() {
    if (_artRefill.notDoneReason != ARTRefillNotDoneReason.NOT_TAKING_ART_ANYMORE()) {
      return Container();
    }
    return _makeQuestion('Reason:',
      answer: TextFormField(
        controller: _notTakingARTAnymoreCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please give a reason';
          }
        },
      ),
    );
  }

  _onSubmitForm() async {
    if (_formKey.currentState.validate()) {
      _artRefill.causeOfDeath = _causeOfDeathCtr.text;
      _artRefill.hospitalizedClinic = _hospitalizedClinicCtr.text;
      _artRefill.otherClinic = _otherClinicCtr.text;
      _artRefill.notTakingARTReason = _notTakingARTAnymoreCtr.text;
      print('NEW ART REFILL (_id will be given by SQLite database):\n$_artRefill');
      await DatabaseProvider().insertARTRefill(_artRefill);
      _patient.latestARTRefill = _artRefill;
      if (_patient.isActivated && _artRefill.notDoneReason != ARTRefillNotDoneReason.STOCK_OUT_OR_FAILED_DELIVERY()) {
        _patient.isActivated = false;
        // the isActivated field changed on the patient object, we have to store
        // this change in the Patient table of the SQLite database
        await DatabaseProvider().insertPatient(_patient);
      }
      Navigator.of(context).popUntil((Route<dynamic> route) {
        return route.settings.name == '/patient';
      });
    }
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

  Future<DateTime> _showDatePicker(BuildContext context, String title, {DateTime initialDate}) async {
    DateTime now = DateTime.now();
    return showDatePicker(
        context: context,
        initialDate: initialDate ?? now,
        firstDate: DateTime.fromMillisecondsSinceEpoch(0),
        lastDate: DateTime.now(),
    );
  }

}
