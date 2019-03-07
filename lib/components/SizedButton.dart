import 'package:flutter/material.dart';

class SizedButton extends StatelessWidget {

  final String _buttonText;
  final onPressed;

  SizedButton(this._buttonText, { this.onPressed });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 300,
        minWidth: 150,
        minHeight: 40,
      ),
      child: RaisedButton(
        onPressed: this.onPressed,
        color: Color.fromRGBO(37, 55, 208, 1.0),
        child: Text(
          _buttonText.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
