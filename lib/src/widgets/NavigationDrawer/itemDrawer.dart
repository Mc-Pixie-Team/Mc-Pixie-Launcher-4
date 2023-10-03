// ignore_for_file: must_be_immutable, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../components/sizeTransitionCustom.dart';
import '../components/selectableAnimationBuilder.dart';

class ItemDrawer extends StatefulWidget {
  double height;
  double width;
  String title;
  int offset;
  List<ItemDrawerItem> children;
  Function(int index) onChange;

  ItemDrawer(
      {Key? key,
      required this.onChange,
      this.offset = 0,
      this.title = '',
      this.height = 227,
      this.width = 170,

      required this.children})
      : super(key: key);

  @override
  _ItemDrawerState createState() => _ItemDrawerState();
}

class _ItemDrawerState extends State<ItemDrawer> with TickerProviderStateMixin {
  int index = 0;
  late List listcontrollers;


  @override
  void initState() {
   
    super.initState();
  this.index = widget.offset;

  }

  void onSelectedIndex(int index) {
      widget.onChange.call(index);
    setState(() {
      this.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        clipBehavior: Clip.hardEdge,
        width: widget.width,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          Padding(
            padding: EdgeInsets.only(left: 10, top: 8),
            child: Row(children: [
              Icon(
                Icons.expand_more,
                size: 20,
                color: Theme.of(context).typography.black.bodyMedium!.color,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                widget.title,
                style: Theme.of(context).typography.black.bodySmall,
              )
            ]),
          ),
          Container(
            height: 12,
          ),
          Column(
            children: List.generate(widget.children.length, (index) {
              ItemDrawerItem current = widget.children[index];

              return InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTapUp: (e) => onSelectedIndex(index),
                  child: Padding(
                      padding: EdgeInsets.only(top: 0, bottom: 10),
                      child: SelectableAnimatedBuilder(
                        builder: (BuildContext context,
                            Animation<double> animation) {
                         
                          return AnimatedBuilder(
                            animation: animation as Animation<double>,
                            builder: (context, child) {
                              return ItemDrawerItem(
                                height: current.height,
                                width: current.width,
                                animation: animation,
                                icon: current.icon,
                                title: current.title,
                              );
                            },
                          );
                        },
                        isSelected: index == this.index,
                      )));
            }),
          ),
          Container(
            height: 12,
          )
        ]));
  }
}

class ItemDrawerItem extends StatefulWidget {
  double height;
  double width;
  Icon icon;
  String title;
  Animation? animation;
  ItemDrawerItem({
    Key? key,
    this.height =38,
    this.animation,
    this.width = double.infinity,
    this.icon = const Icon(Icons.abc),
    this.title = "",
  }) : super(key: key);

  @override
  _ItemDrawerItemState createState() => _ItemDrawerItemState();
}

class _ItemDrawerItemState extends State<ItemDrawerItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
          color: ColorTween(
                  begin: Colors.transparent,
                  end: Color.fromARGB(8, 255, 255, 255))
              .animate(widget.animation as Animation<double>)
              .value),
      
        child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: widget.icon,
                ),
                Text(
                  widget.title,
                  style: Theme.of(context).typography.black.labelLarge,
                ),
                Expanded(
                  child: Container(),
                ),
                Sizetransitioncustom(
                  sizeFactor: widget.animation?.value,
                  child: Container(
                    width: 1,
                    height: double.infinity,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            )),
      
    );
  }
}
