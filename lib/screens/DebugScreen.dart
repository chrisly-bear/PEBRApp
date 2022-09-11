import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/database/models/UserData.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/exceptions/BackupNotFoundException.dart';
import 'package:pebrapp/exceptions/InvalidPINException.dart';
import 'package:pebrapp/exceptions/NoPasswordFileException.dart';
import 'package:pebrapp/exceptions/PebraCloudAuthFailedException.dart';
import 'package:pebrapp/screens/NewPINScreen.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/PebraCloudUtils.dart';
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
    const double _spacing = 15.0;

    Widget _buttonRow(
        {@required String description,
        @required String buttonLabel,
        @required VoidCallback onPressed}) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(description),
          PEBRAButtonRaised(
            buttonLabel,
            onPressed: _isLoading
                ? null
                : () {
                    onPressed();
                  },
          ),
        ],
      );
    }

    Widget _dropTabelRow(String tableName) {
      return _buttonRow(
        description: 'Drop $tableName table',
        buttonLabel: 'Drop',
        onPressed: () {
          _onPressDropTableButton(context, tableName);
        },
      );
    }

    Widget _card(String title, List<Widget> children) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: _spacing),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title,
                  style: TextStyle(
                      fontSize: 15.0,
                      fontStyle: FontStyle.italic,
                      color: DATA_SUBTITLE_TEXT)),
              Divider(),
              SizedBox(height: 5.0),
              ...children,
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? SizedBox(
                height: 15.0,
                width: 15.0,
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(SPINNER_SETTINGS_SCREEN),
                ),
              )
            : Column(
                children: <Widget>[
                  _card('Misc.', [
                    _buttonRow(
                      description: 'Restore data from PEBRAcloud',
                      buttonLabel: 'Restore',
                      onPressed: () {
                        _onPressRestoreButton(context);
                      },
                    ),
                  ]),
                  _card('Database Operations', [
                    _dropTabelRow(ViralLoad.tableName),
                    SizedBox(height: _spacing),
                    _dropTabelRow(PreferenceAssessment.tableName),
                    SizedBox(height: _spacing),
                    _dropTabelRow(Patient.tableName),
                  ]),
                  _card('Notifications', [
                    _buttonRow(
                      description: 'Show Normal Notification',
                      buttonLabel: 'Show',
                      onPressed: () {
                        showFlushbar('test notification');
                      },
                    ),
                    SizedBox(height: _spacing),
                    _buttonRow(
                      description: 'Show Transfer Notification',
                      buttonLabel: 'Show',
                      onPressed: () {
                        showTransferringDataFlushbar();
                      },
                    ),
                    SizedBox(height: _spacing),
                    _buttonRow(
                      description: 'Dismiss Transfer Notification',
                      buttonLabel: 'Show',
                      onPressed: () {
                        dismissTransferringDataFlushbar();
                      },
                    ),
                  ]),
                ],
              ),
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
        await restoreFromPebraCloud(userData.username, pinCodeHash);
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
          case PebraCloudAuthFailedException:
            notificationMessage =
                'PEBRAcloud authentication failed. Contact the development team.';
            break;
          case BackupNotFoundException:
            notificationMessage =
                'No data found for user \'${userData.username}\'. Check your login data or create a new account.';
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

  Future<void> _onPressDropTableButton(
      BuildContext context, String tableName) async {
    setState(() {
      _isLoading = true;
    });
    int rowsDeleted = await DatabaseProvider().resetTable(tableName);
    setState(() {
      _isLoading = false;
    });
    PatientBloc.instance.sinkAllPatientsFromDatabase();
    showFlushbar('Deleted $rowsDeleted rows.', title: '$tableName reset');
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
