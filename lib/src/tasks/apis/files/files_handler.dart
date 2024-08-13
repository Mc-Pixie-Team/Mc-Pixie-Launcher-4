import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mclauncher4/src/tasks/apis/curseforge.api.dart';
import 'package:mclauncher4/src/tasks/apis/files/curseforge.files.dart';
import 'package:mclauncher4/src/tasks/apis/files/files_helper.dart';
import 'package:mclauncher4/src/tasks/install_controller.dart';
import 'package:mclauncher4/src/tasks/installs/install_model.dart';
import 'package:mclauncher4/src/tasks/models/disposable_stream.dart';
import 'package:mclauncher4/src/tasks/models/object_type.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:path/path.dart' as p;

class FilesHandler extends DisposableWidget with ChangeNotifier  {
  FilesHandler({required this.directoryPath, required this.types, required this.processId});
  List<String> subDirs = [];
  List<ObjectType> types;
  String processId;
  String directoryPath;
  List<InstallController> _files = [];

  List<InstallController> get files => _files;

  bool get isdisposed => _isdisposed;
  bool _isdisposed = false;

  Isolate? _isolate;

  late FileHelper _helper;

  void initialize() async {
    _helper = FileHelper(directoryPath: directoryPath);
    _isdisposed = false;

   var token = RootIsolateToken.instance!;

   final resultPort = ReceivePort();
   _isolate = await Isolate.spawn(initializeContainingFiles, [ this.directoryPath, this.types,  token, this.processId ,resultPort.sendPort ]);

  _files.addAll(await resultPort.first);


   notifyListeners();

    for (var type in types) {
      var subDir = ObjectTypeTools.todir(type);
      var dir = Directory(p.join(directoryPath, subDir));
      if(!dir.existsSync()) dir.createSync(recursive: true);
    dir.watch().listen((event) => listener(event, type)).canceledBy(this);
  }
    
  }

  static addInstallController(List<InstallController> list, UMF umf, String processId) {
      list.add(  InstallController(handler: CurseforgeApi(), modpackData: umf, installState: InstallState.installed));
  }

  static Future<List<UMF>> initializeContainingFiles(List args) async {
     String directoryPath = args[0];
     List<ObjectType> types = args[1];
     RootIsolateToken token = args[2];
     String processId = args[3];
     SendPort responsePort = args[4];

     BackgroundIsolateBinaryMessenger.ensureInitialized(token);

    List<InstallController> _files = [];
    var _helper = FileHelper(directoryPath: directoryPath);

    var instanceFile = File(p.join(directoryPath, "manifest.json"));

    if (!instanceFile.existsSync()) {
      instanceFile.createSync();
      instanceFile.writeAsStringSync('[]');
    }

    List instance = jsonDecode(instanceFile.readAsStringSync());

   
    for (var type in types) {
      var subDir = ObjectTypeTools.todir(type);
      var dir = Directory(p.join(directoryPath, subDir));
      if(!dir.existsSync()) dir.createSync(recursive: true);
      var items = dir.listSync();

      //Check if all items in directory are in instance
      for (var entity in items) {
        print("in file");
        Map mapfile = instance.singleWhere(
          (element) {
            var lol = p.equals(element["original"]["filepath"], entity.path);
            if(lol) print("${entity.path}  | ${element["original"]["filepath"]}");
            return lol;
          },
          orElse: () => {},
        );

        if (mapfile.isEmpty) {
          addInstallController(_files, (await _addto(entity.path, type)).copyWith(type: type), processId );
        } else {
         addInstallController(_files, UMF.parse(mapfile).copyWith(type: type), processId );
        }
      }
      _files.sort((a, b) =>
          (a.modpackData.name ?? "").toLowerCase().compareTo((b.modpackData.name ?? "").toLowerCase()));
      _helper.write(List.generate(_files.length, (index) => _files[index].modpackData));
    }
    Isolate.exit(responsePort, _files);
  }

  listener(FileSystemEvent event, ObjectType type) async {
    if (event is FileSystemCreateEvent) {
      if (event.isDirectory) return;
      addInstallController(_files, (await _addto(event.path, type)).copyWith(type: type), processId );
    } else if (event is FileSystemDeleteEvent) {
      if (event.isDirectory) return;
      _remove(event.path);
    } else if (event is FileSystemMoveEvent) {
      if (event.isDirectory) return;
      addInstallController(_files, (await _addto(event.path, type)).copyWith(type: type), processId );
      _remove(event.destination!);
    }
    _files.sort((a, b) =>
        (a.modpackData.name ?? "").toLowerCase().compareTo((b.modpackData.name ?? "").toLowerCase()));
    print("added");
    

    _helper.save(List.generate(files.length, (index) => files[index].modpackData));
    notifyListeners();
  }
  @override
  void dispose() {
    if(_isolate != null) {
      _isolate!.kill();
    }
    
    cancelSubscriptions();
    _isdisposed = true;
    super.dispose();
  }

  void _remove(String filepath) {
    _files.removeWhere((element) {
      return p.equals(element.modpackData.original["filepath"], filepath);
    });
  }

  static Future<UMF> _addto(String filepath, ObjectType type) async {
    UMF file;
    try {
      file = await getFileData(filepath);
    } catch (e) {
      file = UMF(
        providerId: "NA",
        original: {"filepath": filepath},
        name: p.basename(filepath),
        author: "unknown",
        slug: "N/A",
        type: type,
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
