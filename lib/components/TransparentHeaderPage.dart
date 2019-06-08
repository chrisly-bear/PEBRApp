import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

class TransparentHeaderPage extends StatelessWidget {
  final String title, subtitle;
  final List<Widget> actions;
  final Widget child;
  final Color color;
  final bool blurEnabled;
  final bool elevationEnabled;
  final bool safeArea;

  double _headerHeight = Platform.isIOS ? 82.0 : 80.0;
  static const double _BLUR_RADIUS = 5.0;

  TransparentHeaderPage({@required this.child, this.title, this.subtitle,
    this.actions, this.color: Colors.transparent, this.blurEnabled: true,
    this.elevationEnabled: false, this.safeArea: true}) {
    if (title == null) {
      _headerHeight -= 25;
    }
    else if (subtitle == null) {
      _headerHeight -= 25;
    }
    if (!safeArea) {
      _headerHeight += 10;
    }
  }

  Widget get _background {
    return SingleChildScrollView(
      child: SafeArea(
        right: false,
        left: false,
        bottom: false,
        top: safeArea,
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
      decoration: BoxDecoration(color: color, boxShadow: elevationEnabled ? [BoxShadow(color: Colors.grey, spreadRadius: 10.0, blurRadius: 5.0)] : null),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurEnabled ? _BLUR_RADIUS : 0, sigmaY: blurEnabled ? _BLUR_RADIUS : 0),
          child: SafeArea(
            right: false,
            left: false,
            bottom: false,
            top: safeArea,
            child: Container(
              height: _headerHeight,
              child: Padding(
                padding: EdgeInsets.only(left: 10.0, right: 0.0, bottom: 10.0, top: safeArea ? 0.0 : 10.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: _buildTitleAndSubtitle(title, subtitle)),
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
      return Container();
    }
    if (title == null) {
      // title is null, subtitle isn't
      return _formatSubtitle(subtitle);
    } else if (subtitle == null) {
      // subtitle is null, title isn't
      return _formatTitle(title);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _formatTitle(title),
        _formatSubtitle(subtitle),
      ],
    );
  }

  _formatTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      overflow: TextOverflow.fade,
      softWrap: false,
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
      overflow: TextOverflow.fade,
      softWrap: false,
    );
  }
}
