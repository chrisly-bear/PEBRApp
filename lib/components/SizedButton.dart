import 'package:flutter/material.dart';

class SizedButton extends StatelessWidget {

  final String _buttonText;
  final onPressed;
  final Widget widget;

  /// If `onPressed` is null then the button is painted gray to show that it's
  /// deactivated. If a `widget` is passed, the `_buttonText` is ignored and the
  /// `widget` is displayed instead.
  const SizedButton(this._buttonText, {this.onPressed, this.widget}) : super();

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
        child: widget != null ? widget : Text(
          this._buttonText.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
