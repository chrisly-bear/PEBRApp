
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pebrapp/components/PEBRAButtonFlat.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/UserData.dart';
import 'package:pebrapp/utils/Utils.dart';

class NewPINScreen extends StatefulWidget {
  @override
  createState() => _NewPINScreenState();
}

class _NewPINScreenState extends State<NewPINScreen> {
  bool _isLoading = false;
  final _pinCodeFormKey = GlobalKey<FormState>();
  TextEditingController _pinCtr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future(() => false),
      child: PopupScreen(
        actions: [],
        child: Form(
          key: _pinCodeFormKey,
          child: Column(
            children: <Widget>[
              _formBlock(),
            ],
          ),
        ),
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
        inputFormatters: [
          WhitelistingTextInputFormatter(RegExp('[0-9]')),
        ],
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a PIN code';
          } else if (value.length < 4) {
            return 'At least 4 digits required';
          }
        },
      );
    }

    return Column(
      children: <Widget>[
        SizedBox(height: 25.0),
        Text('PIN Code Reset', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0)),
        SizedBox(height: 20.0),
        Text('Your PIN code has been reset. Please set a new PIN code:'),
        Card(
          margin: EdgeInsets.all(20.0),
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: pinCodeField(),
          ),
        ),
        PEBRAButtonRaised(
          'Set',
          widget: _isLoading ? SizedBox(height: 15.0, width: 15.0, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : null,
          onPressed: _isLoading ? null : _onSubmitPINCodeForm,
        ),
        SizedBox(height: 15.0),
        PEBRAButtonFlat(
          'Cancel',
          onPressed: _isLoading ? null : () { _closeScreen(false); },
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  /// @param [returnValue] Set to true if setting new pin was successful, false
  /// if there was an error or the process was cancelled.
  _closeScreen(bool returnValue) {
    // pop all flushbar notifications
    Navigator.of(context).popUntil((Route<dynamic> route) {
      return route.settings.name == '/new-pin';
    });
    // pop the new-pin screen itself
    Navigator.of(context).pop(returnValue);
  }

  _onSubmitPINCodeForm() async {
    setState(() {
      _isLoading = true;
    });
    if (_pinCodeFormKey.currentState.validate()) {

      // TODO: store PIN on SWITCHtoolbox, store it in local database, upload database to SWITCHtoolbox
      await Future.delayed(Duration(seconds: 2));

      _closeScreen(true);
    }
    setState(() {
      _isLoading = false;
    });
  }
}
