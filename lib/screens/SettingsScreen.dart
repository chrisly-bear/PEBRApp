import 'package:flutter/material.dart';
import 'package:pebrapp/components/SizedButton.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

const FIRSTNAME_KEY = "FirstName";
const LASTNAME_KEY = "LastName";
const HEALTHCENTER_KEY = "HealthCenter";

class SettingsScreen extends StatefulWidget {
  @override
  createState() => _SettingsScreenState();
}

class LoginData {
  String firstName, lastName, healthCenter;
  LoginData(this.firstName, this.lastName, this.healthCenter);
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  LoginData _loginData;

  @override
  void initState() {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      setState(() {
        this._isLoading = false;
        final firstName = prefs.getString(FIRSTNAME_KEY);
        final lastName = prefs.getString(LASTNAME_KEY);
        final healthCenter = prefs.getString(HEALTHCENTER_KEY);
        this._loginData = LoginData(firstName, lastName, healthCenter);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 224, 224, 224),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? Center(child: Text('Loading...'))
          : (_loginData == null
              ? LoginBody()
              : Center(child: SettingsBody(_loginData))),
    );
  }
}

class SettingsBody extends StatelessWidget {
  final LoginData loginData;
  SettingsBody(this.loginData);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedButton('Set PIN'),
        SizedButton('Start Backup'),
        Text("last backup: never"),
        SizedButton('Logout'),
        Text('${loginData.firstName} ${loginData.lastName}'),
        Text(loginData.healthCenter),
      ],
    );
  }
}

class LoginBody extends StatefulWidget {
  @override
  createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final _loginFormKey = GlobalKey<FormState>();
  final _createAccountFormKey = GlobalKey<FormState>();
  bool _createAccountMode = false;
  TextEditingController _firstNameLoginCtr = TextEditingController();
  TextEditingController _lastNameLoginCtr = TextEditingController();
  TextEditingController _firstNameCreateAccountCtr = TextEditingController();
  TextEditingController _lastNameCreateAccountCtr = TextEditingController();

  String _selectedHealthCenter;
  static final healthCenters = [
    'Maseru',
    'Morija',
    'Butha-Buthe',
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _createAccountMode ? _createAccountFormKey : _loginFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _formBlock(),
          _switchModeBlock(),
        ],
      ),
    );
  }

  _formBlock() {
    return Column(
      children: <Widget>[
        Container(
          width: 500,
          child: Card(
            margin: EdgeInsets.all(20),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Text('First Name'),
                  TextFormField(
                    textAlign: TextAlign.center,
                    controller: _createAccountMode
                        ? _firstNameCreateAccountCtr
                        : _firstNameLoginCtr,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your first name';
                      }
                    },
                  ),
                  Text('Last Name'),
                  TextFormField(
                    textAlign: TextAlign.center,
                    controller: _createAccountMode
                        ? _lastNameCreateAccountCtr
                        : _lastNameLoginCtr,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your last name';
                      }
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedHealthCenter,
                    onChanged: (String newValue) {
                      setState(() {
                        _selectedHealthCenter = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select the health center at which you work';
                      }
                    },
                    items: healthCenters
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: SizedButton(
              _createAccountMode ? 'Create Account' : 'Login',
              onPressed: _createAccountMode
                  ? _onSubmitCreateAccountForm
                  : _onSubmitLoginForm,
            ),
          ),
        ),
      ],
    );
  }

  _switchModeBlock() {
    return Column(
      children: <Widget>[
        _createAccountMode
            ? Text("Already have an account?")
            : Text("Don't have an account yet?"),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: SizedButton(
              _createAccountMode ? 'Log In' : 'Create Account',
              onPressed: () =>
                  {setState(() => _createAccountMode = !_createAccountMode)},
            ),
          ),
        ),
      ],
    );
  }

  _onSubmitLoginForm() async {
    // Validate will return true if the form is valid, or false if the form is invalid.
    if (_loginFormKey.currentState.validate()) {
      await Future.delayed(Duration(seconds: 1)); // TODO: perform login
      final String finishNotification = 'Logged in successfully';
      showFlushBar(context, finishNotification);
    }
  }

  _onSubmitCreateAccountForm() async {
    // Validate will return true if the form is valid, or false if the form is invalid.
    if (_createAccountFormKey.currentState.validate()) {
      // TODO: check if user already exists!!!
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool firstNameResult =
          await prefs.setString(FIRSTNAME_KEY, _firstNameCreateAccountCtr.text);
      bool lastNameResult =
          await prefs.setString(LASTNAME_KEY, _lastNameCreateAccountCtr.text);
      bool healthCenterResult =
          await prefs.setString(HEALTHCENTER_KEY, _selectedHealthCenter);
      final String finishNotification =
          firstNameResult && lastNameResult && healthCenterResult
              ? 'Created account successfully'
              : 'Something went wrong';
      showFlushBar(context, finishNotification);
    }
  }
}
