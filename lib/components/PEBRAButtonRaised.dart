import 'package:flutter/material.dart';
import 'package:pebrapp/utils/AppColors.dart';

class PEBRAButtonRaised extends StatelessWidget {
  final String _buttonText;
  final onPressed;
  final Widget widget;
  final Color color;
  final double minWidth;
  final double maxWidth;

  /// If `onPressed` is null then the button is painted gray to show that it's
  /// deactivated. If a `widget` is passed, the `_buttonText` is ignored and the
  /// `widget` is displayed instead. Pass a [color] to override the default blue
  /// background color of the button.
  const PEBRAButtonRaised(this._buttonText,
      {this.onPressed, this.widget, this.color, this.minWidth, this.maxWidth})
      : super();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? double.infinity,
        minWidth: minWidth ?? 0.0,
        minHeight: 40,
      ),
      child: RaisedButton(
        onPressed: this.onPressed,
        color: color ?? RAISED_BUTTON,
        child: widget != null
            ? widget
            : Text(
                this._buttonText.toUpperCase(),
                style: TextStyle(
                  color: RAISED_BUTTON_TEXT,
                ),
              ),
      ),
    );
  }
}
