import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomDivider extends StatefulWidget {
  double size;
  double thickness;
  Color? color;
  CustomDivider({Key? key, this.size = 10, this.thickness = 1, this.color}) : super(key: key);

  @override
  _CustomDividerState createState() => _CustomDividerState();
}

class _CustomDividerState extends State<CustomDivider> {
  @override
  Widget build(BuildContext context) {
    return Divider(indent: widget.size, endIndent: widget.size, thickness: widget.thickness, color: widget.color ?? Theme.of(context).colorScheme.outline,);
  }
}
