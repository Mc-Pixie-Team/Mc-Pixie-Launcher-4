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
    Directory mainDir = Directory(
        "C:\\Users\\zepat\\Documents\\PixieLauncherInstances\\instance\\5f303592-e94e-1d7f-945f-cbebbd90c4bd");
        ValueNotifier<bool> notifier = ValueNotifier(startvalue);
    this.entityWidgets = getDirectoryItems(mainDir, notifier);
    FileList.files = convertToString(mainDir, "");
    
    super.initState();
  }

  List<String> convertToString(Directory directory, String additional) {
     List<String> result = [];

    List<FileSystemEntity> entities = directory.listSync();

    for(FileSystemEntity entity in entities){
      if(entity is Directory) {
        result.add(entity.path);
        result.addAll(convertToString(entity, additional));
        continue;
      }
      result.add(entity.path);
    }
  return result;
  }

  List<Widget> getDirectoryItems(Directory directory, ValueNotifier<bool> isEnabled) {
    List<Widget> result = [];

    List<FileSystemEntity> entities = directory.listSync();

    for (FileSystemEntity entity in entities) {
      if (entity is Directory) {
        if((entity as Directory).listSync().length < 1){
           result.add(FileWidget(path: entity.path, isEnabled: isEnabled,));
           continue;
        }

        ValueNotifier<bool> notifier = ValueNotifier(startvalue);
        result.add(DirectoryWidget(
            upperNotifier: isEnabled,
            lowerNotifier: notifier,
            path: entity.path,
            children: getDirectoryItems(entity, notifier)));
        continue;
      }
      result.add(FileWidget(path: entity.path, isEnabled: isEnabled,));
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
