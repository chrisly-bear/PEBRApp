import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/database/beans/RefillType.dart';
import 'package:pebrapp/database/models/ARTRefill.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/screens/ARTRefillNotDoneScreen.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/Utils.dart';

class ARTRefillScreen extends StatelessWidget {
  final Patient _patient;
  final String _nextRefillDate;

  ARTRefillScreen(this._patient, this._nextRefillDate);

  @override
  Widget build(BuildContext context) {
    return PopupScreen(
      title: 'Next ART Refill',
      subtitle: _patient.artNumber,
      child: Center(child: _buildBody(context, _patient)),
    );
  }

  Widget _buildBody(BuildContext context, Patient patient) {
    return Column(
      children: <Widget>[
        Text(_nextRefillDate, style: TextStyle(fontSize: 16.0)),
        SizedBox(height: 10.0),
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
    DateTime newDate = await _showDatePickerWithTitle(context, 'Select the Next ART Refill Date');
    if (newDate != null) {
      final ARTRefill artRefill = ARTRefill(this._patient.artNumber, RefillType.CHANGE_DATE(), nextRefillDate: newDate);
      await PatientBloc.instance.sinkARTRefillData(artRefill);
      _uploadARTRefillDate(context, newDate);
      Navigator.of(context).popUntil((Route<dynamic> route) {
        return route.settings.name == '/patient';
      });
    }
  }

  void _onPressRefillDone(BuildContext context) async {
    DateTime newDate = await _showDatePickerWithTitle(context, 'Select the Next ART Refill Date');
    if (newDate != null) {
      final ARTRefill artRefill = ARTRefill(this._patient.artNumber, RefillType.DONE(), nextRefillDate: newDate);
      await PatientBloc.instance.sinkARTRefillData(artRefill);
      _uploadARTRefillDate(context, newDate);
      Navigator.of(context).popUntil((Route<dynamic> route) {
        return route.settings.name == '/patient';
      });
    }
  }

  Future<void> _uploadARTRefillDate(BuildContext context, DateTime date) async {
    // TODO: upload the new date to the viral load database and if it didn't work show a message that the upload has to be retried manually
    await Future.delayed(Duration(seconds: 3));
    showFlushBar(context, 'Please upload the notifications preferences manually.', title: 'Upload of ART Refill Date Failed', error: true, buttonText: 'Retry\nNow', onButtonPress: () {
      Navigator.of(context).popUntil((Route<dynamic> route) {
        return route.settings.name != '/flushbarRoute';
      });
      _uploadARTRefillDate(context, date);
    });
  }

  Future<DateTime> _showDatePicker(BuildContext context) async {
    final DateTime now = DateTime.now();
    return showDatePicker(context: context, initialDate: now, firstDate: now.subtract(Duration(days: 1)), lastDate: DateTime(2050));
  }

  Future<DateTime> _showDatePickerWithTitle(BuildContext context, String title) async {
    final DateTime now = DateTime.now();
    return showDatePicker(context: context, initialDate: now, firstDate: now.subtract(Duration(days: 1)), lastDate: DateTime(2050), builder: (BuildContext context, Widget widget) {
      return PopupScreen(
        backgroundColor: Colors.transparent,
        actions: [],
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              widget,
            ]
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
