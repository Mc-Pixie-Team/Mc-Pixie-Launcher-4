import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/pages/installed_mod/installed_mods_page.dart';
import 'package:mclauncher4/src/tasks/apis/files/curseforge.files.dart';
import 'package:mclauncher4/src/tasks/apis/files/files_helper.dart';
import 'package:mclauncher4/src/tasks/models/object_type.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:path/path.dart' as p;

class FilesHandler with ChangeNotifier {
  FilesHandler({required this.directoryPath, required this.types});
  List<String> subDirs = [];
  List<ObjectType> types;
  String directoryPath;
  List<UMF> _files = [];

  List<UMF> get files => _files;
  List<StreamSubscription<FileSystemEvent>> sub = [];

  late FileHelper _helper;

  void initialize() {

    _helper = FileHelper(directoryPath: directoryPath);
    var instanceFile = File(p.join(directoryPath, "instance.json"));

    if (!instanceFile.existsSync()) {
      instanceFile.createSync();
      instanceFile.writeAsStringSync('{"files": []}');
    }

    var instance = jsonDecode(instanceFile.readAsStringSync());

    List instanceFiles = instance["files"];
    types.forEach((type) {
      var subDir = ObjectTypeTools.todir(type);
        print(subDir);
      var dir = Directory(p.join(directoryPath, subDir));
      var items = dir.listSync();
      
      //Check if all items in directory are in instance
      items.forEach((entity) async {
        print(entity.path);
        Map mapfile = instanceFiles.singleWhere(
          (element) {
            return element["original"]["filepath"] == entity.path;
          },
          orElse: () => {},
        );

        if (mapfile.isEmpty) {
          print("addto");
          await _addto(entity.path);
        } else {
          print("add");
          _files.add(UMF.parse(mapfile).copyWith(type: type));
        }
      });
      _helper.save(_files);

      //Add listener to dir
      var csub = dir.watch().listen((event) async {
        await listener(event);
        notifyListeners();
      });
      sub.add(csub);
    });
  }

  listener(FileSystemEvent event) async {
    if (event is FileSystemCreateEvent) {
      if (event.isDirectory) return;
      await _addto(event.path);
    } else if (event is FileSystemDeleteEvent) {
      if (event.isDirectory) return;
      _remove(event.path);
    } else if (event is FileSystemMoveEvent) {
      if (event.isDirectory) return;
      await _addto(event.path);
      _remove(event.destination!);
    }
  }

  void dispose() {
    sub.forEach((csub) {
      csub.cancel();
    });
    super.dispose();
  }

  void _remove(String filepath) {
    _files.removeWhere((element) {
      return p.equals(element.original["filepath"], filepath);
    });
    _helper.save(_files);
  }

  _addto(String filepath) async {
    UMF file;
    try {
      file = await getFileData(filepath);
    } catch (e) {
      file = UMF(
        original: {"filepath": filepath},
        name: p.basename(filepath),
        author: "unknown",
      );
    }

    _files.add(file);
    _helper.save(_files);
  }

  Future<UMF> getFileData(String filepath) async {
    return await CurseforgeFiles().getFileData(filepath);
  }
}
