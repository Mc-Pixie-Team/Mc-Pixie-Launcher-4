import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mclauncher4/src/widgets/explorer/directoryWidget.dart';
import 'package:mclauncher4/src/widgets/explorer/fileListController.dart';
import 'package:mclauncher4/src/widgets/explorer/fileWidget.dart';

class Explorer extends StatefulWidget {
  const Explorer({Key? key}) : super(key: key);

  @override
  _ExplorerState createState() => _ExplorerState();
}

class _ExplorerState extends State<Explorer> {
  List<Widget> entityWidgets = [];
  List<String> entityPaths = [];
  bool startvalue = true;

  @override
  void initState() {
    FileList.files = [];
    Directory mainDir = Directory(
        "C:\\Users\\zepat\\Documents\\PixieLauncherInstances\\instance\\5f303592-e94e-1d7f-945f-cbebbd90c4bd");

    ValueNotifier<bool> notifier = ValueNotifier(startvalue);
    this.entityWidgets = getDirectoryItems(mainDir, notifier);

    super.initState();
  }

  List<Widget> getDirectoryItems(
      Directory directory, ValueNotifier<bool> isEnabled) {
    List<Widget> result = [];

    List<FileSystemEntity> entities = directory.listSync();

    for (FileSystemEntity entity in entities) {
      FileList.files.add(entity);
      if (entity is Directory) {
        if ((entity as Directory).listSync().length < 1) {
      
          result.add(FileWidget(
            fileEntity: entity,
            isEnabled: isEnabled,
          ));
          continue;
        }

        ValueNotifier<bool> notifier = ValueNotifier(startvalue);
        result.add(DirectoryWidget(
            upperNotifier: isEnabled,
            lowerNotifier: notifier,
            fileEntity: entity,
            children: getDirectoryItems(entity, notifier)));
        continue;
      }
    
      result.add(FileWidget(
        fileEntity: entity as File,
        isEnabled: isEnabled,
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(
                  entityWidgets.length, (index) => entityWidgets[index])),
        ));
  }
}
