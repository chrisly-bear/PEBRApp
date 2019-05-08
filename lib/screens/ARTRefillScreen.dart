import 'package:flutter/material.dart';
import 'package:pebrapp/components/SizedButton.dart';
import 'package:pebrapp/database/models/ARTRefill.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/screens/ARTRefillNotDoneScreen.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/Utils.dart';

class ARTRefillScreen extends StatelessWidget {
  final String _patientART;
  final String _nextRefillDate;

  ARTRefillScreen(this._patientART, this._nextRefillDate);

  @override
  Widget build(BuildContext context) {

    Widget _body = Center(
      child: Card(
        color: Color.fromARGB(255, 224, 224, 224),
        child: Container(
          width: 400,
          height: 600,
          child: _buildBody(context, _patientART),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.50),
      body: _body,
    );
  }

  Widget _buildBody(BuildContext context, String patientART) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).popUntil((Route<dynamic> route) {
                return route.settings.name == '/patient';
              });
            }
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 30,),
              Text('Next ART Refill',
                style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
              ),
              Text('$patientART',
                style: TextStyle(fontSize: 24.0),
              ),
              SizedBox(height: 50),
              Text(_nextRefillDate),
              SizedButton('Change Date', onPressed: () { _onPressChangeDate(context); },),
              SizedBox(height: 50,),
              SizedButton('Refill Done', onPressed: () { _onPressRefillDone(context); },),
              SizedBox(height: 10,),
              SizedButton('Refill Not Done', onPressed: () { _pushARTRefillNotDoneScreen(context, patientART); },),
            ],
          ),
        ),
      ],
    );
  }

  void _onPressChangeDate(BuildContext context) async {
    DateTime newDate = await _showDatePicker(context);
    if (newDate != null) {
      final ARTRefill artRefill = ARTRefill(this._patientART, RefillType.CHANGE_DATE, nextRefillDate: newDate);
      await PatientBloc.instance.sinkARTRefillData(artRefill);
      // TODO: upload the new date to the viral load database and if it didn't work show a message that the upload has to be retried manually
      Navigator.of(context).popUntil((Route<dynamic> route) {
        return route.settings.name == '/patient';
      });
    }
  }

  void _onPressRefillDone(BuildContext context) async {
    DateTime newDate = await _showDatePicker(context);
    if (newDate != null) {
      final ARTRefill artRefill = ARTRefill(this._patientART, RefillType.DONE, nextRefillDate: newDate);
      await PatientBloc.instance.sinkARTRefillData(artRefill);
      // TODO: upload the new date to the viral load database and if it didn't work show a message that the upload has to be retried manually
      Navigator.of(context).popUntil((Route<dynamic> route) {
        return route.settings.name == '/patient';
      });
    }
  }

  Future<DateTime> _showDatePicker(BuildContext context) async {
    final DateTime now = DateTime.now();
    return showDatePicker(context: context, initialDate: now, firstDate: now.subtract(Duration(days: 1)), lastDate: DateTime(2050), builder: (BuildContext context, Widget widget) {
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
                      'Select Next ART Refill Date',
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

  void _pushARTRefillNotDoneScreen(BuildContext context, String patientART) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return ARTRefillNotDoneScreen(patientART);
        },
      ),
    );
  }

}
