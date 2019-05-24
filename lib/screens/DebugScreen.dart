
import 'package:flutter/material.dart';
import 'package:pebrapp/components/SizedButton.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/utils/Utils.dart';

class DebugScreen extends StatefulWidget {
  @override
  createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {

    Widget _body = Center(
      child: Card(
        color: Color.fromARGB(255, 224, 224, 224),
        child: Container(
          width: 400,
          height: 600,
          child: _buildSettingsBody(context),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.50),
      body: _body
    );
  }

  Widget _buildSettingsBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          alignment: Alignment.centerRight,
          child: IconButton(icon: Icon(Icons.close), onPressed: () {Navigator.of(context).popUntil(ModalRoute.withName('/'));}),
        ),
        Expanded(child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 30,),
            Text('Debug',
              style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
            ),
            _isLoading
                ? Padding(padding: EdgeInsets.symmetric(vertical: 17.5), child: SizedBox(width: 15.0, height: 15.0, child: CircularProgressIndicator()))
                : SizedBox(height: 50,),
            PEBRAButtonRaised(
              'Get DB Info',
              onPressed: _getDBInfo,
            ),
            PEBRAButtonRaised(
              'Get All Patients',
              onPressed: _getAllPatients,
            ),
          ],
        ),
        ),
      ],
    );
  }

  _getDBInfo() async {
    final columns = await DatabaseProvider().getTableInfo(Patient.tableName);
    print('### TABLE \'${Patient.tableName}\' INFO <START> ###');
    for (final column in columns) {
      print(column);
    }
    print('### TABLE \'${Patient.tableName}\' INFO <END> ###');
  }

  _getAllPatients() async {
    final List<Patient> patients = await DatabaseProvider().retrieveLatestPatients();
    if (patients.length == 0) { print('No patients in Patient table'); }
    for (final patient in patients) {
      print(patient);
    }
    showFlushBar(context, "${patients.length} patients in database");
  }


}
