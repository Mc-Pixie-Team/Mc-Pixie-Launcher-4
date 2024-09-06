import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mclauncher4/src/get_api_handler.dart';
import 'package:mclauncher4/src/tasks/apis/files/curseforge.files.dart';
import 'package:mclauncher4/src/tasks/install_controller.dart';
import 'package:mclauncher4/src/tasks/installs/install_model.dart';
import 'package:mclauncher4/src/tasks/models/object_type.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/tasks/models/value_notifier_list.dart';

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class InstallObjectHandler with ChangeNotifier {
  InstallObjectHandler(
      {required this.types, required this.path, this.processId});

  Completer completer = Completer();

  List<UMF> modpacksData = [];
  ValueNotifierList<InstallController> installControllers =
      ValueNotifierList([]);

  List<ObjectType> types;
  String? processId;
  String path;
  bool isdisposed = false;
  bool isFetching = true;
  Timer? _timer;

  bool isSomethingInstalling() {
    for (var installController in installControllers.value) {
      if (installController.installModel.installState ==
          InstallState.installing) {
        print("found one that is installing.. Quiting");
        return true;
      }
    }

    return false;
  }

  initialize() async {
    isFetching = true;
    var manifestPath = p.join(path, "manifest.json");
    var file = File(manifestPath);

    print("file: ${file.path}, EXISTS: ${file.existsSync()}");
    if (!file.existsSync()) {
      
      var dir = Directory( p.dirname(file.path));
      print(dir.path);
      if(!dir.existsSync()) {
       await dir.create(recursive: true);
      } 
      await file.create();
      await file.writeAsString("[]");
    }

    List rawInstalledObjects = jsonDecode(await file.readAsString());
    List<UMF> installedObjects = List.generate(rawInstalledObjects.length,
        (index) => UMF.parse(rawInstalledObjects[index]));
    for (var type in types) {
      
      await _syncType(type, manifestPath, installedObjects);

      var dir = Directory(p.join(path, ObjectTypeTools.todir(type)));
      print("DONE WITH FIRST SYNCING: $type");

      if (type == ObjectType.modpack) return;
      dir.watch().listen((event) async {
        if (isSomethingInstalling()) {
          print("skap");
          return;
        }
        print("evetbuo");
        if (_timer != null) {
          print("cancle");
          _timer!.cancel();
        }

        _timer = Timer(
            Duration(seconds: 1),
            () => _syncType(
                type, p.join(path, "manifest.json"), installedObjects));
      });
    }
    isFetching = false;
    notifyListeners();
  }
  @override
  dispose() {
    completer.complete();
    isdisposed = true;
    super.dispose();
  }

  Future _syncType(
      ObjectType type, String manifestPath, List<UMF> installedObjects) async {
    print("sync NOW");
    modpacksData.clear();
    print(manifestPath);
    var file = File(manifestPath);

    var dir = Directory(p.join(path, ObjectTypeTools.todir(type)));

    if (!dir.existsSync()) await dir.create(recursive: true);

    if(type != ObjectType.modpack) {
    var files = dir.listSync();
    var filePaths = List.generate(files.length, (index) => files[index].path);
    outerloop:
    for (var filePath in filePaths) {
      if (completer.isCompleted) return;
      for (var installedObject in installedObjects) {
        if (installedObject.objectPath != null && p.equals(installedObject.objectPath!, filePath)) {
          modpacksData.add(installedObject);
          print("added from down ${installedObject.name}");
          continue outerloop;
        }
      }
      modpacksData.addAll(await _searchFiles(filePath, installedObjects, type));
    }
    }else {
      for (var installedObject in installedObjects) {

        modpacksData.add(installedObject);
      }
    }

    installControllers.value.removeWhere(
      (element) => element.modpackData.type == type,
    );

    for (var modpackData in modpacksData) {
      print(modpackData.name);
      var install_controller = InstallController(
          installObjectHandler: this,
          rootProcessId: this.processId,
          processid: modpackData.processId,
          installState: InstallState.installed,
          handler: modpackData.providerId == null ? null : ApiHandler().getApi(modpackData.providerId!),
          modpackData: modpackData);
      installControllers.value.add(install_controller);
    }

    await file.writeAsString(jsonEncode(List.generate(
        installControllers.value.length,
        (index) => UMF.toJson(installControllers.value[index].modpackData))));
    installControllers.trigger();
  }

  Future<List<UMF>> _searchFiles(String files, installedObjects, type) {
    var rootToken = RootIsolateToken.instance!;

    return Isolate.run(() async {
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);

      return await _generateList(files, installedObjects, type);
    });
  }

  static Future<List<UMF>> _generateList(
      String filePath, List<UMF> installedObjects, ObjectType type) async {
    List<UMF> modpacksData = [];


    if (type != ObjectType.modpack) {
      var modpackData = await _lookup(filePath);
      if (modpackData == null) return modpacksData;
      modpacksData.add(modpackData.copyWith(type: type, objectPath: filePath));
    }

    return modpacksData;
  }

  static Future<UMF?> _lookup(String path) async {
    var retu;  

    try {
     retu = await CurseforgeFiles().getFileData(path);
    } catch (e) {
      print(e);
      retu = UMF(objectPath: path, versionName: "0.0.0.1",  name: p.basename(path), author: "unknown",  type: ObjectType.mod, slug: Uuid().v1(), providerId: "curseforge",  original: {});
    }

    return retu;
  }
}
