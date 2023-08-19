import 'package:flutter/material.dart';
import 'dart:math' as math;

class Sizetransitioncustom extends StatefulWidget {
  var axis;

  var axisAlignment;

  var child;

  double sizeFactor;
  Sizetransitioncustom({
    super.key,
    this.axis = Axis.vertical,
    required this.sizeFactor,
    this.axisAlignment = -1.0,
    this.child,
  });

  @override
  _SizetransitioncustomState createState() => _SizetransitioncustomState();
}

class _SizetransitioncustomState extends State<Sizetransitioncustom> {
  @override
  Widget build(BuildContext context) {
   
    final AlignmentDirectional alignment;
    if (widget.axis == Axis.vertical) {
      alignment = AlignmentDirectional(-1.0, widget.axisAlignment);
    } else {
      alignment = AlignmentDirectional(widget.axisAlignment, -1.0);
    }
    return ClipRect(
      child: Align(
        alignment: alignment,
        heightFactor: widget.axis == Axis.vertical
            ? math.max(widget.sizeFactor, 0.0)
            : null,
        widthFactor: widget.axis == Axis.horizontal
            ? math.max(widget.sizeFactor, 0.0)
            : null,
        child: widget.child,
      ),
    );
  }
}
