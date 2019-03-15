import 'package:flutter/material.dart';
import 'package:pebrapp/components/SizedButton.dart';

class PreferenceAssessmentScreen extends StatelessWidget {
  final _patientART;

  PreferenceAssessmentScreen(this._patientART);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 224, 224, 224),
        appBar: AppBar(
          title: Text('Preference Assessment: ${this._patientART}'),
        ),
        body: Center(child: PreferenceAssessmentScreenBody()));
  }
}

class PreferenceAssessmentScreenBody extends StatelessWidget {
  final _tableRowPaddingVertical = 5.0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _buildTitle('ART Refill'),
        _buildARTRefillCard(),
        _buildTitle('Notifications'),
        _buildNotificationsCard(),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [SizedButton('Export')]
        ),
        _buildTitle('Support'),
        _buildSupportCard(),
        _buildTitle('EAC (Enhanced Adherence Counseling)'),
        _buildEACCard(),

        Center(child: _buildTitle('Next Preference Assessment')),
        Center(child: Text('Today')),
        Container(height: 50), // padding at bottom
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [SizedButton('Save')]),
        Container(height: 50), // padding at bottom
      ],
    );
  }

  _buildTitle(String title) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  _buildARTRefillCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: null,
      ),
    );
  }

  _buildNotificationsCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: null,
      ),
    );
  }

  _buildSupportCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: null,
      )
    );
  }

  _buildEACCard() {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: null,
        )
    );
  }

}
