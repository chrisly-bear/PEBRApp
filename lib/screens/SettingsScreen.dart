import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pebrapp/components/PEBRAButtonFlat.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/exceptions/DocumentNotFoundException.dart';
import 'package:pebrapp/exceptions/NoLoginDataException.dart';
import 'package:pebrapp/exceptions/SWITCHLoginFailedException.dart';
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
  String username, firstName, lastName, healthCenter;
  LoginData(this.username, this.firstName, this.lastName, this.healthCenter);

  @override
  bool operator ==(other) {
    return (username == other.username && firstName == other.firstName && lastName == other.lastName && healthCenter == other.healthCenter);
  }

  @override
  int get hashCode => username.hashCode^firstName.hashCode^lastName.hashCode^healthCenter.hashCode;
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
          height: 700,
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
  bool _isLoading = false;

  @override
  _SettingsBodyState(this.loginData);

  @override
  void initState() {
    super.initState();
    latestBackupFromSharedPrefs.then((DateTime value) {
      setState(() {
        lastBackup = value == null ? 'unknown' : formatDateAndTime(value);
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
          child: IconButton(icon: Icon(Icons.close), onPressed: () {Navigator.of(context).popUntil(ModalRoute.withName('/'));}),
        ),
        Expanded(child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
              Text('${loginData.username}',
                style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('${loginData.firstName} ${loginData.lastName}',
                style: TextStyle(fontSize: 24.0),
              ),
              Text('${loginData.healthCenter}',
                style: TextStyle(fontSize: 24.0),
              ),
            _isLoading
                ? Padding(padding: EdgeInsets.symmetric(vertical: 17.5), child: SizedBox(width: 15.0, height: 15.0, child: CircularProgressIndicator()))
                : SizedBox(height: 50,),
              PEBRAButtonRaised('Set PIN'),
              PEBRAButtonRaised('Start Backup', onPressed: _isLoading ? null : () {_onPressBackupButton(context);},),
              Text("last backup:"),
              Text(lastBackup),
              PEBRAButtonRaised('Restore', onPressed: _isLoading ? null : () {_onPressRestoreButton(context);},),
              PEBRAButtonRaised('Logout', onPressed: () {_onPressLogout(context);},),
              PEBRAButtonRaised('Transfer Tablet', onPressed: () {_onPressTransferTablet(context);},),
              Text('Use this option if you want to keep the patient data on the device but change the user or health center.', textAlign: TextAlign.center,),
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
    VoidCallback onNotificationButtonPress;
    setState(() { _isLoading = true; });
    try {
      await DatabaseProvider().createAdditionalBackupOnSWITCH(loginData);
      setState(() {
        lastBackup = formatDateAndTime(DateTime.now());
      });
    } catch (e, s) {
      error = true;
      title = 'Backup Failed';
      switch (e.runtimeType) {
        // case NoLoginDataException should never occur because we don't show
        // the backup button when the user is not logged in
        case SWITCHLoginFailedException:
          message = 'Login to SWITCH failed. Contact the development team.';
          break;
        case DocumentNotFoundException:
          message = 'No existing backup found for user \'${loginData.username}\'';
          break;
        case SocketException:
          message = 'Make sure you are connected to the internet.';
          break;
        default:
          message = 'An unknown error occured. Contact the development team.';
          print('${e.runtimeType}: $e');
          print(s);
          onNotificationButtonPress = () {
            showErrorInPopup(e, s, context);
          };
      }
    }
    setState(() { _isLoading = false; });
    showFlushBar(context, message, title: title, error: error, onButtonPress: onNotificationButtonPress);
  }

  _onPressRestoreButton(BuildContext context) async {
      String resultMessage = 'Restore Successful';
      String title;
      bool error = false;
      VoidCallback onNotificationButtonPress;
      setState(() { _isLoading = true; });
      final LoginData loginData = await loginDataFromSharedPrefs;
      try {
        await restoreFromSWITCHtoolbox(loginData.username);
      } catch (e, s) {
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
          case SWITCHLoginFailedException:
            resultMessage = 'Login to SWITCH failed. Contact the development team.';
            break;
          case DocumentNotFoundException:
            resultMessage = 'No backup found for user \'${loginData.username}\'.';
            break;
          default:
            resultMessage = 'An unknown error occured. Contact the development team.';
            print('${e.runtimeType}: $e');
            print(s);
            onNotificationButtonPress = () {
              showErrorInPopup(e, s, context);
            };
        }
      }
      setState(() { _isLoading = false; });
      showFlushBar(context, resultMessage, title: title, error: error, onButtonPress: onNotificationButtonPress);
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

  _onPressTransferTablet(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(FIRSTNAME_KEY);
    await prefs.remove(LASTNAME_KEY);
    await prefs.remove(HEALTHCENTER_KEY);
    await prefs.remove(LAST_SUCCESSFUL_BACKUP_KEY);
    // Do not remove database data (otherwise this function is the same as the logout function)
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
    showFlushBar(context, 'Logged out. Enter the name and health center of the new user now.');
  }

}

class LoginBody extends StatefulWidget {
  @override
  createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final _loginFormKey = GlobalKey<FormState>();
  final _createAccountFormKey = GlobalKey<FormState>();
  bool _createAccountMode = true;
  TextEditingController _usernameCtr = TextEditingController();
  TextEditingController _firstNameCtr = TextEditingController();
  TextEditingController _lastNameCtr = TextEditingController();
  bool _isLoading = false;

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
    Widget createAccountFields() {
      if (!_createAccountMode) {
        return Container();
      }
      return Column(children: <Widget>[
        TextFormField(
          decoration: InputDecoration(
            labelText: 'First Name',
          ),
          textAlign: TextAlign.center,
          controller: _firstNameCtr,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter your first name';
            }
          },
        ),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Last Name',
          ),
          textAlign: TextAlign.center,
          controller: _lastNameCtr,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter your last name';
            }
          },
        ),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Health Center',
          ),
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
      ]);
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 25.0, bottom: 10.0),
          child: Text(_createAccountMode ? 'Create Account' : 'Login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0),),
        ),
        Container(
          width: 500,
          child: Card(
            margin: EdgeInsets.all(20),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Username',
                      helperText: _createAccountMode ? 'allowed (max. 12 symbols): lower case letters, numbers, "-"' : null,
                    ),
                    textAlign: TextAlign.center,
                    controller: _usernameCtr,
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp('[a-z0-9\-]')),
                      LengthLimitingTextInputFormatter(12),
                    ],
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a username';
                      }
                    },
                  ),
                  createAccountFields(),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: PEBRAButtonRaised(
              _createAccountMode ? 'Create Account' : 'Login',
              widget: _isLoading
                  ? Container(
                      height: 10.0,
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : null,
              onPressed: _isLoading ? null : (_createAccountMode
                  ? _onSubmitCreateAccountForm
                  : _onSubmitLoginForm),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Text(_createAccountMode
              ? 'Creating an account will store the name and health center on the server.'
              : 'Logging in will replace all data on this device with the data from the latest backup.',
            textAlign: TextAlign.center,
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
            child: PEBRAButtonFlat(
              _createAccountMode ? 'Log In' : 'Create Account',
              onPressed: () {
                setState(() => _createAccountMode = !_createAccountMode);
              },
            ),
          ),
        ),
      ],
    );
  }

  _onSubmitLoginForm() async {
    // Validate will return true if the form is valid, or false if the form is invalid.
    if (_loginFormKey.currentState.validate()) {
      String title;
      String notificationMessage = 'Login Successful';
      bool error = false;
      VoidCallback onNotificationButtonPress;
      setState(() { _isLoading = true; });
      final String username = _usernameCtr.text;
      try {
          LoginData loginData = await restoreFromSWITCHtoolbox(username);
          // if the restore was successful we store the login data on the device
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(USERNAME_KEY, loginData.username);
          await prefs.setString(FIRSTNAME_KEY, loginData.firstName);
          await prefs.setString(LASTNAME_KEY, loginData.lastName);
          await prefs.setString(HEALTHCENTER_KEY, loginData.healthCenter);
          Navigator.of(context).popUntil(ModalRoute.withName('/'));
      } catch (e, s) {
        error = true;
        title = 'Login Failed';
        switch (e.runtimeType) {
          // NoLoginDataException case should never occur because we create the
          // LoginData object at the beginning of this method
          case SocketException:
            notificationMessage = 'Make sure you are connected to the internet.';
            break;
          case SWITCHLoginFailedException:
            notificationMessage = 'Login to SWITCH failed. Contact the development team.';
            break;
          case DocumentNotFoundException:
            notificationMessage = 'User \'$username\' not found. Check your login data or create a new account.';
            break;
          default:
            notificationMessage = 'An unknown error occured. Contact the development team.';
            print('${e.runtimeType}: $e');
            print(s);
            onNotificationButtonPress = () {
              showErrorInPopup(e, s, context);
            };
        }
      }
      setState(() { _isLoading = false; });
      showFlushBar(context, notificationMessage, title: title, error: error, onButtonPress: onNotificationButtonPress);
    }
  }

  _onSubmitCreateAccountForm() async {
    // Validate will return true if the form is valid, or false if the form is invalid.
    if (_createAccountFormKey.currentState.validate()) {
      String notificationMessage = 'Account Created';
      String title;
      bool error = false;
      VoidCallback onNotificationButtonPress;
      setState(() { _isLoading = true; });
      final LoginData loginData = LoginData(
          _usernameCtr.text,
          _firstNameCtr.text,
          _lastNameCtr.text,
          _selectedHealthCenter
      );
      try {
        final bool userExists = await existsBackupForUser(loginData.username);
        if (userExists) {
          error = true;
          title = 'Account could not be created';
          notificationMessage = 'User \'${loginData.username}\' already exists.';
        } else {
          await DatabaseProvider().createFirstBackupOnSWITCH(loginData);
          // if backup was successful we store the login data on the device
          SharedPreferences prefs = await SharedPreferences.getInstance();
          bool usernameResult =
          await prefs.setString(USERNAME_KEY, loginData.username);
          bool firstNameResult =
          await prefs.setString(FIRSTNAME_KEY, loginData.firstName);
          bool lastNameResult =
          await prefs.setString(LASTNAME_KEY, loginData.lastName);
          bool healthCenterResult =
          await prefs.setString(HEALTHCENTER_KEY, loginData.healthCenter);
          if (!usernameResult || !firstNameResult || !lastNameResult || !healthCenterResult) {
            error = true;
            title = 'Something went wrong';
            notificationMessage = 'The account was created successfully. However, the login data could not be stored on the device. Please log in manually.';
          }
        }
      } catch (e, s) {
        error = true;
        title = 'Account could not be created';
        switch (e.runtimeType) {
          // case NoLoginDataException should never occur because we create the
          // loginData object at the beginning of this method
          case SocketException:
            notificationMessage = 'Make sure you are connected to the internet.';
            break;
          case SWITCHLoginFailedException:
            notificationMessage = 'Login to SWITCH failed. Contact the development team.';
            break;
          default:
            notificationMessage = 'An unknown error occured. Contact the development team.';
            print('${e.runtimeType}: $e');
            print(s);
            onNotificationButtonPress = () {
              showErrorInPopup(e, s, context);
            };
        }
      }
      setState(() { _isLoading = false; });
      if (!error) { Navigator.of(context).popUntil(ModalRoute.withName('/')); }
      showFlushBar(context, notificationMessage, title: title, error: error, onButtonPress: onNotificationButtonPress);
      // TODO: refresh settings screen to show the logged in state -> use the BloC
    }
  }
}
