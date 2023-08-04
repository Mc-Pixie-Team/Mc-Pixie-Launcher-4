import 'package:flutter/material.dart';

// ignore: must_be_immutable
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
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 0.50,
              strokeAlign: BorderSide.strokeAlignCenter,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        width: double.infinity,
        height: widget.thickness,
      ),
    );
  }
}
