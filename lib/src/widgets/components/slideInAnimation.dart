

import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:mclauncher4/src/widgets/components/selectableAnimationBuilder.dart';


class SlideInAnimation extends StatefulWidget {
  const SlideInAnimation({
    required this.child,
    this.curve = Curves.easeOutExpo,
    this.duration = const Duration(milliseconds: 1500),
    
  });

  final Duration duration;

  final Curve curve;

  final Widget child;

  @override
  _SlideInAnimationState createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation> with SingleTickerProviderStateMixin {
late AnimationController _controller;
  late Animation<double> animation = Tween( begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this,);
    _controller.duration = widget.duration;
    _controller.addListener(() { setState(() {
      
    });});
    _controller.forward();

  
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return  Transform.translate(offset: Offset(animation.value * 60, 0), child: widget.child,);
  }
}