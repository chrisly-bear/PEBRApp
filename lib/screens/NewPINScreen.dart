import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' show join;
import 'package:pebrapp/components/PEBRAButtonFlat.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/config/PebraCloudConfig.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/exceptions/PebraCloudAuthFailedException.dart';
import 'package:pebrapp/utils/PebraCloudUtils.dart';
import 'package:pebrapp/utils/Utils.dart';

class NewPINScreen extends StatefulWidget {
  final String username;
  NewPINScreen(this.username);
  @override
  createState() => _NewPINScreenState(username);
}

class _NewPINScreenState extends State<NewPINScreen> {
  final String username;
  bool _isLoading = false;
  final _pinCodeFormKey = GlobalKey<FormState>();
  TextEditingController _pinCtr = TextEditingController();

  _NewPINScreenState(this.username);

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
        Text('PIN Code Reset',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0)),
        SizedBox(height: 20.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child:
              Text('Your PIN code has been reset. Please set a new PIN code:'),
        ),
        Card(
          margin: EdgeInsets.all(20.0),
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: pinCodeField(),
          ),
        ),
        PEBRAButtonRaised(
          'Set',
          widget: _isLoading
              ? SizedBox(
                  height: 15.0,
                  width: 15.0,
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              : null,
          onPressed: _isLoading
              ? null
              : () {
                  _onSubmitPINCodeForm(context);
                },
        ),
        SizedBox(height: 15.0),
        PEBRAButtonFlat(
          'Cancel',
          onPressed: _isLoading
              ? null
              : () {
                  _closeScreen(null);
                },
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  /// @param [returnValue] Set to the new pin hash if setting a new pin was
  /// successful, set it to null if there was an error or the process was
  /// cancelled.
  _closeScreen(String returnValue) {
    // pop all flushbar notifications
    Navigator.of(context).popUntil((Route<dynamic> route) {
      return route.settings.name == '/new-pin';
    });
    // pop the new-pin screen itself
    Navigator.of(context).pop(returnValue);
  }

  _onSubmitPINCodeForm(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    if (_pinCodeFormKey.currentState.validate()) {
      try {
        final String pinCodeHash = hash(_pinCtr.text);
        final String filepath = join(
            await DatabaseProvider().databasesDirectoryPath, 'PEBRA-password');
        var file = File(filepath);
        file = await file.writeAsString(pinCodeHash, flush: true);
        await uploadFileToPebraCloud(file, PEBRA_CLOUD_PASSWORD_FOLDER,
            filename: '$username.txt');
        _closeScreen(pinCodeHash);
      } catch (e, s) {
        final String title = 'PIN Update Failed';
        String message = '';
        VoidCallback onNotificationButtonPress;
        switch (e.runtimeType) {
          case SocketException:
            message = 'Make sure you are connected to the internet.';
            break;
          case PebraCloudAuthFailedException:
            message =
                'PEBRAcloud authentication failed. Contact the development team.';
            break;
          default:
            print('${e.runtimeType}: $e');
            print(s);
            message = 'An unknown error occured. Contact the development team.';
            onNotificationButtonPress = () {
              showErrorInPopup(e, s, context);
            };
        }
        showFlushbar(message,
            title: title,
            error: true,
            onButtonPress: onNotificationButtonPress);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }
}
