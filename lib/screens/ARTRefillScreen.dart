import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/RefillType.dart';
import 'package:pebrapp/database/models/ARTRefill.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
import 'package:pebrapp/screens/ARTRefillNotDoneScreen.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/VisibleImpactUtils.dart';
import 'package:pebrapp/utils/Utils.dart';

class ARTRefillScreen extends StatefulWidget {
  final Patient _patient;
  final String _nextRefillDate;

  ARTRefillScreen(this._patient, this._nextRefillDate);

  @override
  _ARTRefillScreenState createState() => _ARTRefillScreenState();
}

class _ARTRefillScreenState extends State<ARTRefillScreen> {
  String _nextRefillDate;

  void initState() {
    super.initState();
    setState(() {
      this._nextRefillDate = widget._nextRefillDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopupScreen(
      title: 'Next ART Refill',
      subtitle: widget._patient.artNumber,
      child: Center(child: _buildBody(context, widget._patient)),
    );
  }

  Widget _buildBody(BuildContext context, Patient patient) {
    return Column(
      children: <Widget>[
        Text(this._nextRefillDate, style: TextStyle(fontSize: 16.0)),
        SizedBox(height: 10.0),
        PEBRAButtonRaised(
          'Change Date',
          onPressed: () {
            _onPressChangeDate(context);
          },
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
              'The date above has to match the actual date of refill before clicking on "Refill done", otherwise change the date',
              style: TextStyle(fontSize: 16.0)),
        ),
        SizedBox(height: 50),
        PEBRAButtonRaised(
          'Refill Done',
          onPressed: () {
            _onPressRefillDone(context);
          },
        ),
        SizedBox(height: 10),
        PEBRAButtonRaised(
          'Refill Not Done',
          onPressed: () {
            _pushARTRefillNotDoneScreen(context, patient);
          },
        ),
        SizedBox(height: 30),
      ],
    );
  }

  void _onPressChangeDate(BuildContext context) async {
    DateTime nextRefillDate =
        await _showDatePickerWithTitle(context, 'Select the ART Refill Date');
    if (nextRefillDate != null) {
      final ARTRefill artRefill = ARTRefill(
          this.widget._patient.artNumber, RefillType.CHANGE_DATE(),
          nextRefillDate: nextRefillDate);
      await DatabaseProvider().insertARTRefill(artRefill);
      widget._patient.latestARTRefill = artRefill;
      widget._patient.latestDoneARTRefill = artRefill;
      final DateTime now = DateTime.now();
      if (nextRefillDate.isAfter(now)) {
        // send an event indicating that the art refill was done
        PatientBloc.instance.sinkRequiredActionData(
            RequiredAction(widget._patient.artNumber,
                RequiredActionType.REFILL_REQUIRED, null),
            true);
      } else {
        // send an event indicating that the art refill is overdue and has to be done
        PatientBloc.instance.sinkRequiredActionData(
            RequiredAction(widget._patient.artNumber,
                RequiredActionType.REFILL_REQUIRED, nextRefillDate),
            false);
      }
      // Adherence reminders and ART Refill reminders need to be updated
      uploadNotificationsPreferences(widget._patient);
      /*Navigator.of(context).popUntil((Route<dynamic> route) {
        return route.settings.name == '/patient';
      });*/
      setState(() {
        this._nextRefillDate = formatDate(nextRefillDate);
      });
    }
  }

  void _onPressRefillDone(BuildContext context) async {
    DateTime nextRefillDate = await _showDatePickerWithTitle(
        context, 'Select the Next ART Refill Date');
    if (nextRefillDate != null) {
      final ARTRefill artRefill = ARTRefill(
          this.widget._patient.artNumber, RefillType.DONE(),
          nextRefillDate: nextRefillDate);
      await DatabaseProvider().insertARTRefill(artRefill);
      widget._patient.latestARTRefill = artRefill;
      widget._patient.latestDoneARTRefill = artRefill;
      final DateTime now = DateTime.now();
      if (nextRefillDate.isAfter(now)) {
        // send an event indicating that the art refill was done
        PatientBloc.instance.sinkRequiredActionData(
            RequiredAction(widget._patient.artNumber,
                RequiredActionType.REFILL_REQUIRED, null),
            true);
      } else {
        // send an event indicating that the art refill is overdue and has to be done
        PatientBloc.instance.sinkRequiredActionData(
            RequiredAction(widget._patient.artNumber,
                RequiredActionType.REFILL_REQUIRED, nextRefillDate),
            false);
      }
      // Adherence reminders and ART Refill reminders need to be updated
      uploadNotificationsPreferences(widget._patient);
      Navigator.of(context).popUntil((Route<dynamic> route) {
        return route.settings.name == '/patient';
      });
    }
  }

  Future<DateTime> _showDatePicker(BuildContext context) async {
    final DateTime now = DateTime.now();
    return showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now.subtract(Duration(days: 1)),
        lastDate: DateTime(2050));
  }

  Future<DateTime> _showDatePickerWithTitle(
      BuildContext context, String title) async {
    final DateTime now = DateTime.now();
    return showDatePicker(
        context: context,
        initialDate: widget._patient.latestARTRefill?.nextRefillDate ?? now,
        firstDate: DateTime(1900),
        lastDate: DateTime(2050),
        builder: (BuildContext context, Widget widget) {
          return PopupScreen(
            backgroundColor: Colors.transparent,
            actions: [],
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
            ]),
          );
        });
  }

  void _pushARTRefillNotDoneScreen(BuildContext context, Patient patient) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        transitionsBuilder: (BuildContext context, Animation<double> anim1,
            Animation<double> anim2, Widget widget) {
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
