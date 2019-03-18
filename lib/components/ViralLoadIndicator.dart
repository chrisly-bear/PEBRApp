import 'package:flutter/material.dart';

class ViralLoadIndicator extends StatelessWidget {
  final ViralLoad viralLoad;
  final bool smallSize;

  const ViralLoadIndicator(this.viralLoad, {this.smallSize}) : super();

  @override
  Widget build(BuildContext context) {
    String displayText;
    Color displayColor;
    switch (viralLoad) {
      case ViralLoad.SUPPRESSED:
        displayText = smallSize ? "S" : "SUPPRESSED";
        displayColor = Color.fromARGB(255, 36, 179, 124);
        break;
      case ViralLoad.UNSUPPRESSED:
        displayText = smallSize ? "U" : "UNSUPPRESSED";
        displayColor = Color.fromARGB(255, 255, 51, 102);
        break;
      case ViralLoad.NA:
        displayText = "N/A";
        displayColor = Colors.grey;
        break;
      default:
        displayText = "N/A";
        displayColor = Colors.grey;
        break;
    }
    return Card(
      color: displayColor,
      child: Padding(
        padding: EdgeInsets.all(3.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 25,
            maxWidth: 25,
          ),
          child: Text(
            displayText.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
//              fontSize: 16.0,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

enum ViralLoad { SUPPRESSED, UNSUPPRESSED, NA }
