import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pebrapp/components/TransparentHeaderPage.dart';
import 'package:pebrapp/utils/AppColors.dart';

class PopupScreen extends StatelessWidget {
  final Widget child;
  final String title, subtitle;
  final List<Widget> actions;
  final double backgroundBlur;

  // define the maximum width of the popup screen
  static const double MAX_WIDTH = 600;
  static const double MIN_PADDING = 20;
  double screenWidth;
  double padding;

  /// Popup window with a header and content.
  ///
  /// If [actions] is null then a close button is displayed by default.
  ///
  /// If [title], [subtitle] are null and [actions] is empty, the header
  /// disappears and only the content is displayed.
  ///
  /// @param [child] The content that should be displayed in the popup window.
  ///
  /// @param [title] The title to be displayed in the header.
  ///
  /// @param [subtitle] The subtitle to be displayed in the header.
  ///
  /// @param [actions] The buttons to be displayed on the right hand side of the
  /// header. If it is null, a close button is displayed by default. If
  /// no buttons should be displayed, pass an empty list (`[]`).
  ///
  /// @param [backgroundBlur] The amount with which the content behind the popup
  /// screen should be blurred.
  PopupScreen({@required this.child, this.title, this.subtitle, this.actions,
  this.backgroundBlur: 0.0});

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    padding = max(MIN_PADDING, (screenWidth - MAX_WIDTH)/2);

    return Scaffold(
      backgroundColor: POPUP_BEHIND,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: backgroundBlur, sigmaY: backgroundBlur),
        child: SafeArea(
          child: Center(
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 10.0,
              margin: EdgeInsets.symmetric(horizontal: padding, vertical: MIN_PADDING),
              color: BACKGROUND_COLOR,
//              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0), side: BorderSide(color: Colors.black)),
              child: TransparentHeaderPage(
                safeArea: false,
                title: title,
                subtitle: subtitle,
                child: child,
                actions: actions ?? [
                  IconButton(
                    alignment: Alignment.topCenter,
//                    padding: EdgeInsets.all(0.0),
                    icon: Icon(Icons.close),
                    onPressed: Navigator.of(context).pop,
                  ),
                ],
                color: BACKGROUND_COLOR,
                blurEnabled: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
