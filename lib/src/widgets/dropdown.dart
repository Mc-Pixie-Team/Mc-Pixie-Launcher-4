import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import '../theme/scrollphysics.dart';
import 'package:flutter/physics.dart';

class DropDown extends StatefulWidget {
  Color color;
  Color cardColor;
  DropDown(
      {Key? key,
      this.color = const Color.fromARGB(255, 15, 15, 15),
      this.cardColor = const Color.fromARGB(255, 34, 34, 34)})
      : super(key: key);

  @override
  _DropDown createState() => _DropDown();
}

class _DropDown extends State<DropDown> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapUp: (details) {
        showDialog(
            context: context,
            builder: (context) {
              return Center(
                  child: DropDownMenu(
                height: 200,
                width: 300,
              ));
            });
      },
      child: Container(
        height: 60,
        width: 80,
        decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.all(Radius.circular(8))),
      ),
    );
  }
}

class DropDownMenu extends StatefulWidget {
  double height;
  double width;

  DropDownMenu({Key? key, this.height = 500, this.width = 60})
      : super(key: key);

  @override
  _DropDownMenu createState() => _DropDownMenu();
}

class _DropDownMenu extends State<DropDownMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  Duration duration = const Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: duration,
    );
    _animation = CurveTween(curve: Curves.easeInOutCubic).animate(_controller);
    _controller.forward();

    a.addListener(() {
      // print(a.position);
    });
  }

  ScrollController a = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: widget.height,
        width: widget.width,
        child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                  opacity: _animation.value,
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: SizeTransition(
                        sizeFactor: _animation as Animation<double>,
                        child: Container(
                            color: Color.fromARGB(255, 29, 29, 29),
                            child: ListView.builder(
                                itemCount: 1000,
                                controller: a,
                                physics: PixieScrollPhysics(),
                                itemBuilder: (context, i) {
                                  return Text(
                                    '$i',
                                    style: TextStyle(color: Colors.white),
                                  );
                                })),
                      )));
            }));
  }
}



class DropDownItem extends StatefulWidget {
  const DropDownItem({Key? key}) : super(key: key);

  @override
  _DropDownItemState createState() => _DropDownItemState();
}

class _DropDownItemState extends State<DropDownItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 35,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16))));
  }
}
