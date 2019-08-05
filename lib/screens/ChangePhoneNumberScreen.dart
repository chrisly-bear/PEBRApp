import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pebrapp/components/PEBRAButtonRaised.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/utils/InputFormatters.dart';

class ChangePhoneNumberScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChangePhoneNumberState();
  }
}

class _ChangePhoneNumberState extends State<ChangePhoneNumberScreen> {

  String _changedPhoneValidationMessage;
  TextEditingController _changedPhoneNumberCtr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopupScreen(
      subtitle: 'Change Phone Number',
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 175.0,
              ),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixText: '+266-',
                    ),
                    textAlign: TextAlign.start,
                    controller: _changedPhoneNumberCtr,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                      LesothoPhoneNumberTextInputFormatter(),
                    ],
                    validator: validatePhoneNumber,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            _changedPhoneValidationMessage == null ? SizedBox() : Text(_changedPhoneValidationMessage),
            SizedBox(height: 10.0),
            PEBRAButtonRaised(
              'Save',
              onPressed: () {
                setState(() {
                  _changedPhoneValidationMessage = validatePhoneNumber(_changedPhoneNumberCtr.text);
                });
                final String _newPhone = '+266-${_changedPhoneNumberCtr.text}';
                if (_changedPhoneValidationMessage == null) {
                  Navigator.of(context).pop(_newPhone);
                }
              },
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}