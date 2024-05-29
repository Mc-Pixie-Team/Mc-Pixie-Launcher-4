import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/widgets/side_panel/taskwidget.dart';
import 'package:vector_math/vector_math.dart' as vec;
import 'dart:io' show Platform;


class StaticSidePanelController {

static SidePanelController controller = SidePanelController();
}


class SidePanelController {

  Function(Widget parent, double width)? _pushCallBack;

  Function(Widget parent)? _setSecondaryCallBack;

  Function? _removeSecondaryCallBack;

  Function(Widget item, String processId)? _addToTaskWidgetCallback;

  Function(String processId)? _removeFromTaskWidgetCallback;

  void push(Widget parent, double width) {
    if (_pushCallBack == null)
      throw Exception("Side Panel Controller isnt initialized!");

    _pushCallBack!.call(parent, width);
  }

  void setSecondary(Widget parent) {
    if (_setSecondaryCallBack == null)
      throw Exception("Side Panel Controller isnt initialized!");

    _setSecondaryCallBack!.call(parent);
  }

  void removeSecondary() {
    if (_removeSecondaryCallBack == null)
      throw Exception("Side Panel Controller isnt initialized!");

    _removeSecondaryCallBack!.call();
  }

  void addToTaskWidget(Widget item, String processId) {
    if (_addToTaskWidgetCallback == null)
      throw Exception("Side Panel Controller isnt initialized!");

    _addToTaskWidgetCallback!.call(item, processId);
  }

  removeFromTaskWidget(String processId) {
    if(_removeFromTaskWidgetCallback == null)  throw Exception("Side Panel Controller isnt initialized!");

    _removeFromTaskWidgetCallback!.call(processId);
  }
}

// ignore: must_be_immutable
class SidePanel extends StatefulWidget {
  SidePanelController controller;
  SidePanel({required this.controller});

  @override
  _SidePanelState createState() => _SidePanelState();
}

class _SidePanelState extends State<SidePanel> with TickerProviderStateMixin {
  bool isdisposed = true;
  bool isanimating = false;
  late Widget oldWidget;
  Widget? newWidget;
  late Widget secOldWidget;
  Widget? secNewWidget;
  late AnimationController _controller;
  late Animation ani;
  late AnimationController _controllersec;
  late Animation ani2;
  double? width;
  double? width_old;
  double defaultHeight = 320.0;
  double defaultWidth = 280.0;

