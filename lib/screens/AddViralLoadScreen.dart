import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pebrapp/components/PEBRAButtonFlat.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/database/beans/ViralLoadSource.dart';
import 'package:pebrapp/database/models/ARTRefill.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/Utils.dart';

class AddViralLoadScreen extends StatelessWidget {
  final Patient _patient;

  AddViralLoadScreen(this._patient);

  _onPressCancel(BuildContext context) {
    Navigator.of(context).popUntil((Route<dynamic> route) {
      return route.settings.name == '/patient';
    });
  }

  @override
  Widget build(BuildContext context) {

    Widget _body = Center(
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 100.0, horizontal: 50.0),
        color: Color.fromARGB(255, 224, 224, 224),
        child: Column(
          children: <Widget>[
            SizedBox(height: 50),
            Text('Add Viral Load', style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),),
            AddViralLoadForm(_patient),
            Expanded(child: Container(),),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              PEBRAButtonFlat(
                'Cancel',
                onPressed: () { _onPressCancel(context); },
              )
            ]),
            SizedBox(height: 20),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.50),
      body: _body,
    );
  }
}

class AddViralLoadForm extends StatefulWidget {
  final Patient _patient;

  AddViralLoadForm(this._patient);

  @override
  createState() => _AddViralLoadFormState(_patient);
}

class _AddViralLoadFormState extends State<AddViralLoadForm> {
  // fields
  final _formKey = GlobalKey<FormState>();
  final int _questionsFlex = 1;
  final int _answersFlex = 1;

  ViralLoad _viralLoad;
  bool _viralLoadBaselineDateValid = true;
  TextEditingController _viralLoadResultCtr = TextEditingController();
  TextEditingController _viralLoadLabNumberCtr = TextEditingController();

  // constructor
  _AddViralLoadFormState(Patient patient) {
    _viralLoad = ViralLoad(patientART: patient.artNumber, source: ViralLoadSource.MANUAL_INPUT(), isBaseline: false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          SizedBox(height: 50),
          _buildQuestionCard(),
          SizedBox(height: 50),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            PEBRAButtonRaised(
              'Save',
              onPressed: () { _onSubmitForm(context); },
            )
          ]),
          SizedBox(height: 50), // padding at bottom
        ],
      ),
    );
  }

  _buildQuestionCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            _viralLoadBaselineDateQuestion(),
            _viralLoadBaselineLowerThanDetectableQuestion(),
            _viralLoadBaselineResultQuestion(),
            _viralLoadBaselineLabNumberQuestion(),
          ],
        ),
      ),
    );
  }

  Widget _viralLoadBaselineDateQuestion() {
    return _makeQuestion('Date of most recent viral load (put the date when blood was taken)',
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlatButton(
              padding: EdgeInsets.all(0.0),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  _viralLoad.dateOfBloodDraw == null ? 'Select Date' : formatDateConsistent(_viralLoad.dateOfBloodDraw),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              onPressed: () async {
                final now = DateTime.now();
                DateTime date = await _showDatePicker(context, 'Viral Load Baseline Date', initialDate: _viralLoad.dateOfBloodDraw ?? DateTime(now.year, now.month, now.day));
                if (date != null) {
                  setState(() {
                    _viralLoad.dateOfBloodDraw = date;
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
    return _makeQuestion('Was the viral load baseline result lower than detectable limit (<20 copies/mL)?',
      child: DropdownButtonFormField<bool>(
        value: _viralLoad.isLowerThanDetectable,
        onChanged: (bool newValue) {
          setState(() {
            _viralLoad.isLowerThanDetectable = newValue;
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
    if (_viralLoad.isLowerThanDetectable == null || _viralLoad.isLowerThanDetectable) {
      return Container();
    }
    return _makeQuestion('What was the result of the viral load baseline (in c/mL)',
      child: TextFormField(
        inputFormatters: [
          WhitelistingTextInputFormatter(RegExp('[0-9]')),
//          LengthLimitingTextInputFormatter(5),
        ],
        keyboardType: TextInputType.numberWithOptions(),
        controller: _viralLoadResultCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter the viral load baseline result';
          }
        },
      ),
    );
  }

  Widget _viralLoadBaselineLabNumberQuestion() {
    return _makeQuestion('Lab number of the viral load baseline',
      child: TextFormField(
        controller: _viralLoadLabNumberCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter the lab number of the viral load result';
          }
        },
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

  bool _validateViralLoadBaselineDate() {
    // if the viral load baseline date is not selected when it should be show
    // the error message under the viral load baseline date field and return
    // false.
    if (_viralLoad.dateOfBloodDraw == null) {
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

  _onSubmitForm(BuildContext context) async {
    if (_formKey.currentState.validate() & _validateViralLoadBaselineDate()) {
      
      _viralLoad.viralLoad = _viralLoad.isLowerThanDetectable ? null : int.parse(_viralLoadResultCtr.text);
      _viralLoad.labNumber = _viralLoadLabNumberCtr.text;
      _viralLoad.checkLogicAndResetUnusedFields();
      await PatientBloc.instance.sinkViralLoadData(_viralLoad);
      
      // we will also have to sink a PatientData event in case the patient's isActivated state changes
      Navigator.of(context).popUntil((Route<dynamic> route) {
        return route.settings.name == '/patient';
      });
    }
  }

}
