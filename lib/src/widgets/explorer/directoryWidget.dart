import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mclauncher4/src/widgets/components/slideInAnimation.dart';
import 'package:mclauncher4/src/widgets/explorer/fileListController.dart';
import 'package:mclauncher4/src/widgets/explorer/fileWidget.dart';

class DirectoryWidget extends StatefulWidget {
  FileSystemEntity get getEntity => fileEntity;
  List<Widget> get getChildren => children;

  FileSystemEntity fileEntity;
  List<Widget> children;
  ValueNotifier<bool> upperNotifier;
  ValueNotifier<bool> lowerNotifier;
  DirectoryWidget(
      {Key? key,
      required this.fileEntity,
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
  bool isDisposed = true;
  List<String> overflow = [];
  void toggelexpand() {
    setState(() {
      isExpanded = !isExpanded;
      turns = isExpanded ? 0 : -0.25;
    });
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  void initState() {
    isEnabled = widget.upperNotifier.value; //init standart value
    isDisposed = false;
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
    if(isDisposed) return;
    if (!isEnabled) {
        FileList.files.remove(widget.fileEntity);
      } else {
        FileList.files.add(widget.fileEntity);
      }

    if (!isExpanded) {
      
     handleDirectory(widget.children);
    
    }
    print(FileList.files);
  }

  void handleDirectory(List<Widget> inwidgets){
      for (var inwidget in inwidgets) {
        if (inwidget is FileWidget) {
          if (!isEnabled) {
            FileList.files.remove(inwidget.getEntity);
          }else {
             FileList.files.add(inwidget.fileEntity);
          }
        } else if (inwidget is DirectoryWidget) {

          handleDirectory(inwidget.getChildren);
          if (!isEnabled) {
            FileList.files.remove(inwidget.getEntity);
          }else {
             FileList.files.add(inwidget.fileEntity);
          }
        }
      }
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
                            "/" + widget.fileEntity.path.split("\\").last,
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
