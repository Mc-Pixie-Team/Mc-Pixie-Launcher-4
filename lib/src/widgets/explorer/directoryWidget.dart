import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mclauncher4/src/widgets/components/slideInAnimation.dart';
import 'package:mclauncher4/src/widgets/explorer/fileListController.dart';

class DirectoryWidget extends StatefulWidget {
  String path;
  List<Widget> children;
  ValueNotifier<bool> upperNotifier;
  ValueNotifier<bool> lowerNotifier;
  DirectoryWidget(
      {Key? key,
      required this.path,
      required this.children,
      required this.upperNotifier,
      required this.lowerNotifier})
      : super(key: key);

  @override
  _DirectoryWidgetState createState() => _DirectoryWidgetState();
}

class _DirectoryWidgetState extends State<DirectoryWidget> {
  double turns = -0.25;
  bool isExpanded = false;
  bool isEnabled = false;
  List<String> overflow = [];
  void toggelexpand() {
    setState(() {
      isExpanded = !isExpanded;
      turns = isExpanded ? 0 : -0.25;
    });
  }

  @override
  void initState() {
    isEnabled = widget.upperNotifier.value; //init standart value
    overflow =
        List.from(FileList.files.where((str) => str.startsWith(widget.path)));
    /*
    Calculate all children widgets Path. 
    This means that if they are no longer rendered, the paths can still be restored or deleted
    */

    widget.upperNotifier.addListener(() {
      this.isEnabled = widget.upperNotifier.value;
      handleFile();
      widget.lowerNotifier.value = widget.upperNotifier.value;
    });

    super.initState();
  }

  onPressed() {
    widget.lowerNotifier.value = !widget.lowerNotifier.value;

    setState(() {
      this.isEnabled = !this.isEnabled;
    });

    handleFile();
  }

  void handleFile() {
    if (!isEnabled) {
      FileList.files.remove(widget.path);
      if (!isExpanded) {
        FileList.files.removeWhere((str) => str.startsWith(widget.path));
      }
    } else {
      FileList.files.add(widget.path);
      if (!isExpanded) {
        FileList.files.addAll(overflow);
      }
    }
    print(FileList.files);
  }

  @override
  Widget build(BuildContext context) {
    return SlideInAnimation(
        duration: Duration(milliseconds: 600),
        child: Padding(
            padding: EdgeInsets.only(top: 10),
            child: GestureDetector(
              onTap: () => toggelexpand(),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.start, //Center Row contents horizontally,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                              padding: EdgeInsets.only(
                                right: 9,
                              ),
                              child: AnimatedRotation(
                                  turns: turns,
                                  duration: Duration(milliseconds: 400),
                                  curve: Curves.easeOutExpo,
                                  child: SizedBox(
                                      width: 10,
                                      height: 10,
                                      child: SvgPicture.asset(
                                          "assets/svg/dropdown-icon.svg")))),
                          ValueListenableBuilder(
                              valueListenable: widget.upperNotifier,
                              builder: (context, isEnabled, child) =>
                                  GestureDetector(
                                      onTap: () => onPressed(),
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeOutExpo,
                                        margin:
                                            EdgeInsets.only(top: 2, right: 9),
                                        width: 25,
                                        height: 25,
                                        decoration: ShapeDecoration(
                                          color: (this.isEnabled as bool)
                                              ? Color(0xFF9C79FF)
                                              : Color.fromARGB(255, 71, 71, 71),
                                          shape: OvalBorder(),
                                        ),
                                      ))),
                          Text(
                            "/" + widget.path.split("\\").last,
                            style: Theme.of(context).typography.black.bodyLarge,
                          ),
                        ],
                      ),
                      if (isExpanded)
                        Padding(
                          padding: EdgeInsets.only(left: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var child in widget.children) child,
                            ],
                          ),
                        ),
                    ],
                  )
                ],
              ),
            )));
  }
}
