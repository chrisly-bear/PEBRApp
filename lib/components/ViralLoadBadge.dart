import 'package:flutter/material.dart';
import 'package:pebrapp/database/models/ViralLoad.dart';

class ViralLoadBadge extends StatelessWidget {
  final ViralLoad viralLoad;
  final bool smallSize;

  const ViralLoadBadge(this.viralLoad, {this.smallSize = false}) : super();

  @override
  Widget build(BuildContext context) {
    String displayText;
    Color displayColor;
    if (viralLoad.isLowerThanDetectable) {
      displayText = "LTDL";
      displayColor = Colors.grey;
    } else if (viralLoad.isSuppressed) {
      displayText = smallSize ? "S" : "SUPPRESSED";
      displayColor = Color.fromARGB(255, 36, 179, 124);
    } else {
      displayText = smallSize ? "U" : "UNSUPPRESSED";
      displayColor = Color.fromARGB(255, 255, 51, 102);
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
                color: Colors.white,
  //              fontSize: 16.0,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
