import 'package:flutter/material.dart';

class MenuItem extends StatefulWidget {
  Icon icon;
  String title;
  double height;
  double width;
  MenuItem(
      {Key? key,
      this.icon = const Icon(Icons.abc),
      this.title = '',
      this.width = double.infinity,
      this.height = 25})
      : super(key: key);

  @override
  _MenuItemState createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Align(alignment: Alignment.topCenter, child: Row(children: [
        Padding(
          padding: EdgeInsets.only( right: 10),
          child: widget.icon,
        ),
        Text(widget.title, style: Theme.of(context).typography.black.titleMedium,)
      ]),
    ));
  }
}
