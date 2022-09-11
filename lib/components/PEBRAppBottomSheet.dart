import 'package:flutter/material.dart';
import 'package:pebrapp/config/VisibleImpactConfig.dart';
import 'package:pebrapp/utils/AppColors.dart';

class PEBRAppBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (VI_API != VI_API_TEST) {
      return null;
    }
    return BottomSheet(
      onClosing: () {},
      backgroundColor: BOTTOM_SHEET,
      enableDrag: false,
      builder: (context) {
        return Container(
          height: 20.0,
          width: double.infinity,
          child: Center(
              child: Text(
            'DEMO VERSION',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 12.0),
          )),
        );
      },
    );
  }
}
