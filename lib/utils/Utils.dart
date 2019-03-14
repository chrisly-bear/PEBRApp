import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';

void showFlushBar(BuildContext context, String message, {String title}) {
  Flushbar()
    ..title = title
    ..messageText = Text(message, textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 18.0))
    ..duration = Duration(seconds: 5)
    ..show(context);
}
