import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pebrapp/components/PEBRAButtonFlat.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/components/RequiredActionContainerPEPhoneNumberUpload.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/beans/HealthCenter.dart';
import 'package:pebrapp/database/models/UserData.dart';
import 'package:pebrapp/exceptions/DocumentNotFoundException.dart';
import 'package:pebrapp/exceptions/InvalidPINException.dart';
import 'package:pebrapp/exceptions/NoPasswordFileException.dart';
import 'package:pebrapp/exceptions/SWITCHLoginFailedException.dart';
import 'package:pebrapp/screens/NewPINScreen.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/InputFormatters.dart';
import 'package:pebrapp/utils/SwitchToolboxUtils.dart';
import 'package:pebrapp/utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pebrapp/config/SharedPreferencesConfig.dart';

class SettingsScreen extends StatefulWidget {
  @override
  createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  UserData _loginData;

  // SETTINGS BODY fields
  String lastBackup = 'loading...';
  bool _isLoadingSettingsBody = false;

  // LOGIN BODY fields
  final _loginFormKey = GlobalKey<FormState>();
  final _createAccountFormKey = GlobalKey<FormState>();
  bool _createAccountMode = false;
  UserData _userData = UserData();
  TextEditingController _usernameCtr = TextEditingController();
  TextEditingController _firstNameCtr = TextEditingController();
  TextEditingController _lastNameCtr = TextEditingController();
  TextEditingController _phoneNumberCtr = TextEditingController();
  TextEditingController _pinCtr = TextEditingController();
  bool _isLoadingLoginBody = false;
  AnimateDirection shouldAnimateRequiredActionContainer;

  bool get _isLoggedIn => _loginData != null;

  @override
  void initState() {
    super.initState();
    DatabaseProvider().retrieveLatestUserData().then((UserData loginData) {
      this._loginData = loginData;
      setState(() {this._isLoading = false;});
    });
    latestBackupFromSharedPrefs.then((DateTime value) {
      setState(() {
        lastBackup = value == null ? 'unknown' : formatDateAndTime(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      print('~~~ LOADING SCREEN ~~~');
      return PopupScreen(
        actions: [],
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(SPINNER_SETTINGS_SCREEN),
            ),
          ),
        ),
      );
    }
    if (!_isLoggedIn) {
      print('~~~ LOGIN/CREATE ACCOUNT SCREEN ~~~');
      return WillPopScope(
        onWillPop: () => Future(() => false),
        child: PopupScreen(
          actions: [],
          child: _loginBody,
        ),
      );
    }
    print('~~~ SETTINGS SCREEN ~~~');
    return PopupScreen(
      title: 'Settings',
      child: _settingsBody,
      actions: [IconButton(icon: Icon(Icons.close), onPressed: () { Navigator.of(context).popUntil(ModalRoute.withName('/')); })],
    );

  }



  /*
   * SETTINGS BODY
   */

  Widget _buildRow(String description, String content) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: <Widget>[
          Expanded(flex: 1, child: Text(description)),
          Expanded(flex: 1, child: Text(content ?? '—')),
        ],
      ),
    );
  }

  _buildUserDataCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            _buildRow('Name', '${_loginData.firstName} ${_loginData.lastName}'),
            _buildRow('Username', _loginData.username),
            _buildRow('Health Center', _loginData.healthCenter.description),
            _buildRow('Phone Number', _loginData.phoneNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildRequiredActions() {
    if (_loginData.phoneNumberUploadRequired) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: RequiredActionContainerPEPhoneNumberUpload(
          _loginData.phoneNumber,
          animateDirection: shouldAnimateRequiredActionContainer,
        ),
      );
    }
    return SizedBox();
  }

  Widget get _settingsBody {
    const double _spacing = 20.0;
    return Column(
      children: <Widget>[
        _buildRequiredActions(),
        _buildUserDataCard(),
        PEBRAButtonFlat('Change Phone Number'),
        SizedBox(height: _spacing),
        PEBRAButtonRaised('Start Upload', onPressed: _isLoadingSettingsBody ? null : () {_onPressBackupButton(context);},),
        SizedBox(height: 10.0),
        Container(
          height: 40,
          child: Column(
              mainAxisAlignment: _isLoadingSettingsBody ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: _isLoadingSettingsBody ? [SizedBox(width: 15.0, height: 15.0, child: CircularProgressIndicator())] : [
                Text("last upload:"),
                Text(lastBackup),
              ]),
        ),
        SizedBox(height: _spacing),
        PEBRAButtonRaised('Logout', onPressed: _onPressLogout),
        SizedBox(height: 10.0),
        PEBRAButtonRaised('Transfer Device', onPressed: _onPressTransferTablet),
        SizedBox(height: 5.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Text('Use this option if you want to keep the patient data on the device but change the user.', textAlign: TextAlign.center,),
        ),
        SizedBox(height: _spacing),
      ],
    );
  }

  _onPressBackupButton(BuildContext context) async {
    String message = 'Upload Successful';
    String title;
    bool error = false;
    VoidCallback onNotificationButtonPress;
    setState(() { _isLoadingSettingsBody = true; });
    try {
      await DatabaseProvider().createAdditionalBackupOnSWITCH(_loginData);
      setState(() {
        lastBackup = formatDateAndTime(DateTime.now());
      });
    } catch (e, s) {
      error = true;
      title = 'Upload Failed';
      switch (e.runtimeType) {
      // case NoLoginDataException should never occur because we don't show
      // the backup button when the user is not logged in
        case SWITCHLoginFailedException:
          message = 'Login to SWITCH failed. Contact the development team.';
          break;
        case DocumentNotFoundException:
          message = 'No existing backup found for user \'${_loginData.username}\'';
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
    setState(() { _isLoadingSettingsBody = false; });
    showFlushbar(message, title: title, error: error, onButtonPress: onNotificationButtonPress);
  }

  Future<String> _setNewPIN(String username, BuildContext context) async {
    return Navigator.of(context).push(
      PageRouteBuilder<String>(
        settings: RouteSettings(name: '/new-pin'),
        opaque: false,
        transitionsBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2, Widget widget) {
          return FadeTransition(
            opacity: anim1,
            child: widget,
          );
        },
        pageBuilder: (BuildContext context, _, __) {
          return NewPINScreen(username);
        },
      ),
    );
  }

  /// Returns true if the user selected 'proceed', false if the user selected
  /// 'cancel'.
  Future<bool> _showWarningDialog(String title, String body) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            PEBRAButtonFlat(
              'Cancel',
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            PEBRAButtonRaised(
              'Proceed',
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              color: NOTIFICATION_ERROR,
            ),
          ],
        );
      },
    );
  }

  _onPressLogout() async {
    final bool proceed = await _showWarningDialog(
        'Warning',
        'If you log out all data on this device will be deleted. Data since '
            'your last upload ($lastBackup) will be lost forever! Before you '
            'proceed make sure you have uploaded your data.\n\n'
            'Are you sure you want to proceed?');
    if (proceed) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(LAST_SUCCESSFUL_BACKUP_KEY);
      await DatabaseProvider().resetDatabase();
      await PatientBloc.instance.sinkAllPatientsFromDatabase();
      setState(() {
        this._loginData = null;
      });
      print('logged out');
    }
  }

  _onPressTransferTablet() async {
    final bool proceed = await _showWarningDialog(
        'Warning',
        'If you transfer this device and then log in again with your own '
            'account all data since your last upload ($lastBackup) will be '
            'lost! Before you proceed make sure you uploaded your data.\n\n'
            'Are you sure you want to proceed?');
    if (proceed) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(LAST_SUCCESSFUL_BACKUP_KEY);
      await DatabaseProvider().deactivateCurrentUser();
      // Do not remove database data (otherwise this function is the same as the logout function)
      setState(() {
        this._loginData = null;
        this._createAccountMode = true;
      });
      showFlushbar('Create a new account now.', title: 'Logged Out');
    }
  }



