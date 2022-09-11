import 'package:flutter/material.dart';

class RequiredActionBadge extends StatefulWidget {
  final String text;
  final double badgeSize;
  final bool animate;
  final VoidCallback onAnimateComplete;
  final List<BoxShadow> boxShadow;

  RequiredActionBadge(this.text,
      {this.animate: false,
      this.badgeSize: 30.0,
      this.onAnimateComplete,
      this.boxShadow: const []});

  @override
  State<StatefulWidget> createState() => _RequiredActionBadgeState();
}

class _RequiredActionBadgeState extends State<RequiredActionBadge>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _containerAnimation;
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
    ).chain(CurveTween(curve: _curve)).animate(_controller);

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
      _controller.forward().then((dynamic _) {
        if (widget.onAnimateComplete != null) {
          widget.onAnimateComplete();
        }
      });
    } else {
      // initialize animation to its end state
      _controller.value = _controller.upperBound;
    }
  }

  dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _surroundWithFittedBoxIfWidthGreaterThanZero(
      {Widget child, double parentWidth}) {
    if (parentWidth > 0.0) {
      return FittedBox(
        fit: BoxFit.fitWidth,
        child: child,
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    return SizedOverflowBox(
      size: Size(widget.badgeSize, widget.badgeSize),
      child: Container(
        width: _containerAnimation.value,
        height: _containerAnimation.value,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
          boxShadow: widget.boxShadow,
        ),
        child: Padding(
          padding: EdgeInsets.all(_containerAnimation.value / 10.0),
          child: Center(
            child: _surroundWithFittedBoxIfWidthGreaterThanZero(
              parentWidth: _containerAnimation.value,
              child: Text(
                widget.text,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Roboto',
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
