
import 'package:flutter/material.dart';

class IconExplanationsScreen extends StatefulWidget {
  @override
  createState() => _IconExplanationsScreenState();
}

class _IconExplanationsScreenState extends State<IconExplanationsScreen> {

  @override
  Widget build(BuildContext context) {

    Widget _body = Center(
      child: Card(
        color: Color.fromARGB(255, 224, 224, 224),
        child: Container(
          width: 450,
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
            Text('Icon Explanations',
              style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30,),
            _makeExplanation('assets/icons/saturday_clinic_club_fett.png', 'Saturday Clinic Club (SCC)'),
            _makeExplanation('assets/icons/youth_club_fett.png', 'Community Youth Club (CTC)'),
            _makeExplanation('assets/icons/phonecall_pe_fett.png', 'Phone Call by PE'),
            _makeExplanation('assets/icons/homevisit_pe_fett.png', 'Home Visit by PE'),
            _makeExplanation('assets/icons/nurse_clinic_fett.png', 'By the nurse at the clinic'),
            _makeExplanation('assets/icons/schooltalk_pe_fett.png', 'School visit and health talk by PE'),
          ],
        ),
        ),
      ],
    );
  }

}

Padding _makeExplanation(String iconAsset, String explanation) {
  return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            iconAsset,
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              explanation,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          )
        ],
      )
  );
}