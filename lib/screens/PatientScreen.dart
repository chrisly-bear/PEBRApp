import 'package:flutter/material.dart';

class PatientScreen extends StatelessWidget {

  final _patientId;

  PatientScreen(this._patientId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Patient ${this._patientId}'),
        ),
        body: Center(
          child: Text('PATIENT SCREEN'),
        ));
  }
}
