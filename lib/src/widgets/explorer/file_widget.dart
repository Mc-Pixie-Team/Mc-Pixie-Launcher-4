import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/widgets/components/slide_in_animation.dart';
import 'package:mclauncher4/src/widgets/explorer/file_listcontroller.dart';
import 'package:path/path.dart' as path;
// ignore: must_be_immutable
class FileWidget extends StatefulWidget {
  FileSystemEntity get getEntity => fileEntity;

  FileSystemEntity fileEntity;
  ValueNotifier<bool> isEnabled;
  FileWidget({Key? key, required this.fileEntity, required this.isEnabled}) : super(key: key);

  @override
  _FileWidgetState createState() => _FileWidgetState();
}

class _FileWidgetState extends State<FileWidget> {
  bool isEnabled = false;
  bool isDisposed = true;

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  void initState() {
    print('init');
    isEnabled = widget.isEnabled.value;
    isDisposed = false;
    widget.isEnabled.addListener(() {
      isEnabled = widget.isEnabled.value;
    });
    super.initState();
  }

  void onPressed() {
    setState(() {
      isEnabled = !isEnabled;
    });

    handleFile();
  }

  void handleFile() {
    if (isDisposed) return;
    if (!isEnabled) {
      FileList.files.remove(widget.fileEntity);
    } else {
      FileList.files.add(widget.fileEntity);
    }
    print(FileList.files);
  }

  @override
  Widget build(BuildContext context) {
    return SlideInAnimation(
        duration: Duration(milliseconds: 600),
        child: SizedBox(
          child: Padding(
              padding: EdgeInsets.only(left: 19, top: 10),
              child: Row(
                children: [
                  ValueListenableBuilder(
                      valueListenable: widget.isEnabled,
                      builder: (context, bool isEnabled, child) => GestureDetector(
                          onTap: () => onPressed(),
                          child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOutExpo,
                              margin: EdgeInsets.only(top: 2, right: 9),
                              width: 25,
                              height: 25,
                              decoration: ShapeDecoration(
                                color: this.isEnabled ? Color(0xFF9C79FF) : Color.fromARGB(255, 71, 71, 71),
                                shape: OvalBorder(),
                              )))),
                  Text(
                    widget.fileEntity.path.split(path.separator).last,
                    style: Theme.of(context).typography.black.bodyLarge,
                  )
                ],
              )),
        ));
  }
}
