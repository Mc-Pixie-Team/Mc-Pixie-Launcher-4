// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class ItemDrawer extends StatefulWidget {
  double height;
  double width;
  List<ItemDrawerItem> children;

  ItemDrawer(
      {Key? key, this.height = 300, this.width = 200, required this.children})
      : super(key: key);

  @override
  _ItemDrawerState createState() => _ItemDrawerState();
}

class _ItemDrawerState extends State<ItemDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        
          color: Colors.green, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: List.generate(widget.children.length, (index) {
          var current = widget.children[index];
          return ItemDrawerItem(
            height: current.height,
            width: current.width,
          );
        }),
      ),
    );
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
