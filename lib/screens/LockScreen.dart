
import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/UserData.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/Utils.dart';

class LockScreen extends StatefulWidget {
  @override
  createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _isLoading = true;
  String _storedPINHash;

  @override
  void initState() {
    super.initState();
    DatabaseProvider().retrieveLatestUserData().then((UserData loginData) {
      loginData.pinCodeHash.then((String storedPINCodeHash) {
        _storedPINHash = storedPINCodeHash;
        setState(() { this._isLoading = false; });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double backgroundBlur = 10.0;
    if (_isLoading) {
      print('~~~ LOADING SCREEN ~~~');
      return PopupScreen(
        actions: [],
        backgroundBlur: backgroundBlur,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(SPINNER_LOCK_SCREEN),
            ),
          ),
        ),
      );
    }
    print('~~~ LOCK SCREEN ~~~');
    return WillPopScope(
      onWillPop: () => Future(() => false),
      child: PopupScreen(
        actions: [],
        backgroundBlur: backgroundBlur,
        child: LockScreenBody(_storedPINHash),
      ),
    );

  }
}

class LockScreenBody extends StatefulWidget {
  final String _pinHashed;

  LockScreenBody(this._pinHashed);

  @override
  createState() => _LockScreenBodyState(_pinHashed);
}

class _LockScreenBodyState extends State<LockScreenBody> {
  final String _pinHashed;
  final _pinCodeFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';

  _LockScreenBodyState(this._pinHashed);

  TextEditingController _pinCtr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _pinCodeFormKey,
      child: Column(
        children: <Widget>[
          _formBlock(),
        ],
      ),
    );
  }

  _formBlock() {

    Widget pinCodeField() {
      return TextFormField(
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.numberWithOptions(),
        obscureText: true,
        textAlign: TextAlign.center,
        controller: _pinCtr,
      );
    }

    return Column(
      children: <Widget>[
        SizedBox(height: 25.0),
        Text('App Locked', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0)),
        SizedBox(height: 20.0),
        Text('Please enter your PIN code:'),
        Card(
          margin: EdgeInsets.all(20.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: pinCodeField(),
          ),
        ),
        _errorMessage.isEmpty
          ? SizedBox()
          : Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Text(_errorMessage, style: TextStyle(color: Colors.red, fontSize: 13.0, fontWeight: FontWeight.w400),
              ),
        ),
        PEBRAButtonRaised(
          'Unlock',
          widget: _isLoading ? SizedBox(height: 15.0, width: 15.0, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : null,
          onPressed: _isLoading ? null : _onSubmitPINCodeForm,
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  /// Returns true if the PIN was correct.
  Future<bool> get validatePIN async {
    return verifyHashAsync(_pinCtr.text, _pinHashed);
  }

  _onSubmitPINCodeForm() async {
    setState(() {
      _isLoading = true;
    });
    if (_pinCtr.text.isEmpty) {
      _errorMessage = 'Please enter your PIN code.';
    } else if (await validatePIN) {
      _errorMessage = '';
      // pop all flushbar notifications
      Navigator.of(context).popUntil((Route<dynamic> route) {
        return route.settings.name == '/lock';
      });
      // pop the lock screen itself
      Navigator.of(context).pop();
    } else {
      _errorMessage = 'Incorrect PIN code.';
    }
    setState(() {
      _isLoading = false;
    });
  }
}
