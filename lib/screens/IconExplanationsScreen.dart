import 'package:flutter/material.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/config/PEBRAConfig.dart';
import 'package:pebrapp/database/beans/SupportOption.dart';

class IconExplanationsScreen extends StatefulWidget {
  @override
  createState() => _IconExplanationsScreenState();
}

class _IconExplanationsScreenState extends State<IconExplanationsScreen> {
  @override
  Widget build(BuildContext context) {
    return PopupScreen(
      title: 'Icon Explanations',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _makeExplanation('assets/icons/nurse_clinic.png',
              SupportOption.NURSE_CLINIC().description),
          _makeExplanation('assets/icons/saturday_clinic_club.png',
              SupportOption.SATURDAY_CLINIC_CLUB().description),
          _makeExplanation('assets/icons/youth_club.png',
              SupportOption.COMMUNITY_YOUTH_CLUB().description),
          _makeExplanation('assets/icons/phonecall_pe.png',
              SupportOption.PHONE_CALL_PE().description),
          _makeExplanation('assets/icons/homevisit_pe.png',
              SupportOption.HOME_VISIT_PE().description),
          _makeExplanation('assets/icons/schooltalk_pe.png',
              SupportOption.SCHOOL_VISIT_PE().description),
          _makeExplanation('assets/icons/pitso.png',
              SupportOption.PITSO_VISIT_PE().description),
          _makeExplanation('assets/icons/viralload_suppressed.png',
              'Suppressed (viral load < $VL_SUPPRESSED_THRESHOLD copies/mL)'),
          _makeExplanation('assets/icons/viralload_unsuppressed.png',
              'Unsuppressed (viral load missing or ≥ $VL_SUPPRESSED_THRESHOLD copies/mL)'),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Padding _makeExplanation(String iconAsset, String explanation) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        child: Row(
          children: [
            Image.asset(
              iconAsset,
              height: 30,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                explanation,
                maxLines: 9, // may have as many lines as necessary
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ));
  }
}
