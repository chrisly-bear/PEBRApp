import 'package:flutter/material.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';
import 'package:pebrapp/utils/AppColors.dart';

class ViralLoadBadge extends StatelessWidget {
  final ViralLoad viralLoad;
  final bool smallSize;

  const ViralLoadBadge(this.viralLoad, {this.smallSize = false}) : super();

  @override
  Widget build(BuildContext context) {
    String displayText;
    Color displayColor;
    if (viralLoad.isSuppressed) {
      displayText = smallSize ? "S" : "SUPPRESSED";
      displayColor = VL_BADGE_SUPPRESSED;
    } else {
      displayText = smallSize ? "U" : "UNSUPPRESSED";
      displayColor = VL_BADGE_UNSUPPRESSED;
    }
    return Card(
      color: displayColor,
      child: Padding(
        padding: EdgeInsets.all(3.0),
        child: Container(
          constraints: BoxConstraints(
            minWidth: 40,
            maxWidth: smallSize ? 40 : double.infinity,
            minHeight: 25,
            maxHeight: 25,
          ),
          child: Center(
            child: Text(
              displayText.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: VL_BADGE_TEXT,
                // fontSize: 16.0,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
