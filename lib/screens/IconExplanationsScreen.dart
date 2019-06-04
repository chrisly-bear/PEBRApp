
import 'package:flutter/material.dart';

class IconExplanationsScreen extends StatefulWidget {
  @override
  createState() => _IconExplanationsScreenState();
}

class _IconExplanationsScreenState extends State<IconExplanationsScreen> {
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
            Text('Icon Explanations',
              style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30,),
            Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/icons/saturday_clinic_club_fett.png',
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Saturday Clinic Club (SCC)',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    )
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/icons/youth_club_fett.png',
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Community Youth Club (CTC)',
                        style: TextStyle(
                          fontSize: 20,
                          //fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                 ],
                )
            ),
            Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/icons/phonecall_pe_fett.png',
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Phone Call by PE',
                        style: TextStyle(
                            fontSize: 20,
                        ),
                      ),
                    )
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/icons/homevisit_pe_fett.png',
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Home Visit by PE',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    )
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/icons/nurse_clinic_fett.png',
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'By the nurse at the clinic',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    )
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/icons/schooltalk_pe_fett.png',
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'School visit and health talk by PE',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    )
                  ],
                )
            ),
          ],
        ),
        ),
      ],
    );
  }

}
