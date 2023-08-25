import 'package:flutter/material.dart';
import 'package:mclauncher4/src/widgets/components/barGraphComponent.dart';

class BarGraph extends StatefulWidget {
  BarGraph({required this.values, required this.labels, this.barHeight = 200, Key? key}) : super(key: key);
  late final List<String> labels;
  late final List values;
  late final double barHeight;
  @override
  _BarGraphState createState() => _BarGraphState();
}

class _BarGraphState extends State<BarGraph> {
  double space = 16;

  _getDividerColor(BuildContext context) => Color.fromARGB(223, 118, 118, 118);
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 330,
        width: 500,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(18)),
        child: Stack(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(
                  height: 26,
                ),
                Text(
                  widget.labels[0],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).typography.black.labelLarge,
                ),
                SizedBox(
                  height: 20,
                ),
                BarGraphComponent(barHeight: widget.barHeight, value: widget.values[0]),
              ]),
              Padding(
                padding: EdgeInsets.all(space).add(EdgeInsets.only(bottom: 100, top: 20)),
                child: VerticalDivider(
                  thickness: 0.5,
                  color: _getDividerColor(context),
                ),
              ),
              Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(
                  height: 26,
                ),
                Text(
                  widget.labels[1],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).typography.black.labelLarge,
                ),
                SizedBox(
                  height: 20,
                ),
                BarGraphComponent(barHeight: widget.barHeight, value: widget.values[1]),
              ]),
              Padding(
                padding: EdgeInsets.all(space).add(EdgeInsets.only(bottom: 100, top: 20)),
                child: VerticalDivider(
                  thickness: 0.5,
                  color: _getDividerColor(context),
                ),
              ),
              Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(
                  height: 26,
                ),
                Text(
                  widget.labels[2],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).typography.black.labelLarge,
                ),
                SizedBox(
                  height: 20,
                ),
                BarGraphComponent(barHeight: widget.barHeight, value: widget.values[2]),
              ]),
              Padding(
                padding: EdgeInsets.all(space).add(EdgeInsets.only(bottom: 100, top: 20)),
                child: VerticalDivider(
                  thickness: 0.5,
                  color: _getDividerColor(context),
                ),
              ),
              Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(
                  height: 26,
                ),
                Text(
                  widget.labels[3],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).typography.black.labelLarge,
                ),
                SizedBox(
                  height: 20,
                ),
                BarGraphComponent(barHeight: widget.barHeight, value: widget.values[3]),
              ]),
              Padding(
                padding: EdgeInsets.all(space).add(EdgeInsets.only(bottom: 100, top: 20)),
                child: VerticalDivider(
                  thickness: 0.5,
                  color: _getDividerColor(context),
                ),
              ),
              Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(
                  height: 26,
                ),
                Text(
                  widget.labels[4],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).typography.black.labelLarge,
                ),
                SizedBox(
                  height: 20,
                ),
                BarGraphComponent(barHeight: widget.barHeight, value: widget.values[4]),
              ]),
              Padding(
                padding: EdgeInsets.all(space).add(EdgeInsets.only(bottom: 100, top: 20)),
                child: VerticalDivider(
                  thickness: 0.5,
                  color: _getDividerColor(context),
                ),
              ),
              Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(
                  height: 26,
                ),
                Text(
                  widget.labels[5],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).typography.black.labelLarge,
                ),
                SizedBox(
                  height: 20,
                ),
                BarGraphComponent(barHeight: widget.barHeight, value: widget.values[5]),
              ]),
              Padding(
                padding: EdgeInsets.all(space).add(EdgeInsets.only(bottom: 100, top: 20)),
                child: VerticalDivider(
                  thickness: 0.5,
                  color: _getDividerColor(context),
                ),
              ),
              Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(
                  height: 26,
                ),
                Text(
                  widget.labels[6],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).typography.black.labelLarge,
                ),
                SizedBox(
                  height: 20,
                ),
                BarGraphComponent(barHeight: widget.barHeight, value: widget.values[6]),
              ]),
            ],
          ),
          Align(
            alignment: Alignment(-1, 0),
            child: Padding(
              padding: const EdgeInsets.only(top: 60, bottom: 40, left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "24h",
                    style: Theme.of(context).typography.black.labelMedium!.merge(TextStyle(color: Color.fromARGB(223, 118, 118, 118))),
                  ),
                  Text(
                    "12h",
                    style: Theme.of(context).typography.black.labelMedium!.merge(TextStyle(color: Color.fromARGB(223, 118, 118, 118))),
                  ),
                  Text(
                    "0h",
                    style: Theme.of(context).typography.black.labelMedium!.merge(TextStyle(color: Color.fromARGB(223, 118, 118, 118))),
                  ),
                ],
              ),
            ),
          )
        ]));
  }
}
