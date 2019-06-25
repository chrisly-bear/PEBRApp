import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/UserData.dart';
import 'package:pebrapp/exceptions/DocumentNotFoundException.dart';
import 'package:pebrapp/exceptions/InvalidPINException.dart';
import 'package:pebrapp/exceptions/NoPasswordFileException.dart';
import 'package:pebrapp/exceptions/SWITCHLoginFailedException.dart';
import 'package:pebrapp/screens/NewPINScreen.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/SwitchToolboxUtils.dart';
import 'package:pebrapp/utils/Utils.dart';

class DebugScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return PopupScreen(
      title: 'Debug',
      child: _body,
      actions: [
        IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).popUntil(ModalRoute.withName('/'));
            })
      ],
    );
  }

  Widget get _body {
    const double _spacing = 20.0;
    return Center(
      child: Column(
        children: <Widget>[
          SizedBox(height: _spacing),
          PEBRAButtonRaised('Restore',
              onPressed: _isLoading
                  ? null
                  : () {
                      _onPressRestoreButton(context);
                    },
              widget: _isLoading
                  ? SizedBox(
                      height: 15.0,
                      width: 15.0,
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              SPINNER_SETTINGS_SCREEN)))
                  : null),
          SizedBox(height: _spacing),
        ],
      ),
    );
  }

  Future<void> _onPressRestoreButton(BuildContext context) async {
    UserData userData = await DatabaseProvider().retrieveLatestUserData();
    String pinCodeHash = await userData.pinCodeHash;
    String title;
    String notificationMessage = 'Restore Successful';
    bool error = false;
    VoidCallback onNotificationButtonPress;
    setState(() {
      _isLoading = true;
    });
    bool retry = true;
    while (retry) {
      error = false;
      onNotificationButtonPress = null;
      retry = false;
      try {
        await restoreFromSWITCHtoolbox(userData.username, pinCodeHash);
        // restore was successful, go to home screen
        Navigator.of(context).popUntil(ModalRoute.withName('/'));
      } catch (e, s) {
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
                'User \'${userData.username}\' not found. Check your login data or create a new account.';
            break;
          case InvalidPINException:
            notificationMessage = 'Invalid PIN Code.';
            break;
          case NoPasswordFileException:
            final String newPINHash =
                await _setNewPIN(userData.username, context);
            if (newPINHash != null) {
              error = false;
              title = 'Login Successful';
              notificationMessage = 'New PIN set.';
              retry = true;
              pinCodeHash = newPINHash;
            } else {
              notificationMessage = 'New PIN required.';
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
    setState(() {
      _isLoading = false;
    });
    showFlushbar(notificationMessage,
        title: title, error: error, onButtonPress: onNotificationButtonPress);
  }

  Future<String> _setNewPIN(String username, BuildContext context) async {
    return Navigator.of(context).push(
      PageRouteBuilder<String>(
        settings: RouteSettings(name: '/new-pin'),
        opaque: false,
        transitionsBuilder: (BuildContext context, Animation<double> anim1,
            Animation<double> anim2, Widget widget) {
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
}
