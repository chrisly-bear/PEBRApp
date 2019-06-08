import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/database/beans/RefillType.dart';
import 'package:pebrapp/database/models/ARTRefill.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/screens/ARTRefillNotDoneScreen.dart';
import 'package:pebrapp/state/PatientBloc.dart';

class ARTRefillScreen extends StatelessWidget {
  final Patient _patient;
  final String _nextRefillDate;

  ARTRefillScreen(this._patient, this._nextRefillDate);

  @override
  Widget build(BuildContext context) {
    return PopupScreen(
      title: 'Next ART Refill',
      subtitle: _patient.artNumber,
      child: _buildBody(context, _patient),
    );
  }

  Widget _buildBody(BuildContext context, Patient patient) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(_nextRefillDate),
        PEBRAButtonRaised('Change Date', onPressed: () { _onPressChangeDate(context); },),
        SizedBox(height: 50),
        PEBRAButtonRaised('Refill Done', onPressed: () { _onPressRefillDone(context); },),
        SizedBox(height: 10),
        PEBRAButtonRaised('Refill Not Done', onPressed: () { _pushARTRefillNotDoneScreen(context, patient); },),
        SizedBox(height: 30),
      ],
    );
  }

  void _onPressChangeDate(BuildContext context) async {
    DateTime newDate = await _showDatePicker(context);
    if (newDate != null) {
      final ARTRefill artRefill = ARTRefill(this._patient.artNumber, RefillType.CHANGE_DATE(), nextRefillDate: newDate);
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
      final ARTRefill artRefill = ARTRefill(this._patient.artNumber, RefillType.DONE(), nextRefillDate: newDate);
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

  void _pushARTRefillNotDoneScreen(BuildContext context, Patient patient) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        transitionsBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2, Widget widget) {
          return FadeTransition(
            opacity: anim1,
            child: widget, // child is the value returned by pageBuilder
          );
        },
        pageBuilder: (BuildContext context, _, __) {
          return ARTRefillNotDoneScreen(patient);
        },
      ),
    );
  }

}
