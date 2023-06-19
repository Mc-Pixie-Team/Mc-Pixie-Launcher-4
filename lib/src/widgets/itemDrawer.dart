// ignore_for_file: must_be_immutable, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ItemDrawer extends StatefulWidget {
  double height;
  double width;
  List<ItemDrawerItem> children;

  ItemDrawer(
      {Key? key, this.height = 230, this.width = 170, required this.children})
      : super(key: key);

  @override
  _ItemDrawerState createState() => _ItemDrawerState();
}

class _ItemDrawerState extends State<ItemDrawer>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
        clipBehavior: Clip.hardEdge,
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, top: 4),
                child: Icon(
                  Icons.expand_more,
                  size: 20,
                ),
              )
            ],
          ),
          Column(
            children: List.generate(widget.children.length, (index) {
              ItemDrawerItem current = widget.children[index];

              return current;
            }),
          ),
        ]));
  }
}

class ItemDrawerItem extends StatefulWidget {
  double height;
  double width;
  ItemDrawerItem({
    Key? key,
    this.height = 80,
    this.width = double.infinity,
  }) : super(key: key);

  @override
  _ItemDrawerItemState createState() => _ItemDrawerItemState();
}

class _ItemDrawerItemState extends State<ItemDrawerItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      color: Colors.black,
    );
  }
}
