
import 'package:flutter/material.dart';
import 'package:pebrapp/components/PopupScreen.dart';
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
          _makeExplanation('assets/icons/nurse_clinic_fett.png', SupportPreferencesSelection.NURSE_CLINIC_DESCRIPTION),
          _makeExplanation('assets/icons/saturday_clinic_club_fett.png', SupportPreferencesSelection.SATURDAY_CLINIC_CLUB_DESCRIPTION),
          _makeExplanation('assets/icons/youth_club_fett.png', SupportPreferencesSelection.COMMUNITY_YOUTH_CLUB_DESCRIPTION),
          _makeExplanation('assets/icons/phonecall_pe_fett.png', SupportPreferencesSelection.PHONE_CALL_PE_DESCRIPTION),
          _makeExplanation('assets/icons/homevisit_pe_fett.png', SupportPreferencesSelection.HOME_VISIT_PE_DESCRIPTION),
          _makeExplanation('assets/icons/schooltalk_pe_fett.png', SupportPreferencesSelection.SCHOOL_VISIT_PE_DESCRIPTION),
          _makeExplanation('assets/icons/pitso_fett.png', SupportPreferencesSelection.PITSO_VISIT_PE_DESCRIPTION),
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
