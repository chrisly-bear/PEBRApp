import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pebrapp/utils/AppColors.dart';

class TransparentHeaderPage extends StatelessWidget {
  final String title, subtitle;
  final List<Widget> actions;
  final Widget child;
  final Color color;
  final bool blurEnabled;
  final bool elevationEnabled;
  final bool safeArea;
  final bool scrollable;

  double _headerHeight = Platform.isIOS ? 82.0 : 80.0;
  static const double _BLUR_RADIUS = 5.0;

  /// Page with a header and content.
  ///
  /// If [title], [subtitle] are null and [actions] is null or empty, the header
  /// disappears and only the content is displayed.
  ///
  /// @param [child] The content that should be displayed in the popup window.
  ///
  /// @param [title] The title to be displayed in the header.
  ///
  /// @param [subtitle] The subtitle to be displayed in the header.
  ///
  /// @param [actions] The buttons to be displayed on the right hand side of the
  /// header.
  ///
  /// @param [color] A custom color to use for the header. Default is
  /// transparent.
  ///
  /// @param [blurEnabled] If the header should blur the content as it scrolls
  /// underneath it.
  ///
  /// @param [elevationEnabled] If true, there will be a drop shadow underneath
  /// the header which separates it from the content ([child]). NOTE: If no
  /// [color] is provided the header will become grey.
  ///
  /// @param [safeArea] Set to true if the title, subtitle, actions, and content
  /// should be rendered within the safe area bounds.
  ///
  /// @param [scrollable] If set to true the content behind the transparent
  /// header can be scrolled. This is useful for small devices and/or content
  /// with large heights. Defaults to true.
  TransparentHeaderPage(
      {@required this.child,
      this.title,
      this.subtitle,
      this.actions,
      this.color: Colors.transparent,
      this.blurEnabled: true,
      this.elevationEnabled: false,
      this.safeArea: true,
      this.scrollable: true}) {
    if (title == null) {
      _headerHeight -= 25;
    } else if (subtitle == null) {
      _headerHeight -= 25;
    }
    if (!safeArea) {
      // if SafeArea is disabled compensate for the zero-padding at the top of
      // the title
      _headerHeight += 10;
    }
    if (title == null && subtitle == null && (actions?.length ?? 0) == 0) {
      _headerHeight = 0;
    }
  }

  Widget get _background {
    // padding until bottom of header
    final double paddingUntilBottomOfHeader = _headerHeight;
    // padding to avoid Gaussian blur,
    // only required if we have a header and either blurring is enabled
    // or a shadow is displayed
    final double paddingToAvoidBlur =
        (_headerHeight != 0 && (blurEnabled || elevationEnabled))
            ? (Platform.isIOS ? 10.0 : 12.0)
            : 0;

    final Widget content = SafeArea(
      right: safeArea,
      left: safeArea,
      bottom: safeArea,
      top: safeArea,
      child: Padding(
        padding: EdgeInsets.only(
            top: paddingUntilBottomOfHeader + paddingToAvoidBlur),
        child: child,
      ),
    );

    return scrollable ? SingleChildScrollView(child: content) : content;
  }

  Widget get _foreground {
    final Widget _actionBar = actions == null
        ? Container()
        : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions,
          );

    return Container(
      decoration: BoxDecoration(
          color: color,
          boxShadow: elevationEnabled
              ? [
                  BoxShadow(
                      color: HEADER_DROPSHADOW,
                      spreadRadius: 10.0,
                      blurRadius: 5.0)
                ]
              : null),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: blurEnabled ? _BLUR_RADIUS : 0,
              sigmaY: blurEnabled ? _BLUR_RADIUS : 0),
          child: SafeArea(
            right: safeArea,
            left: safeArea,
            bottom: false,
            top: safeArea,
            child: Container(
              height: _headerHeight,
              child: Padding(
                padding: EdgeInsets.only(
                    left: 10.0,
                    right: 0.0,
                    bottom: 10.0,
                    top: safeArea ? 0.0 : 10.0),
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
        color: HEADER_TITLE,
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
        color: HEADER_SUBTITLE,
      ),
      overflow: TextOverflow.fade,
      softWrap: false,
    );
  }
}
