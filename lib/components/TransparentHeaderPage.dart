import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

class TransparentHeaderPage extends StatelessWidget {
  final String title, subtitle;
  final List<Widget> actions;
  final Widget child;

  double _headerHeight = Platform.isIOS ? 82.0 : 80.0;
  static const double _BLUR_RADIUS = 5.0;

  TransparentHeaderPage({@required this.title, this.subtitle, this.actions, @required this.child}) {
    if (subtitle == null) {
      _headerHeight -= 30;
    }
  }

  Widget get _background {
    return SingleChildScrollView(
      child: SafeArea(
        right: false,
        left: false,
        bottom: false,
        top: true,
        child: Column(
          children: [
            // padding until bottom of header
            Container(height: _headerHeight),
            // padding to avoid Gaussian blur
            Container(height: Platform.isIOS ? 10.0 : 12.0),
            child,
          ],
        ),
      ),
    );
  }

  Widget get _foreground {

    final Widget _actionBar = actions == null ? Container() : Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions,
    );

    return Container(
//      color: Colors.black.withOpacity(0.2),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _BLUR_RADIUS, sigmaY: _BLUR_RADIUS),
          child: SafeArea(
            right: false,
            left: false,
            bottom: false,
            top: true,
            child: Container(
              height: _headerHeight,
              child: Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildTitleAndSubtitle(title, subtitle),
                      _actionBar,
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _background, // body
        _foreground, // header
      ],
    );
  }

  _buildTitleAndSubtitle(String title, String subtitle) {
    if (title == null && subtitle == null) {
      return null;
    }

    if (title != null) {
      if (subtitle != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _formatTitle(title),
            _formatSubtitle(subtitle),
          ],
        );
      } else {
        return _formatTitle(title);
      }
    }
  }

  _formatTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  _formatSubtitle(String subtitle) {
    return Text(
      subtitle,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}
