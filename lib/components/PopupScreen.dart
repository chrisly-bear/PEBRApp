import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pebrapp/components/TransparentHeaderPage.dart';

class PopupScreen extends StatelessWidget {
  final Widget child;
  final String title, subtitle;

  // define the maximum width of the popup screen
  static const double MAX_WIDTH = 600;
  static const double MIN_PADDING = 20;
  double screenWidth;
  double padding;

  PopupScreen({@required this.child, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    padding = max(MIN_PADDING, (screenWidth - MAX_WIDTH)/2);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.50),
      body: SafeArea(
        child: Center(
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 10.0,
            margin: EdgeInsets.symmetric(horizontal: padding, vertical: MIN_PADDING),
            color: Color.fromARGB(255, 224, 224, 224),
//          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0), side: BorderSide(color: Colors.black)),
            child: TransparentHeaderPage(
              safeArea: false,
              title: title,
              subtitle: subtitle,
              child: child,
              actions: <Widget>[
                IconButton(
                  alignment: Alignment.topCenter,
//                padding: EdgeInsets.all(0.0),
                  icon: Icon(Icons.close),
                  onPressed: Navigator.of(context).pop,
                ),
              ],
              color: Color.fromARGB(255, 224, 224, 224),
              blurEnabled: false,
            ),
          ),
        ),
      ),
    );
  }
}
