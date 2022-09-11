import 'package:flutter/material.dart';
import 'package:pebrapp/utils/AppColors.dart';

class PEBRAButtonFlat extends StatelessWidget {
  final String _buttonText;
  final onPressed;
  final Widget widget;
  final double minWidth;
  final double maxWidth;

  /// If `onPressed` is null then the button is painted gray to show that it's
  /// deactivated. If a `widget` is passed, the `_buttonText` is ignored and the
  /// `widget` is displayed instead.
  const PEBRAButtonFlat(this._buttonText,
      {this.onPressed, this.widget, this.minWidth, this.maxWidth})
      : super();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? double.infinity,
        minWidth: minWidth ?? 0.0,
        minHeight: 40,
      ),
      child: FlatButton(
        onPressed: this.onPressed,
        child: widget != null
            ? widget
            : Text(
                this._buttonText.toUpperCase(),
                style: TextStyle(
                  color: this.onPressed == null ? BUTTON_INACTIVE : FLAT_BUTTON,
                ),
              ),
      ),
    );
  }
}
