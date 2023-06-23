// ignore_for_file: must_be_immutable, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import './components/sizeTransitionCustom.dart';

class ItemDrawer extends StatefulWidget {
  double height;
  double width;
  String title;
  List<ItemDrawerItem> children;
  Function callback;

  ItemDrawer(
      {Key? key,
      required this.callback,
      this.title = '',
      this.height = 230,
      this.width = 170,
      required this.children})
      : super(key: key);

  @override
  _ItemDrawerState createState() => _ItemDrawerState();
}

class _ItemDrawerState extends State<ItemDrawer> with TickerProviderStateMixin {
  int index = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
        clipBehavior: Clip.hardEdge,
        height: widget.height,
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
            height: 10,
          ),
          Column(
            children: List.generate(widget.children.length, (index) {
              print('reload');
              ItemDrawerItem current = widget.children[index];
              AnimationController _controller = AnimationController(
                  vsync: this, duration: Duration(milliseconds: 300));
              Animation tweenAnimation =
                  CurveTween(curve: Curves.easeInOut).animate(_controller);
              current.animation = tweenAnimation;
              tweenAnimation.addListener(() {
                print('heleo from controller');
              });

              if (_controller.isCompleted) {
                _controller.reverse();
              } else {
                if (this.index == index) {
                  print('starting controller');
                  _controller.forward();
                }
              }

              return InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTapUp: (e) => setState(() {
                        this.index = index;
                        print('setting index to: ' + index.toString());
                      }),
                  child: Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: AnimatedBuilder(
                        animation: tweenAnimation,
                        builder: (context, child) => current,
                      )));
            }),
          ),
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
    this.height = 40,
    this.animation,
    this.width = double.infinity,
    this.icon = const Icon(Icons.abc),
    this.title = "",
  }) : super (key: key);

  @override
  _ItemDrawerItemState createState() => _ItemDrawerItemState();
}



  

class _ItemDrawerItemState extends State<ItemDrawerItem> {


  @override
  void initState() {
    print('initstate');
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    print('heelo from builder of item');
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(color: Color.fromARGB(40, 114, 114, 114)),
      child: Center(
        child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
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
                widget.animation != null
                    ? Sizetransitioncustom(
                        sizeFactor: widget.animation!.value,
                        child: Container(
                          width: 1,
                          height: double.infinity,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : Container()
              ],
            )),
      ),
    );
  }
}
