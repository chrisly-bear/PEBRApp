import 'package:flutter/material.dart';
import 'package:pebrapp/components/SizedButton.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/utils/Utils.dart';

class PreferenceAssessmentScreen extends StatelessWidget {
  final String _patientART;

  PreferenceAssessmentScreen(this._patientART);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 224, 224, 224),
        appBar: AppBar(
          title: Text('Preference Assessment: ${this._patientART}'),
        ),
        body: Center(child: PreferenceAssessmentForm(_patientART)));
  }
}

class PreferenceAssessmentForm extends StatefulWidget {
  final String _patientART;

  PreferenceAssessmentForm(this._patientART);

  @override
  createState() => _PreferenceAssessmentFormState(_patientART);
}

class _PreferenceAssessmentFormState extends State<PreferenceAssessmentForm> {

  // fields
  final _formKey = GlobalKey<FormState>();
  var _pa = PreferenceAssessment.uninitialized();
  bool _artRefillOption1PersonAvailable;
  // TODO: add all necessary controller that we need to get the text from the form fields
  var _phoneAvailableCtr = TextEditingController();
  var _supportPreferencesCtr = TextEditingController();

  // constructor
  _PreferenceAssessmentFormState(String patientART) {
    _pa.patientART = patientART;
  }

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
            children: [SizedButton('Export')]),
        _buildTitle('Support'),
        _buildSupportCard(),
        _buildTitle('EAC (Enhanced Adherence Counseling)'),
        _buildEACCard(),

        Center(child: _buildTitle('Next Preference Assessment')),
        Center(child: Text('Today')),
        Container(height: 50), // padding at bottom
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedButton(
            'Save',
            onPressed: _onSubmitForm,
          )
        ]),
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
            child: Column(
              children: [
                _artRefillOption1(),
                _artRefillOptionPersonAvailable(),
              ],
            )));
  }

  Row _artRefillOptionPersonAvailable() {
    return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Is there a VHW available nearby?'),
                  DropdownButton<bool>(
                    value: _artRefillOption1PersonAvailable,
                    onChanged: (bool newValue) {
                      setState(() {
                        _artRefillOption1PersonAvailable = newValue;
                      });
                    },
                    items: <bool>[
                      true,
                      false
                    ].map<DropdownMenuItem<bool>>(
                        (bool value) {
                      String description;
                      switch (value) {
                        case true:
                          description = 'Yes';
                          break;
                        case false:
                          description = 'No';
                          break;
                      }
                      return DropdownMenuItem<bool>(
                        value: value,
                        child: Text(description),
                      );
                    }).toList(),
                  )
                ],
              );
  }

  Row _artRefillOption1() {
    return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                      'How and where do you want to refill your ART mainly?'),
                  DropdownButton<ARTRefillOption>(
                    value: _pa.artRefillOption1,
                    onChanged: (ARTRefillOption newValue) {
                      setState(() {
                        _pa.artRefillOption1 = newValue;
                      });
                    },
                    items: <ARTRefillOption>[
                      ARTRefillOption.CLINIC,
                      ARTRefillOption.COMMUNITY_ADHERENCE_CLUB,
                      ARTRefillOption.PE_HOME_DELIVERY,
                      ARTRefillOption.TREATMENT_BUDDY,
                      ARTRefillOption.VHW
                    ].map<DropdownMenuItem<ARTRefillOption>>(
                        (ARTRefillOption value) {
                      String description;
                      switch (value) {
                        case ARTRefillOption.CLINIC:
                          description = 'Clinic';
                          break;
                        case ARTRefillOption.COMMUNITY_ADHERENCE_CLUB:
                          description = 'Community Adherence Club';
                          break;
                        case ARTRefillOption.PE_HOME_DELIVERY:
                          description = 'Home Delivery (PE)';
                          break;
                        case ARTRefillOption.TREATMENT_BUDDY:
                          description = 'Treatment Buddy';
                          break;
                        case ARTRefillOption.VHW:
                          description = 'Treatment Buddy';
                          break;
                      }
                      return DropdownMenuItem<ARTRefillOption>(
                        value: value,
                        child: Text(description),
                      );
                    }).toList(),
                  )
                ],
              );
  }

  _buildNotificationsCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            _phoneAvailableQuestion(),
          ],
        ),
      ),
    );
  }

  Row _phoneAvailableQuestion() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Do you have regular access to a phone where you can receive confidential information?'),
        DropdownButton<bool>(
          value: _pa.phoneAvailable,
          onChanged: (bool newValue) {
            setState(() {
              _pa.phoneAvailable = newValue;
            });
          },
          items: <bool>[
            true,
            false
          ].map<DropdownMenuItem<bool>>(
                  (bool value) {
                String description;
                switch (value) {
                  case true:
                    description = 'Yes';
                    break;
                  case false:
                    description = 'No';
                    break;
                }
                return DropdownMenuItem<bool>(
                  value: value,
                  child: Text(description),
                );
              }).toList(),
        )
      ],
    );
  }

  _buildSupportCard() {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: [
              _supportPreferencesQuestion(),
            ],
          ),
        ));
  }

  Row _supportPreferencesQuestion() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
            'What kind of support do you mainly wish? (tick all that apply)'),
        Container(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            CheckboxListTile(
                // secondary: const Icon(Icons.local_hospital),
                title: Text('Saturday Clinic Club'),
                dense: true,
                value: _pa.supportPreferences.saturdayClinicClubSelected,
                onChanged: (bool newValue) => this.setState(() {
                  _pa.supportPreferences.saturdayClinicClubSelected = newValue;
                })
              ),
            CheckboxListTile(
              // secondary: const Icon(Icons.local_hospital),
                title: Text('Community Youth Club'),
                dense: true,
                value: _pa.supportPreferences.communityYouthClubSelected,
                onChanged: (bool newValue) => this.setState(() {
                  _pa.supportPreferences.communityYouthClubSelected = newValue;
                })
            ),
            CheckboxListTile(
              // secondary: const Icon(Icons.local_hospital),
                title: Text('1x Phone Call from PE'),
                dense: true,
                value: _pa.supportPreferences.phoneCallPESelected,
                onChanged: (bool newValue) => this.setState(() {
                  _pa.supportPreferences.phoneCallPESelected = newValue;
                })
            ),
            CheckboxListTile(
              // secondary: const Icon(Icons.local_hospital),
                title: Text('1x Home Visit from PE'),
                dense: true,
                value: _pa.supportPreferences.homeVisitPESelected,
                onChanged: (bool newValue) => this.setState(() {
                  _pa.supportPreferences.homeVisitPESelected = newValue;
                })
            ),
            CheckboxListTile(
              // secondary: const Icon(Icons.local_hospital),
                title: Text('Nurse at the Clinic'),
                dense: true,
                value: _pa.supportPreferences.nurseAtClinicSelected,
                onChanged: (bool newValue) => this.setState(() {
                  _pa.supportPreferences.nurseAtClinicSelected = newValue;
                })
            ),
            CheckboxListTile(
              // secondary: const Icon(Icons.local_hospital),
                title: Text('None'),
                dense: true,
                value: _pa.supportPreferences.areAllDeselected,
                onChanged: (bool newValue) {
                  if (newValue) {
                    this.setState(() {
                      _pa.supportPreferences.deselectAll();
                    });
                  }
                }
            ),
          ],
        ),
        )
      ],
    );
  }

  _buildEACCard() {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: null,
        ));
  }

  _onSubmitForm() async {
    if (_formKey.currentState.validate()) {
      print('NEW PREFERENCE ASSESSMENT (_id will be given by SQLite database):\n$_pa');
      await DatabaseProvider().insertPreferenceAssessment(_pa);
      Navigator.of(context).pop(); // close Preference Assessment screen
      showFlushBar(context, 'Preference Assessment saved');
    }
  }
}
