import 'package:flutter/material.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/RequiredAction.dart';
import 'package:pebrapp/state/PatientBloc.dart';
import 'package:pebrapp/utils/AppColors.dart';
import 'package:pebrapp/utils/VisibleImpactUtils.dart';

enum AnimateDirection { FORWARD, BACKWARD }

class RequiredActionContainerPEPhoneNumberUpload extends StatefulWidget {
  final AnimateDirection animateDirection;
  final VoidCallback onAnimated;
  final String phoneNumber;

  RequiredActionContainerPEPhoneNumberUpload(this.phoneNumber,
      {this.animateDirection, this.onAnimated});

  @override
  State<StatefulWidget> createState() =>
      _RequiredActionContainerPEPhoneNumberUploadState();
}

class _RequiredActionContainerPEPhoneNumberUploadState
    extends State<RequiredActionContainerPEPhoneNumberUpload>
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
  void didUpdateWidget(RequiredActionContainerPEPhoneNumberUpload oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    String actionText =
        "The automatic upload of your phone number failed. Please upload manually.";
    Widget actionButton = FlatButton(
      onPressed: () async {
        await uploadPeerEducatorPhoneNumber();
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

    return SizeTransition(
      sizeFactor: _containerAnimation,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 15.0),
          clipBehavior: Clip.antiAlias,
          child: Container(
            color: NOTIFICATION_NORMAL,
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                SizedBox(height: 20.0),
                Container(
                  width: double.infinity,
                  child: Text(
                    actionText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: NOTIFICATION_MESSAGE_TEXT,
                      height: 1.2,
                    ),
                  ),
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
