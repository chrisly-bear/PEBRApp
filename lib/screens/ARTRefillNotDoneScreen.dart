import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
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
  bool _deactivatePatient;
  TextEditingController _otherClinicLesothoCtr = TextEditingController();
  TextEditingController _otherClinicSouthAfricaCtr = TextEditingController();
  TextEditingController _notTakingARTAnymoreCtr = TextEditingController();

  // constructor
  _ARTRefillNotDoneFormState(Patient patient) {
    _patient = patient;
    _artRefill = ARTRefill(patient.artNumber, RefillType.NOT_DONE);
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
            _otherClinicLesothoQuestion(),
            _otherClinicSouthAfricaQuestion(),
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
                  ARTRefillNotDoneReason.values.map<DropdownMenuItem<ARTRefillNotDoneReason>>((ARTRefillNotDoneReason value) {
                String description;
                switch (value) {
                  case ARTRefillNotDoneReason.PATIENT_DIED:
                    description = 'Patient Died';
                    break;
                  case ARTRefillNotDoneReason.PATIENT_HOSPITALIZED:
                    description = 'Patient is Hospitalized';
                    break;
                  case ARTRefillNotDoneReason.ART_FROM_OTHER_CLINIC_LESOTHO:
                    description = 'Getting ART from another clinic in Lesotho';
                    break;
                  case ARTRefillNotDoneReason.ART_FROM_OTHER_CLINIC_SA:
                    description = 'Getting ART from another clinic in South Africa';
                    break;
                  case ARTRefillNotDoneReason.NOT_TAKING_ART_ANYMORE:
                    description = 'Not taking ART anymore';
                    break;
                  case ARTRefillNotDoneReason.STOCK_OUT_OR_FAILED_DELIVERY:
                    description = 'ART stock-out, or VHW or PE failed to deliver ART to patient';
                    break;
                }
                return DropdownMenuItem<ARTRefillNotDoneReason>(
                  value: value,
                  child: Text(description),
                );
              }).toList(),
            ))
      ],
    );
  }

  Widget _otherClinicLesothoQuestion() {
    if (_artRefill.notDoneReason != ARTRefillNotDoneReason.ART_FROM_OTHER_CLINIC_LESOTHO) {
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
            controller: _otherClinicLesothoCtr,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter the name of the clinic';
              }
            },
          ),)
      ],
    );
  }

  Widget _otherClinicSouthAfricaQuestion() {
    if (_artRefill.notDoneReason != ARTRefillNotDoneReason.ART_FROM_OTHER_CLINIC_SA) {
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
            controller: _otherClinicSouthAfricaCtr,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter the name of the clinic';
              }
            },
          ),)
      ],
    );
  }

  Widget _notTakingARTAnymoreQuestion() {
    if (_artRefill.notDoneReason != ARTRefillNotDoneReason.NOT_TAKING_ART_ANYMORE) {
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

  _onSubmitForm() async {
    if (_formKey.currentState.validate()) {
      _artRefill.otherClinicLesotho = _otherClinicLesothoCtr.text;
      _artRefill.otherClinicSouthAfrica = _otherClinicSouthAfricaCtr.text;
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

  patientActivatedWillChange(Patient patient, bool newStatus) {
    return patient.isActivated != newStatus;
  }

}
