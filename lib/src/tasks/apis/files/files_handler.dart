import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void initialize() async {
    _helper = FileHelper(directoryPath: directoryPath);

    var token = RootIsolateToken.instance!;
    var files32 = await Isolate.run(
        () => initializeContainingFiles(this.directoryPath, this.types, token));
    _files.addAll(files32);
    notifyListeners();

    for (var type in types) {
      var subDir = ObjectTypeTools.todir(type);
      var dir = Directory(p.join(directoryPath, subDir));
      var csub = dir.watch().listen((event) => listener(event, type));
      sub.add(csub);
    }
  }

  static Future<List<UMF>> initializeContainingFiles(String directoryPath,
      List<ObjectType> types, RootIsolateToken token) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);

    List<UMF> _files = [];
    var _helper = FileHelper(directoryPath: directoryPath);

    var instanceFile = File(p.join(directoryPath, "instance.json"));

    if (!instanceFile.existsSync()) {
      instanceFile.createSync();
      instanceFile.writeAsStringSync('{"files": []}');
    }

    var instance = jsonDecode(instanceFile.readAsStringSync());

    List instanceFiles = instance["files"];
    for (var type in types) {
      var subDir = ObjectTypeTools.todir(type);
      var dir = Directory(p.join(directoryPath, subDir));
      var items = dir.listSync();

      //Check if all items in directory are in instance
      for (var entity in items) {
        Map mapfile = instanceFiles.singleWhere(
          (element) {
            return element["original"]["filepath"] == entity.path;
          },
          orElse: () => {},
        );

        if (mapfile.isEmpty) {
          _files.add((await _addto(entity.path)).copyWith(type: type));
        } else {
          _files.add(UMF.parse(mapfile).copyWith(type: type));
        }
      }
      _files.sort((a, b) =>
          (a.name ?? "").toLowerCase().compareTo((b.name ?? "").toLowerCase()));
      _helper.write(_files);
    }
    return _files;
  }

  listener(FileSystemEvent event, ObjectType type) async {
    if (event is FileSystemCreateEvent) {
      if (event.isDirectory) return;
      _files.add((await _addto(event.path)).copyWith(type: type));
    } else if (event is FileSystemDeleteEvent) {
      if (event.isDirectory) return;
      _remove(event.path);
    } else if (event is FileSystemMoveEvent) {
      if (event.isDirectory) return;
      _files.add((await _addto(event.path)).copyWith(type: type));
      _remove(event.destination!);
    }
    _files.sort((a, b) =>
        (a.name ?? "").toLowerCase().compareTo((b.name ?? "").toLowerCase()));
    print("added");
    _helper.save(files);
    notifyListeners();
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
  }

  static Future<UMF> _addto(String filepath) async {
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
    print("t");
    return file;
    // helper.save(_files);
  }

  static Future<UMF> getFileData(String filepath) async {
    return CurseforgeFiles().getFileData(filepath);
  }
}
