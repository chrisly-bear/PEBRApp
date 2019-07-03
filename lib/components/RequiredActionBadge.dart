import 'package:flutter/material.dart';

class RequiredActionBadge extends StatefulWidget {

  final String text;
  final double badgeSize = 30.0;
  final double textSize = 16.0;
  final bool animate;

  RequiredActionBadge(this.text, {this.animate: false});

  @override
  State<StatefulWidget> createState() => _RequiredActionBadgeState();

}

class _RequiredActionBadgeState extends State<RequiredActionBadge> with SingleTickerProviderStateMixin {

  AnimationController _controller;
  Animation<double> _containerAnimation;
  Animation<double> _textAnimation;
  Curve _curve = Curves.elasticOut;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _containerAnimation = Tween<double>(
      begin: 0.0,
      end: widget.badgeSize,
    ).chain(
        CurveTween(curve: _curve)
    ).animate(_controller);

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: widget.textSize,
    ).chain(
        CurveTween(curve: _curve)
    ).animate(_controller);

    _controller.addListener(() {
      setState(() {});
    });

    _animateIfDemanded();
    super.initState();
  }

  @override
  void didUpdateWidget(RequiredActionBadge oldWidget) {
    _animateIfDemanded();
    super.didUpdateWidget(oldWidget);
  }

  void _animateIfDemanded() {
    if (widget.animate) {
      _controller.reset();
      _controller.forward();
    } else {
      // initialize animation to its end state
      _controller.value = _controller.upperBound;
    }
  }

  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedOverflowBox(
      size: Size(widget.badgeSize, widget.badgeSize),
      child:
      Container(
        width: _containerAnimation.value,
        height: _containerAnimation.value,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              color: Colors.white,
              fontSize: _textAnimation.value,
              fontWeight: FontWeight.normal,
              fontFamily: 'Roboto',
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }

}
