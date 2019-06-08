import 'package:flutter/material.dart';
import 'package:pebrapp/components/TransparentHeaderPage.dart';

class PopupScreen extends StatelessWidget {
  final Widget child;
  final String title, subtitle;

  PopupScreen({@required this.child, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.50),
      body: Center(
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 10.0,
          // TODO: set padding so that the popup has a minimum width and height (see flushbar on how to do it)
          margin: EdgeInsets.symmetric(horizontal: 50.0, vertical: 200.0),
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
    );
  }
}