/*
 * LOGIN BODY
 */

  Widget get _loginBody {

    return Form(
      key: _createAccountMode ? _createAccountFormKey : _loginFormKey,
      child: Column(
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
        DropdownButtonFormField<HealthCenter>(
          decoration: InputDecoration(
            labelText: 'Health Center',
          ),
          value: _userData.healthCenter,
          onChanged: (HealthCenter newValue) {
            setState(() {
              _userData.healthCenter = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select the health center at which you work';
            }
          },
          items: HealthCenter.allValues.map<DropdownMenuItem<HealthCenter>>((HealthCenter value) {
            return DropdownMenuItem<HealthCenter>(
              value: value,
              child: Text(value.description),
            );
          }).toList(),
        ),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Phone Number',
            prefixText: '+266-',
          ),
          textAlign: TextAlign.left,
          controller: _phoneNumberCtr,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            WhitelistingTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
            LesothoPhoneNumberTextInputFormatter(),
          ],
          validator: validatePhoneNumber,
        ),
      ]);
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 25.0, bottom: 10.0),
          child: Text(_createAccountMode ? 'Create Account' : 'Login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0),),
        ),
        Card(
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
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'PIN Code',
                    helperText: _createAccountMode ? 'at least 4 digits' : null,
                  ),
                  keyboardType: TextInputType.numberWithOptions(),
                  obscureText: true,
                  textAlign: TextAlign.center,
                  controller: _pinCtr,
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp('[0-9]')),
                  ],
                  validator: (value) {
                    if (value.isEmpty) {
                      return _createAccountMode ? 'Please enter a PIN code' : 'Please enter your PIN code';
                    } else if (value.length < 4) {
                      return 'At least 4 digits required';
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: PEBRAButtonRaised(
              _createAccountMode ? 'Create Account' : 'Login',
              widget: _isLoadingLoginBody
                  ? SizedBox(height: 15.0, width: 15.0, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(SPINNER_SETTINGS_SCREEN))) : null,
              onPressed: _isLoadingLoginBody ? null : (_createAccountMode
                  ? _onSubmitCreateAccountForm
                  : _onSubmitLoginForm),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Text(_createAccountMode
              ? 'Creating an account will store the name and health center on the server.'
              : 'Logging in will replace all data on this device with the data from the latest upload.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  _switchModeBlock() {
    const double _spacing = 20.0;
    return Column(
      children: <Widget>[
        SizedBox(height: _spacing),
        _createAccountMode
            ? Text("Already have an account?")
            : Text("Don't have an account yet?"),
        PEBRAButtonFlat(
          _createAccountMode ? 'Log In' : 'Create Account',
          onPressed: () {
            setState(() => _createAccountMode = !_createAccountMode);
          },
        ),
        SizedBox(height: _spacing),
      ],
    );
  }

  _onSubmitLoginForm() async {
    // Validate will return true if the form is valid, or false if the form is invalid.
    if (_loginFormKey.currentState.validate()) {
      String title;
      String notificationMessage = 'Login Successful';
      bool error = false;
      bool showNotification = false;
      VoidCallback onNotificationButtonPress;
      setState(() { _isLoadingLoginBody = true; });
      final String username = _usernameCtr.text;
      String pinCodeHash = hash(_pinCtr.text);
      bool retry = true;
      while (retry) {
        error = false;
        onNotificationButtonPress = null;
        retry = false;
        try {
          await restoreFromSWITCHtoolbox(username, pinCodeHash);
          // restore was successful, go to home screen
          Navigator.of(context).popUntil(ModalRoute.withName('/'));
        } catch (e, s) {
          showNotification = true;
          error = true;
          title = 'Login Failed';
          switch (e.runtimeType) {
          // NoLoginDataException case should never occur because we create the
          // LoginData object at the beginning of this method
            case SocketException:
              notificationMessage =
              'Make sure you are connected to the internet.';
              break;
            case SWITCHLoginFailedException:
              notificationMessage =
              'Login to SWITCH failed. Contact the development team.';
              break;
            case DocumentNotFoundException:
              notificationMessage =
              'User \'$username\' not found. Check your login data or create a new account.';
              break;
            case InvalidPINException:
              notificationMessage = 'Invalid PIN Code.';
              break;
            case NoPasswordFileException:
              // the password file was removed from SWITCHtoolbox -> prompt user
              // to set a new PIN
              final String newPINHash = await _setNewPIN(username, context);
              if (newPINHash != null) {
                error = false;
                title = 'Login Successful';
                notificationMessage = 'New PIN set.';
                retry = true;
                pinCodeHash = newPINHash;
              } else {
                showNotification = false;
              }
              break;
            default:
              notificationMessage =
              'An unknown error occured. Contact the development team.';
              print('${e.runtimeType}: $e');
              print(s);
              onNotificationButtonPress = () {
                showErrorInPopup(e, s, context);
              };
          }
        }
      }
      setState(() { _isLoadingLoginBody = false; });
      if (showNotification) {
        showFlushbar(notificationMessage, title: title,
            error: error,
            onButtonPress: onNotificationButtonPress);
      }
    }
  }

  _onSubmitCreateAccountForm() async {
    // Validate will return true if the form is valid, or false if the form is invalid.
    if (_createAccountFormKey.currentState.validate()) {
      String notificationMessage = '';
      String title = 'Error Creating Account';
      bool error = true;
      VoidCallback onNotificationButtonPress;
      setState(() { _isLoadingLoginBody = true; });
      _userData.username = _usernameCtr.text;
      _userData.firstName = _firstNameCtr.text;
      _userData.lastName = _lastNameCtr.text;
      _userData.phoneNumber = '+266-${_phoneNumberCtr.text}';
      _userData.phoneNumberUploadRequired = false;
      _userData.isActive = true;
      final String pinCodeHash = hash(_pinCtr.text);
      try {
        final bool userExists = await existsBackupForUser(_userData.username);
        if (userExists) {
          notificationMessage = 'User \'${_userData.username}\' already exists.';
        } else {
          await DatabaseProvider().createFirstBackupOnSWITCH(_userData, pinCodeHash);
          title = 'Account Created';
          notificationMessage = 'You are logged in as \'${_userData.username}\.';
          error = false;
        }
      } catch (e, s) {
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
      setState(() { _isLoadingLoginBody = false; });
      if (!error) { Navigator.of(context).popUntil(ModalRoute.withName('/')); }
      showFlushbar(notificationMessage, title: title, error: error, onButtonPress: onNotificationButtonPress);
    }
  }

}
