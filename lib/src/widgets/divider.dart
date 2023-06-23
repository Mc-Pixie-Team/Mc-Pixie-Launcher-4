import 'package:flutter/material.dart';

class Divider extends StatefulWidget {
  double size;
  double thickness;
  Divider({Key? key, this.size = 10, this.thickness = 1}) : super(key: key);

  @override
  _DividerState createState() => _DividerState();
}

class _DividerState extends State<Divider> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: widget.size, right: widget.size),
      child: Container(
        color: Theme.of(context).colorScheme.outline,
        width: double.infinity,
        height: widget.thickness,
      ),
    );
  }
}
