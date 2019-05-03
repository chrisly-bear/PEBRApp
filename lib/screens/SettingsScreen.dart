import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pebrapp/components/SizedButton.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/exceptions/DocumentNotFoundException.dart';
import 'package:pebrapp/exceptions/NoLoginDataException.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/SwitchToolboxUtils.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pebrapp/config/SharedPreferencesConfig.dart';

class SettingsScreen extends StatefulWidget {
  @override
  createState() => _SettingsScreenState();
}

class LoginData {
  String firstName, lastName, healthCenter;
  LoginData(this.firstName, this.lastName, this.healthCenter);

  @override
  bool operator ==(other) {
    return (firstName == other.firstName && lastName == other.lastName && healthCenter == other.healthCenter);
  }

  @override
  int get hashCode => firstName.hashCode^lastName.hashCode^healthCenter.hashCode;
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  LoginData _loginData;

  @override
  void initState() {
    loginDataFromSharedPrefs.then((LoginData loginData) {
      this._loginData = loginData;
      setState(() {this._isLoading = false;});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Widget _body = Center(
      child: Card(
        color: Color.fromARGB(255, 224, 224, 224),
        child: Container(
          width: 400,
          height: 600,
          child: _isLoading ? Center(child: Text('Loading...')) : (
              _loginData == null ? LoginBody() : Center(child: SettingsBody(this._loginData))),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.50),
      body: _body
    );
  }
}

class SettingsBody extends StatefulWidget {

  final LoginData loginData;

  @override
  SettingsBody(this.loginData);

  @override
  _SettingsBodyState createState() => _SettingsBodyState(loginData);
}

class _SettingsBodyState extends State<SettingsBody> {

  final LoginData loginData;
  String lastBackup = 'loading...';

  @override
  _SettingsBodyState(this.loginData);

  @override
  void initState() {
    super.initState();
    latestBackupFromSharedPrefs.then((DateTime value) {
      setState(() {
        lastBackup = value == null ? 'never' : formatDateAndTime(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          alignment: Alignment.centerRight,
          child: IconButton(icon: Icon(Icons.close), onPressed: () {Navigator.of(context).pop();}),
        ),
        Expanded(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
              SizedButton('Set PIN'),
              SizedButton('Start Backup', onPressed: () {_onPressBackupButton(context);},),
              Text("last backup:"),
              Text(lastBackup),
              SizedButton('Restore', onPressed: () {_onPressRestoreButton(context);},),
              SizedButton('Logout', onPressed: () {_onPressLogout(context);},),
              Text('${loginData.firstName} ${loginData.lastName}'),
              Text('${loginData.healthCenter}'),
            ],
          ),
        ),
      ],
    );
  }

  _onPressBackupButton(BuildContext context) async {
    String message = 'Backup Successful';
    String title;
    bool error = false;
    try {
      await DatabaseProvider().createAdditionalBackupOnSWITCH(loginData);
      setState(() {
        lastBackup = formatDateAndTime(DateTime.now());
      });
    } catch (e) {
      error = true;
      title = 'Backup Failed';
      switch (e.runtimeType) {
        // case NoLoginDataException should never occur because we don't show
        // the backup button when the user is not logged in
        case DocumentNotFoundException:
          message = 'No existing backup found for user \'${loginData.firstName} ${loginData.lastName} (${loginData.healthCenter})\'';
          break;
        case SocketException:
          message = 'Make sure you are connected to the internet.';
          break;
        default:
          message = '$e';
      }
    }
    showFlushBar(context, message, title: title, error: error);
  }

  _onPressRestoreButton(BuildContext context) async {
      String resultMessage = 'Restore Successful';
      String title;
      bool error = false;
      final LoginData loginData = await loginDataFromSharedPrefs;
      try {
        await restoreFromSWITCHtoolbox(loginData);
      } catch (e) {
        error = true;
        title = 'Restore Failed';
        switch (e.runtimeType) {
          case NoLoginDataException:
            // this case should never occur because we only show the 'Restore'
            // button when the user is logged in
            resultMessage = 'Not logged in. Please log in first.';
            break;
          case SocketException:
            resultMessage = 'Make sure you are connected to the internet.';
            break;
          case DocumentNotFoundException:
            resultMessage = 'No backup found for user \'${loginData.firstName} ${loginData.lastName} (${loginData.healthCenter})\'.';
            break;
          default:
            resultMessage = '$e';
        }
      }
      showFlushBar(context, resultMessage, title: title, error: error);
  }

  _onPressLogout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(FIRSTNAME_KEY);
    await prefs.remove(LASTNAME_KEY);
    await prefs.remove(HEALTHCENTER_KEY);
    await prefs.remove(LAST_SUCCESSFUL_BACKUP_KEY);
    await DatabaseProvider().resetDatabase();
    await PatientBloc.instance.sinkAllPatientsFromDatabase();
    // TODO (not super important): the pushReplacement results in a jerky animation
    //       -> We should call `setState` and set the loginData to null (or some
    //       other state variable such as `isLoggedIn`) and react to it by auto-
    //       matically rendering the login screen. We should only use one State
    //       component (namely _SettingsScreenState), LoginBody and SettingsBody
    //       should only be methods to call to render the Login UI /Settings UI.
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        opaque: false,
        transitionsBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2, Widget widget) {
          return FadeTransition(
            opacity: anim1,
            child: widget, // child is the value returned by pageBuilder
          );
        },
        pageBuilder: (BuildContext context, _, __) {
          return SettingsScreen();
        },
      ),
    );
    showFlushBar(context, 'Logged Out');
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
                  : () {_onSubmitLoginForm();},
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
      LoginData loginData = LoginData(_firstNameLoginCtr.text, _lastNameLoginCtr.text, _selectedHealthCenter);
      String title;
      String notificationMessage = 'Login Successful';
      bool error = false;
      try {
          await restoreFromSWITCHtoolbox(loginData);
          // if the restore was successful we store the login data on the device
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(FIRSTNAME_KEY, loginData.firstName);
          await prefs.setString(LASTNAME_KEY, loginData.lastName);
          await prefs.setString(HEALTHCENTER_KEY, loginData.healthCenter);
          Navigator.of(context).pop();
      } catch (e) {
        error = true;
        title = 'Login Failed';
        switch (e.runtimeType) {
          // NoLoginDataException case should never occur because we create the
          // LoginData object at the beginning of this method
          case SocketException:
            notificationMessage = 'Make sure you are connected to the internet.';
            break;
          case DocumentNotFoundException:
            notificationMessage = 'User \'${loginData.firstName} ${loginData.lastName} (${loginData.healthCenter})\' not found. Check your login data or create a new account.';
            break;
          default:
            notificationMessage = '$e';
        }
      }
      showFlushBar(context, notificationMessage, title: title, error: error);
    }
  }

  _onSubmitCreateAccountForm() async {
    // Validate will return true if the form is valid, or false if the form is invalid.
    if (_createAccountFormKey.currentState.validate()) {
      String notificationMessage = 'Account Created';
      String title;
      bool error = false;
      final LoginData loginData = LoginData(
          _firstNameCreateAccountCtr.text,
          _lastNameCreateAccountCtr.text,
          _selectedHealthCenter
      );
      try {
        final bool userExists = await existsBackupForUser(loginData);
        if (userExists) {
          error = true;
          title = 'Account could not be created';
          notificationMessage = 'User \'${loginData.firstName} ${loginData.lastName} (${loginData.healthCenter})\' already exists.';
        } else {
          await DatabaseProvider().createFirstBackupOnSWITCH(loginData);
          // if backup was successful we store the login data on the device
          SharedPreferences prefs = await SharedPreferences.getInstance();
          bool firstNameResult =
          await prefs.setString(FIRSTNAME_KEY, loginData.firstName);
          bool lastNameResult =
          await prefs.setString(LASTNAME_KEY, loginData.lastName);
          bool healthCenterResult =
          await prefs.setString(HEALTHCENTER_KEY, loginData.healthCenter);
          if (!firstNameResult || !lastNameResult || !healthCenterResult) {
            error = true;
            title = 'Something went wrong';
            notificationMessage = 'The account was created successfully. However, the login data could not be stored on the device. Please log in manually.';
          }
        }
      } catch (e) {
        error = true;
        title = 'Account could not be created';
        switch (e.runtimeType) {
          // case NoLoginDataException should never occur because we create the
          // loginData object at the beginning of this method
          case SocketException:
            notificationMessage = 'Make sure you are connected to the internet.';
            break;
          default:
            notificationMessage = '$e';
        }
      }
      if (!error) { Navigator.of(context).pop(); }
      showFlushBar(context, notificationMessage, title: title, error: error);
      // TODO: refresh settings screen to show the logged in state -> use the BloC
    }
  }
}
