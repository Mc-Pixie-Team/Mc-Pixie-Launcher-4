import 'package:flutter/material.dart';

class BarGraphComponent extends StatefulWidget {
  BarGraphComponent({Key? key, required this.barHeight, required this.value}) : super(key: key);
  late final double barHeight;
  late final int value;
  @override
  _BarGraphComponentState createState() => _BarGraphComponentState();
}

class _BarGraphComponentState extends State<BarGraphComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.cyanAccent, borderRadius: BorderRadius.circular(90)),
      height: widget.barHeight,
      width: 20,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 20,
        constraints: BoxConstraints(
          minWidth: 0, // Minimum width
          maxWidth: double.infinity, // Maximum width
          minHeight: 0, // Minimum height
          maxHeight: widget.barHeight, // Maximum height
        ),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), color: Theme.of(context).colorScheme.primary),
        child: Container(),
        height: widget.barHeight * (widget.value / 100),
      ),
    );
  }
}
