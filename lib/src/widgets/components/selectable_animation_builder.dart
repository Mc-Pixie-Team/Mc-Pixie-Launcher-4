import 'package:flutter/material.dart';

class SelectableAnimatedBuilder extends StatefulWidget {
  const SelectableAnimatedBuilder({
    this.isSelected = true,
    this.curve = Curves.easeOutExpo,
    this.duration = const Duration(milliseconds: 400),
    required this.builder,
  });

  final bool isSelected;

  final Duration duration;

  final Curve curve;

  final Widget Function(BuildContext, Animation<double>) builder;

  @override
  SelectableAnimatedBuilderState createState() => SelectableAnimatedBuilderState();
}

class SelectableAnimatedBuilderState extends State<SelectableAnimatedBuilder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  );
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
    );
    _controller.duration = widget.duration;
    _controller.value = widget.isSelected ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(SelectableAnimatedBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse(from: 0.4);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      animation,
    );
  }
}
