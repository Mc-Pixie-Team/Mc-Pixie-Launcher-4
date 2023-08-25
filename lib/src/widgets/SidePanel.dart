import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vec;

class SidePanel extends StatefulWidget {
  var state = _SidePanelState();
  static final SidePanel _instance = SidePanel._internal();

  factory SidePanel() {
    return _instance;
  }

  SidePanel._internal();

  void pop(Widget parent, double width) {
    state.setNewWidget(parent, width);
  }

  @override
  _SidePanelState createState() => state;
}

class _SidePanelState extends State<SidePanel>
    with SingleTickerProviderStateMixin {
  bool isdisposed = true;
  bool isanimating = false;
  late Widget oldWidget;
  Widget? newWidget;
  late AnimationController _controller;
  late Animation ani;
  double? width;
  double? width_old;

  @override
  void initState() {
    isdisposed = false;
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    ani = Tween(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));

    _controller.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    isdisposed = true;
    super.dispose();
  }

  GlobalKey stickyKey = GlobalKey();

  Widget currentWidget = Container(
      height: double.infinity,
      width: 250,
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets\\images\\backgound_blue.jpg',
        fit: BoxFit.cover,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Color.fromARGB(0, 27, 124, 204)));

  startAnimation() {
    _controller.reset();
    _controller.forward();
  }

  setNewWidget(Widget parent, double width) {
    if (isdisposed || isanimating) return;
    width_old = this.width;
    this.width = width;
    newWidget = parent;

    startAnimation();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        isanimating = true;
      }
      if (status == AnimationStatus.completed) {
        currentWidget = newWidget as Widget;
        isanimating = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 0, top: 43, right: 10, bottom: 12),
        child: Container(
            width: lerpDouble(
                (width_old ?? 200), (width ?? 200), ((ani.value * -1) + 1)),
            height: double.infinity,
            child: ClipRect(
                child: Stack(
              children: [
                Opacity(
                  opacity: ani.value,
                  child: Transform.translate(
                      offset: Offset(100.0 * ((ani.value * -1) + 1), 0),
                      child: currentWidget),
                ),
                Align(
                    alignment: Alignment(1, 1),
                    child: Transform.translate(
                      offset: Offset((width ?? 200) * ani.value, 0),
                      child: newWidget == null ? Container() : newWidget,
                    )),
              ],
            ))));
  }
}
