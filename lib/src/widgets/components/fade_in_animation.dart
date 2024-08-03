import 'package:flutter/material.dart';

class FadeInAnimation extends StatefulWidget {
  const FadeInAnimation({ Key? key,  this.duration = const Duration(milliseconds: 500), this.curve = Curves.easeInQuad, required this.child }) : super(key: key);

  final Duration duration;

  final Curve curve;

  final Widget child;

  @override
  _FadeInAnimationState createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>  with SingleTickerProviderStateMixin{
    late AnimationController _controller;
  late Animation<double> animation =
      Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

  @override
  void initState() {
    
    super.initState();
    _controller = AnimationController(
      vsync: this,
    );
    _controller.duration = widget.duration;
    _controller.addListener(() {
      setState(() {});
    });
    _controller.forward();

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: animation.value, child: widget.child,);
  }
}