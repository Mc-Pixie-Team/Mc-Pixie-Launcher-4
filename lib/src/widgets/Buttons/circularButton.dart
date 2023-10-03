import 'package:flutter/material.dart';

class CircularButton extends StatefulWidget {
  CircularButton({Key? key, required this.height, required this.width, required this.child, required this.onClick}) : super(key: key);
  double height;
  double width;
  Widget child;
  void Function()? onClick;
  @override
  _CircularButtonState createState() => _CircularButtonState();
}

class _CircularButtonState extends State<CircularButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(90)),
          height: widget.height,
          width: widget.width,
          child: Center(child: widget.child)),
      onTap: widget.onClick,
    );
  }
}
