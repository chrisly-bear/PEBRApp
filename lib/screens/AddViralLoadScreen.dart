import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pebrapp/components/PEBRAButtonFlat.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/ViralLoadSource.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/AppColors.dart';
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
    return PopupScreen(
      title: 'Add Viral Load',
      subtitle: _patient.artNumber,
      actions: <Widget>[IconButton(icon: Icon(Icons.close), onPressed: () { _onPressCancel(context); })],
      child: AddViralLoadForm(_patient)
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
  double _screenWidth = double.infinity;

  final Patient _patient;
  ViralLoad _viralLoad;
  bool _isLowerThanDetectable;
  bool _viralLoadBaselineDateValid = true;
  TextEditingController _viralLoadResultCtr = TextEditingController();
  TextEditingController _viralLoadLabNumberCtr = TextEditingController();

  // constructor
  _AddViralLoadFormState(this._patient) {
    _viralLoad = ViralLoad(patientART: _patient.artNumber, source: ViralLoadSource.MANUAL_INPUT());
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
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            PEBRAButtonRaised(
              'Save',
              onPressed: () { _onSubmitForm(context); },
            )
          ]),
          SizedBox(height: _spacing),
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
      answer: Column(
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
    return _makeQuestion('Was the viral load baseline result lower than detectable limit (<20 copies/mL)?',
      answer: DropdownButtonFormField<bool>(
        value: _isLowerThanDetectable,
        onChanged: (bool newValue) {
          setState(() {
            _isLowerThanDetectable = newValue;
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
    if (_isLowerThanDetectable == null || _isLowerThanDetectable) {
      return Container();
    }
    return _makeQuestion('What was the result of the viral load baseline (in c/mL)',
      answer: TextFormField(
        inputFormatters: [
          WhitelistingTextInputFormatter(RegExp('[0-9]')),
//          LengthLimitingTextInputFormatter(5),
        ],
        keyboardType: TextInputType.numberWithOptions(),
        controller: _viralLoadResultCtr,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter the viral load baseline result';
          } else if (int.parse(value) < 20) {
            return 'Value must be ≥ 20 (otherwise it is lower than detectable limit)';
          }
        },
      ),
    );
  }

  Widget _viralLoadBaselineLabNumberQuestion() {
    return _makeQuestion('Lab number of the viral load baseline',
      answer: TextFormField(
        controller: _viralLoadLabNumberCtr,
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

  Future<DateTime> _showDatePicker(BuildContext context, String title, {DateTime initialDate}) async {
    DateTime now = DateTime.now();
    return showDatePicker(
        context: context,
        initialDate: initialDate ?? now,
        firstDate: DateTime(now.year - 1, now.month, now.day),
        lastDate: DateTime.now(),
    );
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
      
      _viralLoad.viralLoad = _isLowerThanDetectable ? 0 : int.parse(_viralLoadResultCtr.text);
      _viralLoad.labNumber = _viralLoadLabNumberCtr.text == '' ? null : _viralLoadLabNumberCtr.text;
      _viralLoad.checkLogicAndResetUnusedFields();
      await DatabaseProvider().insertViralLoad(_viralLoad);
      _patient.viralLoads.add(_viralLoad);
      
      // we will also have to sink a PatientData event in case the patient's isActivated state changes
      Navigator.of(context).popUntil((Route<dynamic> route) {
        return route.settings.name == '/patient';
      });
    }
  }

}
