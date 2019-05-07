import 'package:flutter/material.dart';
import 'package:pebrapp/components/SizedButton.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/screens/ARTRefillNotDoneScreen.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/Utils.dart';

class ARTRefillScreen extends StatelessWidget {
  final String _patientART;

  ARTRefillScreen(this._patientART);

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
              SizedBox(height: 50,),
              Text('31.12.2000'),
              SizedButton('Change Date'),
              SizedBox(height: 50,),
              SizedButton('Refill Done'),
              SizedBox(height: 10,),
              SizedButton('Refill Not Done', onPressed: () { _pushARTRefillNotDoneScreen(context, patientART); },),
            ],
          ),
        ),
      ],
    );
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
