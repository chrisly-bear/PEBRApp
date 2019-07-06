
import 'package:flutter/material.dart';
import 'package:pebrapp/components/PopupScreen.dart';
import 'package:pebrapp/config/PEBRAConfig.dart';
import 'package:pebrapp/database/beans/SupportPreferencesSelection.dart';

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
          _makeExplanation('assets/icons/nurse_clinic.png', SupportPreferencesSelection.NURSE_CLINIC_DESCRIPTION),
          _makeExplanation('assets/icons/saturday_clinic_club.png', SupportPreferencesSelection.SATURDAY_CLINIC_CLUB_DESCRIPTION),
          _makeExplanation('assets/icons/youth_club.png', SupportPreferencesSelection.COMMUNITY_YOUTH_CLUB_DESCRIPTION),
          _makeExplanation('assets/icons/phonecall_pe.png', SupportPreferencesSelection.PHONE_CALL_PE_DESCRIPTION),
          _makeExplanation('assets/icons/homevisit_pe.png', SupportPreferencesSelection.HOME_VISIT_PE_DESCRIPTION),
          _makeExplanation('assets/icons/schooltalk_pe.png', SupportPreferencesSelection.SCHOOL_VISIT_PE_DESCRIPTION),
          _makeExplanation('assets/icons/pitso.png', SupportPreferencesSelection.PITSO_VISIT_PE_DESCRIPTION),
          _makeExplanation('assets/icons/viralload_suppressed.png', 'Suppressed (viral load < $VL_SUPPRESSED_THRESHOLD copies/mL)'),
          _makeExplanation('assets/icons/viralload_unsuppressed.png', 'Unsuppressed (viral load missing or ≥ $VL_SUPPRESSED_THRESHOLD copies/mL)'),
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
        )
    );
  }

}
