import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mclauncher4/src/widgets/explorer/directory_widget.dart';
import 'package:mclauncher4/src/widgets/explorer/file_listcontroller.dart';
import 'package:mclauncher4/src/widgets/explorer/file_widget.dart';
import 'package:path/path.dart' as path;

class Explorer extends StatefulWidget {
  Directory rootDir;
  Explorer({Key? key, required this.rootDir}) : super(key: key);

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

    ValueNotifier<bool> notifier = ValueNotifier(startvalue);
    this.entityWidgets = getDirectoryItems(widget.rootDir, notifier);

    super.initState();
  }

  List<Widget> getDirectoryItems(Directory directory, ValueNotifier<bool> isEnabled) {
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
              children: List.generate(entityWidgets.length, (index) => entityWidgets[index])),
        ));
  }
}
