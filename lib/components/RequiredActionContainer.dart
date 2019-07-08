import 'package:flutter/material.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/VisibleImpactUtils.dart';

enum AnimateDirection { FORWARD, BACKWARD }

class RequiredActionContainer extends StatefulWidget {

  final RequiredAction action;
  final int actionNumber;
  final Patient patient;
  final AnimateDirection animateDirection;
  final VoidCallback onAnimated;

  RequiredActionContainer(this.action, this.actionNumber, this.patient, {this.animateDirection, this.onAnimated});

  @override
  State<StatefulWidget> createState() => _RequiredActionContainerState();

}

class _RequiredActionContainerState extends State<RequiredActionContainer> with SingleTickerProviderStateMixin {

  AnimationController _controller;
  Animation<double> _containerAnimation;
  Curve _curve = Curves.ease;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _containerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).chain(
        CurveTween(curve: _curve)
    ).animate(_controller);

    _animateIfDemanded();
    super.initState();
  }

  @override
  void didUpdateWidget(RequiredActionContainer oldWidget) {
    _animateIfDemanded();
    super.didUpdateWidget(oldWidget);
  }

  void _animateIfDemanded() {
    if (widget.animateDirection == null) {
      // do not animate and initialize animation to its end state
      _controller.value = _controller.upperBound;
    } else if (widget.animateDirection == AnimateDirection.FORWARD) {
      _controller.reset();
      _controller.forward().then((_) {
        if (widget.onAnimated != null) {
          widget.onAnimated();
        }
      });
    } else if (widget.animateDirection == AnimateDirection.BACKWARD) {
      _controller.value = _controller.upperBound;
      _controller.animateBack(0.0, duration: Duration(milliseconds: 1000), curve: Curves.ease).then((_) {
        if (widget.onAnimated != null) {
          widget.onAnimated();
        }
      });
    }
  }

  dispose() {
    _controller.dispose();
    super.dispose();
  }

  FlatButton _endpointSurveyDoneButton(RequiredAction action) {
    return FlatButton(
      onPressed: () async {
        await DatabaseProvider().removeRequiredAction(widget.patient.artNumber, action.type);
        PatientBloc.instance.sinkRequiredActionData(action, true);
      },
      splashColor: NOTIFICATION_INFO_SPLASH,
      child: Text(
        "ENDPOINT SURVEY COMPLETED",
        style: TextStyle(
          color: NOTIFICATION_INFO_TEXT,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String actionText;
    Widget actionButton;
    switch (widget.action.type) {
      case RequiredActionType.ASSESSMENT_REQUIRED:
        actionText = "Preference assessment required. Start a preference assessment by tapping 'Start Assessment' below.";
        break;
      case RequiredActionType.REFILL_REQUIRED:
        actionText = "ART refill required. Start an ART refill by tapping 'Manage Refill' below.";
        break;
      case RequiredActionType.ENDPOINT_3M_SURVEY_REQUIRED:
        actionText = "3 month endpoint survey required. Start an endpoint survey by tapping 'Open KoBoCollect' below.";
        actionButton = _endpointSurveyDoneButton(widget.action);
        break;
      case RequiredActionType.ENDPOINT_6M_SURVEY_REQUIRED:
        actionText = "6 month endpoint survey required. Start an endpoint survey by tapping 'Open KoBoCollect' below.";
        actionButton = _endpointSurveyDoneButton(widget.action);
        break;
      case RequiredActionType.ENDPOINT_12M_SURVEY_REQUIRED:
        actionText = "12 month endpoint survey required. Start an endpoint survey by tapping 'Open KoBoCollect' below.";
        actionButton = _endpointSurveyDoneButton(widget.action);
        break;
      case RequiredActionType.NOTIFICATIONS_UPLOAD_REQUIRED:
        actionText = "The automatic synchronization of the notifications preferences with the database failed. Please synchronize manually.";
        actionButton = FlatButton(
          onPressed: () async {
            await uploadNotificationsPreferences(widget.patient, widget.patient.latestPreferenceAssessment);
          },
          splashColor: NOTIFICATION_INFO_SPLASH,
          child: Text(
            "SYNCHRONIZE",
            style: TextStyle(
              color: NOTIFICATION_INFO_TEXT,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        break;
      case RequiredActionType.ART_REFILL_DATE_UPLOAD_REQUIRED:
        actionText = "The automatic synchronization of the ART refill date with the database failed. Please synchronize manually.";
        actionButton = FlatButton(
          onPressed: () async {
            await uploadNextARTRefillDate(widget.patient, widget.patient.latestARTRefill.nextRefillDate);
          },
          splashColor: NOTIFICATION_INFO_SPLASH,
          child: Text(
            "SYNCHRONIZE",
            style: TextStyle(
              color: NOTIFICATION_INFO_TEXT,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        break;
      case RequiredActionType.PATIENT_PHONE_UPLOAD_REQUIRED:
        actionText = "The automatic synchronization of the patient's phone number with the database failed. Please synchronize manually.";
        actionButton = FlatButton(
          onPressed: () async {
            await uploadPatientPhoneNumber(widget.patient, widget.patient.phoneNumber);
          },
          splashColor: NOTIFICATION_INFO_SPLASH,
          child: Text(
            "SYNCHRONIZE",
            style: TextStyle(
              color: NOTIFICATION_INFO_TEXT,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        break;
    }

    final double badgeSize = 30.0;
    return SizeTransition(
      sizeFactor: _containerAnimation,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 15.0),
          elevation: 5.0,
          clipBehavior: Clip.antiAlias,
          child: Container(
            color: NOTIFICATION_NORMAL,
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                SizedBox(height: 20.0),
                Container(
                  width: double.infinity,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Hero(
                          tag: "RequiredAction_${widget.patient.artNumber}_${widget.actionNumber}",
                          child: Container(
                            width: badgeSize,
                            height: badgeSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: Center(
                              child: Text(
                                '${widget.actionNumber+1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Roboto',
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            actionText,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: NOTIFICATION_MESSAGE_TEXT,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ]),
                ),
                actionButton ?? SizedBox(height: 15.0),
                SizedBox(height: 5.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
