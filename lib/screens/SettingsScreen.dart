import 'package:flutter/material.dart';
import 'package:pebrapp/components/SizedButton.dart';
import 'package:pebrapp/utils/Utils.dart';

class SettingsScreen extends StatefulWidget {
  @override
  createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loggedIn = false; // TODO: get login state
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 224, 224, 224),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _loggedIn ? Center(child: SettingsBody()) : LoginBody(),
    );
  }
}

class SettingsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedButton('Set PIN'),
        SizedButton('Start Backup'),
        Text("last backup: never"),
        SizedButton('Logout'),
      ],
    );
  }
}

class LoginBody extends StatefulWidget {
  @override
  createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _firstNameCtr = TextEditingController();
  TextEditingController _lastNameCtr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _loginForm(),
          _createAccountBlock(),
        ],
      ),
    );
  }

  _loginForm() {
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
                    controller: _firstNameCtr,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your first name';
                      }
                    },
                  ),
                  Text('Last Name'),
                  TextFormField(
                    textAlign: TextAlign.center,
                    controller: _lastNameCtr,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your last name';
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: SizedButton(
              'Login',
              onPressed: _onSubmitForm,
            ),
          ),
        ),
      ],
    );
  }

  _createAccountBlock() {
    return Column(
      children: <Widget>[
        Text("No account yet?"),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: SizedButton(
              'Create Account',
              onPressed: null, // TODO: show create account screen
            ),
          ),
        ),
      ],
    );
  }

  _onSubmitForm() async {
    // Validate will return true if the form is valid, or false if the form is invalid.
    if (_formKey.currentState.validate()) {
      await Future.delayed(Duration(seconds: 1)); // TODO: perform login
      final String finishNotification = 'Logged in successfully';
      showFlushBar(context, finishNotification);
    }
  }
}
