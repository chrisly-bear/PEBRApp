import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/database/beans/ARTRefillNotDoneReason.dart';
import 'package:pebrapp/database/beans/RefillType.dart';
import 'package:pebrapp/database/models/ARTRefill.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/Utils.dart';

class ARTRefillNotDoneScreen extends StatelessWidget {
  final Patient _patient;

  ARTRefillNotDoneScreen(this._patient);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 224, 224, 224),
        appBar: AppBar(
          title: Text('ART Refill Not Done: ${this._patient.artNumber}'),
        ),
        body: Center(child: ARTRefillNotDoneForm(_patient)));
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

  Patient _patient;
  ARTRefill _artRefill;
  bool _dateOfDeathValid = true;
  bool _transferDateValid = true;
  bool _deactivatePatient;
  TextEditingController _causeOfDeathCtr = TextEditingController();
  TextEditingController _hospitalizedClinicCtr = TextEditingController();
  TextEditingController _otherClinicCtr = TextEditingController();
  TextEditingController _notTakingARTAnymoreCtr = TextEditingController();

  // constructor
  _ARTRefillNotDoneFormState(Patient patient) {
    _patient = patient;
    _artRefill = ARTRefill(patient.artNumber, RefillType.NOT_DONE());
    _deactivatePatient = !patient.isActivated;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: ListView(
      children: <Widget>[
        Container(height: 50), // padding at bottom
        _buildQuestionCard(),
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
            _deactivatePatientQuestion(),
          ],
        ),
      ),
    );
  }

  Row _whyRefillNotDoneQuestion() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child: Text(
                'Why was this ART Refill not done?')),
        Expanded(
            flex: _answersFlex,
            child: DropdownButtonFormField<ARTRefillNotDoneReason>(
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
            ))
      ],
    );
  }

  Widget _dateOfDeathQuestion() {
    if (_artRefill.notDoneReason != ARTRefillNotDoneReason.PATIENT_DIED()) {
      return Container();
    }
    return _makeQuestion('Date of Death',
      child: Column(
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
            Divider(color: Colors.black87, height: 1.0,),
            _dateOfDeathValid ? Container() : Padding(
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

  Widget _causeOfDeathQuestion() {
    if (_artRefill.notDoneReason != ARTRefillNotDoneReason.PATIENT_DIED()) {
      return Container();
    }
    return _makeQuestion('Cause of Death',
      child: TextFormField(
        controller: _causeOfDeathCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter the cause of death';
          }
        },
      ),
    );
  }
  
  Widget _hospitalizedClinicQuestion() {
    if (_artRefill.notDoneReason != ARTRefillNotDoneReason.PATIENT_HOSPITALIZED()) {
      return Container();
    }
    return _makeQuestion('Where is the patient hospitalized?',
      child: TextFormField(
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child:
            Text('Clinic Name:')),
        Expanded(
          flex: _answersFlex,
          child: TextFormField(
            controller: _otherClinicCtr,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter the name of the clinic';
              }
            },
          ),)
      ],
    );
  }

  Widget _transferDateQuestion() {
    if (_artRefill.notDoneReason != ARTRefillNotDoneReason.ART_FROM_OTHER_CLINIC_LESOTHO()
        && _artRefill.notDoneReason != ARTRefillNotDoneReason.ART_FROM_OTHER_CLINIC_SA()) {
      return Container();
    }
    return _makeQuestion('Date of Transfer',
      child: Column(
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
            Divider(color: Colors.black87, height: 1.0,),
            _transferDateValid ? Container() : Padding(
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

  Widget _notTakingARTAnymoreQuestion() {
    if (_artRefill.notDoneReason != ARTRefillNotDoneReason.NOT_TAKING_ART_ANYMORE()) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child:
            Text('Reason:')),
        Expanded(
          flex: _answersFlex,
          child: TextFormField(
            controller: _notTakingARTAnymoreCtr,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please give a reason';
              }
            },
          ),)
      ],
    );
  }

  Widget _deactivatePatientQuestion() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            flex: _questionsFlex,
            child:
            Text('Deactivate Patient?')),
        Expanded(
          flex: _answersFlex,
          child: CheckboxListTile(
                  value: _deactivatePatient,
                  onChanged: (bool newState) {
                    setState(() { _deactivatePatient = newState; });
                  },
                ),
          ),
      ],
    );
  }

  bool _validateDateOfDeath() {
    // if the date of death is not specified when it should be show
    // the error message under the date field and return false.
    if (_artRefill.notDoneReason == ARTRefillNotDoneReason.PATIENT_DIED() && _artRefill.dateOfDeath == null) {
      setState(() {
        _dateOfDeathValid = false;
      });
      return false;
    }
    setState(() {
      _dateOfDeathValid = true;
    });
    return true;
  }

  bool _validateTransferDate() {
    // if the date of transfer is not specified when it should be show
    // the error message under the date field and return false.
    if ((_artRefill.notDoneReason == ARTRefillNotDoneReason.ART_FROM_OTHER_CLINIC_LESOTHO()
        || _artRefill.notDoneReason == ARTRefillNotDoneReason.ART_FROM_OTHER_CLINIC_SA())
        &&_artRefill.transferDate == null) {
      setState(() {
        _transferDateValid = false;
      });
      return false;
    }
    setState(() {
      _transferDateValid = true;
    });
    return true;
  }

  _onSubmitForm() async {
    if (_formKey.currentState.validate() & _validateDateOfDeath() & _validateTransferDate()) {
      _artRefill.causeOfDeath = _causeOfDeathCtr.text;
      _artRefill.hospitalizedClinic = _hospitalizedClinicCtr.text;
      _artRefill.otherClinic = _otherClinicCtr.text;
      _artRefill.notTakingARTReason = _notTakingARTAnymoreCtr.text;
      print('NEW ART REFILL (_id will be given by SQLite database):\n$_artRefill');
      await PatientBloc.instance.sinkARTRefillData(_artRefill);
      if (patientActivatedWillChange(_patient, !_deactivatePatient)) {
        print('patient will change activation status, sinking patient data...');
        print('current: ${_patient.isActivated}, new: ${!_deactivatePatient}');
        _patient.isActivated = !_deactivatePatient;
        PatientBloc.instance.sinkPatientData(_patient);
      }
      // we will also have to sink a PatientData event in case the patient's isActivated state changes
      Navigator.of(context).popUntil((Route<dynamic> route) {
        return route.settings.name == '/patient';
      });
      showFlushBar(context, 'ART Refill saved');
    } else {
      showFlushBar(context, "Errors exist in the form. Please check the form.");
    }
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

  Future<DateTime> _showDatePicker(BuildContext context, String title, {DateTime initialDate}) async {
    DateTime now = DateTime.now();
    return showDatePicker(
        context: context,
        initialDate: initialDate ?? now,
        firstDate: DateTime.fromMillisecondsSinceEpoch(0),
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

  patientActivatedWillChange(Patient patient, bool newStatus) {
    return patient.isActivated != newStatus;
  }

}