  @override
  void initState() {
    print("initState in inner SidePanelState build");
    isdisposed = false;

    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    ani = Tween(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));
    _controllersec = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    ani2 = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        reverseCurve: Curves.easeInExpo,
        parent: _controllersec,
        curve: Curves.easeOutExpo));
    _controller.addListener(() {
      setState(() {});
    });
    widget.controller._pushCallBack = setNewWidget;
    widget.controller._setSecondaryCallBack = setNewSecondary;
    widget.controller._removeSecondaryCallBack = removeSecondary;
    widget.controller._addToTaskWidgetCallback = addToTaskWidget;
    widget.controller._removeFromTaskWidgetCallback = removeFromTaskWidget;

    super.initState();
  }

  @override
  void dispose() {
    isdisposed = true;
    super.dispose();
  }

  Widget? _secondaryWidget;

  Widget? get secondaryWidget => _secondaryWidget;
  Widget currentWidget = Container(
      height: double.infinity,
      width: 280.0,
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/backgound_blue.jpg',
        fit: BoxFit.cover,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Color.fromARGB(0, 27, 124, 204)));

  startfirstAnimation() {
    _controller.reset();
    _controller.forward();
  }

  startsecondAnimation() {
    _controllersec.reset();
    _controllersec.forward();
  }

  Map<String, Widget> items = {};
  addToTaskWidget(Widget item, String processId) {
    items['$processId'] = item;
    taskWidgetplacer();
  }

  removeFromTaskWidget(String processId) {
    items.removeWhere((key, value) => key == processId);
    taskWidgetplacer();

    if (items.length < 1) {
      removeSecondary();
    }
  }

  taskWidgetplacer() {
    Widget taskwidget = TaskWidget(
      items: items,
    );

    if (_secondaryWidget == null) {
      setNewSecondary(taskwidget);
      return;
    }
    if (_controllersec.status == AnimationStatus.dismissed ||
        _secondaryWidget!.runtimeType != TaskWidget) {
      setNewSecondary(taskwidget);
    }
    if (_controllersec.status == AnimationStatus.completed) {
      secNewWidget = taskwidget;
      _secondaryWidget = taskwidget;
      setState(() {});
    }
  }

  setNewWidget(Widget parent, double width) {
    // if (isdisposed || isanimating) return;
    width_old = this.width;
    this.width = width;
    newWidget = parent;

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        isanimating = true;
      }
      if (status == AnimationStatus.completed) {
        currentWidget = newWidget as Widget;
        isanimating = false;
      }
    });
    startfirstAnimation();
  }

  setNewSecondary(Widget parent) {
    if (isdisposed || isanimating) return;
    secNewWidget = parent;

    _controllersec.addStatusListener((status) {
      switch (status) {
        case (AnimationStatus.forward):
          isanimating = true;
          break;
        case (AnimationStatus.completed):
          _secondaryWidget = parent;
          isanimating = false;
          break;
        case (AnimationStatus.dismissed):
          isanimating = false;

          break;
        default:
          break;
      }
    });
    startsecondAnimation();
  }

  removeSecondary() {
    print('called removeSeconday');
    _secondaryWidget = null;
    _controllersec.reverse();
  }

  @override
  Widget build(BuildContext context) {
    print("rebuild in inner SidePanelState build");
    return Padding(
        padding: EdgeInsets.only(
            left: 0, top: Platform.isMacOS ? 12 : 43, right: 10, bottom: 12),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Expanded(
              child: Container(
                  width: lerpDouble((width_old ?? defaultWidth),
                      (width ?? defaultWidth), ((ani.value * -1) + 1)),
                  height: double.infinity,
                  child: OverflowBox(
                      child: Stack(
                    children: [
                      Opacity(
                        opacity: ani.value,
                        child: Transform.translate(
                            offset: Offset(100.0 * ((ani.value * -1) + 1), 0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                  width: (this.width_old ?? defaultWidth),
                                  child: currentWidget),
                            )),
                      ),
                      Align(
                          alignment: Alignment(1, 1),
                          child: Transform.translate(
                            offset:
                                Offset((width ?? defaultWidth) * ani.value, 0),
                            child: newWidget == null
                                ? Container()
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                        width: (width ?? defaultWidth),
                                        child: newWidget),
                                  ),
                          )),
                    ],
                  )))),
          AnimatedBuilder(
              animation: ani2,
              builder: (context, child) {
                return Padding(
                    padding: EdgeInsets.only(
                        top: secondaryWidget != null
                            ? 10.0
                            : 10.0 * ((ani2.value * -1) + 1)),
                    child: SizedBox(
                      width: lerpDouble((width_old ?? defaultWidth),
                          (width ?? defaultWidth), ((ani.value * -1) + 1)),
                      height: secondaryWidget != null
                          ? defaultHeight
                          : defaultHeight * ((ani2.value * -1) + 1),
                      child: Stack(
                        alignment: Alignment.topLeft,
                        children: [
                          Transform.translate(
                              offset: Offset(
                                  0,
                                  (defaultHeight + 20) *
                                      ((ani2.value * -1) + 1)),
                              child: secondaryWidget ?? Container()),
                          Transform.translate(
                            offset: Offset(0, defaultHeight * ani2.value),
                            child: secNewWidget ?? Container(),
                          ),
                        ],
                      ),
                    ));
              })
        ]));
  }
}
