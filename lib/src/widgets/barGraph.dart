import 'package:flutter/material.dart';
import 'package:mclauncher4/src/widgets/components/barGraphComponent.dart';

class BarGraph extends StatefulWidget {
  BarGraph({required this.values, this.barHeight = 200, Key? key}) : super(key: key);
  late final List values;
  late final double barHeight;
  @override
  _BarGraphState createState() => _BarGraphState();
}

class _BarGraphState extends State<BarGraph> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text("S"),
            BarGraphComponent(barHeight: widget.barHeight, value: widget.values[0]),
          ])
        ],
      ),
    );
  }
}
