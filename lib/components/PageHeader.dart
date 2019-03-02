import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  String _title, _subtitle;

  PageHeader({String title, String subtitle}) {
    this._title = title;
    this._subtitle = subtitle;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: _buildTitleAndSubtitle(_title, _subtitle)),
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
