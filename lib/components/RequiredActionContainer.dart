import 'package:flutter/material.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/VisibleImpactUtils.dart';
import 'package:pebrapp/utils/Utils.dart';

enum AnimateDirection { FORWARD, BACKWARD }

class RequiredActionContainer extends StatefulWidget {
  final RequiredAction action;
  final int actionNumber;
  final Patient patient;
  final AnimateDirection animateDirection;
  final VoidCallback onAnimated;

  RequiredActionContainer(this.action, this.actionNumber, this.patient,
      {this.animateDirection, this.onAnimated});

  @override
  State<StatefulWidget> createState() => _RequiredActionContainerState();
}

class _RequiredActionContainerState extends State<RequiredActionContainer>
    with SingleTickerProviderStateMixin {
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
    ).chain(CurveTween(curve: _curve)).animate(_controller);

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
      _controller
          .animateBack(0.0,
              duration: Duration(milliseconds: 1000), curve: Curves.ease)
          .then((_) {
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

  FlatButton _doneButton(RequiredAction action) {
    return FlatButton(
      onPressed: () async {
        DatabaseProvider()
            .removeRequiredAction(widget.patient.artNumber, action.type);
        PatientBloc.instance.sinkRequiredActionData(action, true);
      },
      splashColor: NOTIFICATION_INFO_SPLASH,
      child: Text(
        "DONE",
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
        actionText =
            "Preference assessment required. Start a preference assessment by tapping 'Start Assessment' below.";
        break;
      case RequiredActionType.REFILL_REQUIRED:
        actionText =
            "ART refill required. Start an ART refill by tapping 'Manage Refill' below.";
        break;
      case RequiredActionType.NOTIFICATIONS_UPLOAD_REQUIRED:
        actionText =
            "The automatic upload of the notifications failed. Please upload manually.";
        actionButton = FlatButton(
          onPressed: () async {
            await uploadNotificationsPreferences(widget.patient);
          },
          splashColor: NOTIFICATION_INFO_SPLASH,
          child: Text(
            "UPLOAD",
            style: TextStyle(
              color: NOTIFICATION_INFO_TEXT,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        break;
      case RequiredActionType.PATIENT_CHARACTERISTICS_UPLOAD_REQUIRED:
        actionText =
            "The automatic upload of the participant's characteristics failed. Please upload manually.";
        actionButton = FlatButton(
          onPressed: () async {
            await uploadPatientCharacteristics(widget.patient,
                reUploadNotifications: false);
          },
          splashColor: NOTIFICATION_INFO_SPLASH,
          child: Text(
            "UPLOAD",
            style: TextStyle(
              color: NOTIFICATION_INFO_TEXT,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        break;
      case RequiredActionType.PATIENT_STATUS_UPLOAD_REQUIRED:
        actionText =
            "The automatic upload of the participant's status failed. Please upload manually.";
        actionButton = FlatButton(
          onPressed: () async {
            String status = getPatientStatus(
                widget.patient.latestARTRefill.notDoneReason.code);
            await uploadPatientStatusVisibleImpact(widget.patient, status,
                reUploadNotifications: false);
          },
          splashColor: NOTIFICATION_INFO_SPLASH,
          child: Text(
            "UPLOAD",
            style: TextStyle(
              color: NOTIFICATION_INFO_TEXT,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        break;
      case RequiredActionType.VIRAL_LOAD_MEASUREMENT_REQUIRED:
        actionText =
            "Viral load required. Please send the participant to the nurse for blood draw.";
        actionButton = _doneButton(widget.action);
        break;
      case RequiredActionType.VIRAL_LOAD_DISCREPANCY_WARNING:
        actionText =
            "Viral load discrepancy found. Please inform the study supervisor.";
        actionButton = _doneButton(widget.action);
        break;
      case RequiredActionType.VIRAL_LOAD_9M_REQUIRED:
        actionText =
            "The participant needs a viral load within the next few months. Please coordinate with the nurse for blood draw.";
        actionButton = _doneButton(widget.action);
        break;
      case RequiredActionType.QUALITY_OF_LIFE_QUESTIONNAIRE_5M_REQUIRED:
        actionText =
            "Fill in the Quality of Life questionnaire on KoBoCollect.";
        actionButton = _doneButton(widget.action);
        break;
      case RequiredActionType.QUALITY_OF_LIFE_QUESTIONNAIRE_9M_REQUIRED:
        actionText =
            "Fill in the Quality of Life questionnaire on KoBoCollect.";
        actionButton = _doneButton(widget.action);
        break;
      case RequiredActionType.ADHERENCE_QUESTIONNAIRE_2P5M_REQUIRED:
        actionText = "Fill in the Adherence questionnaire on KoBoCollect.";
        actionButton = _doneButton(widget.action);
        break;
      case RequiredActionType.ADHERENCE_QUESTIONNAIRE_5M_REQUIRED:
        actionText = "Fill in the Adherence questionnaire on KoBoCollect.";
        actionButton = _doneButton(widget.action);
        break;
      case RequiredActionType.ADHERENCE_QUESTIONNAIRE_9M_REQUIRED:
        actionText = "Fill in the Adherence questionnaire on KoBoCollect.";
        actionButton = _doneButton(widget.action);
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
                          tag:
                              "RequiredAction_${widget.patient.artNumber}_${widget.actionNumber}",
                          child: Container(
                            width: badgeSize,
                            height: badgeSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: Center(
                              child: Text(
                                '${widget.actionNumber + 1}',
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
