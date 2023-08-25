import 'dart:ui';

import 'package:flutter/material.dart';

class BarGraphComponent extends StatefulWidget {
  BarGraphComponent({Key? key, required this.barHeight, required this.value}) : super(key: key);
  late final double barHeight;
  late final int value;
  @override
  _BarGraphComponentState createState() => _BarGraphComponentState();
}

class _BarGraphComponentState extends State<BarGraphComponent> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 1500));
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutExpo));

    _animationController.forward();
  }

  late AnimationController _animationController;
  late Animation _animation;
  @override
  Widget build(BuildContext context) {
    print(lerpDouble(0.0, (widget.barHeight * (widget.value / 100)), (_animation.value).toDouble()));
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(90)),
      height: widget.barHeight,
      width: 16,
      alignment: Alignment.bottomCenter,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: 16,
            constraints: BoxConstraints(
              minWidth: 0, // Minimum width
              maxWidth: double.infinity, // Maximum width
              minHeight: 0, // Minimum height
              maxHeight: widget.barHeight, // Maximum height
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(90),
                color: Color.lerp(Theme.of(context).colorScheme.onPrimary, Theme.of(context).colorScheme.primary, widget.value / 100)),
            child: Container(),
            height: lerpDouble(0.0, (widget.barHeight * (widget.value / 100)), (_animation.value).toDouble()),
          );
        },
      ),
    );
  }
}
