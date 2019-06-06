import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

class TransparentHeaderPage extends StatelessWidget {
  String _title, _subtitle;
  List<Widget> _actions;
  Widget _child;

  static final double _headerHeight = Platform.isIOS ? 82.0 : 80.0;
  static const double _BLUR_RADIUS = 10.0;

  TransparentHeaderPage({String title, String subtitle, List<Widget> actions, @required Widget child}) {
    this._title = title;
    this._subtitle = subtitle;
    this._actions = actions;
    this._child = child;
  }

  Widget get _background {
    return SafeArea(
      right: false,
      left: false,
      bottom: false,
      top: true,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // padding until bottom of header
            Container(height: _headerHeight),
            // padding to avoid Gaussian blur
            Container(height: Platform.isIOS ? 20.0 : 22.0),
            _child,
          ],
        ),
      ),
    );
  }

  Widget get _foreground {

    final Widget _actionBar = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: _actions,
    );

    return SafeArea(
      right: false,
      left: false,
      bottom: false,
      top: true,
      child: Container(
        height: _headerHeight,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: _BLUR_RADIUS, sigmaY: _BLUR_RADIUS),
            child: Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildTitleAndSubtitle(_title, _subtitle),
                    _actionBar,
                  ]),
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
