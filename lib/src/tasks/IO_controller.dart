import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive_io.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mclauncher4/src/get_api_handler.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/install_controller.dart';
import 'package:mclauncher4/src/tasks/models/download_states.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:path/path.dart' as pathbase;
import 'package:uuid/uuid.dart';

class ImportExportController with ChangeNotifier {
  double _progress = 0.0;
  ExportImport _state = ExportImport.notHandeled;

  double get progress => _progress;
  ExportImport get state => _state;

  void import(filepath) async {
    String process_id = Uuid().v1();
    String path = await getTempCommandPath() + "\\$process_id";

    print("extracting");
    Utils.extractZip(File(filepath).readAsBytesSync(), path);
    Map pixieIndexJson = jsonDecode(File(path + "\\pixie.index.json").readAsStringSync());
    pixieIndexJson["processId"] = process_id;

    await Utils.copyDirectory(
        Directory(path + pixieIndexJson["override"]), Directory("${await getinstances()}\\instance\\$process_id"));

    Api api = ApiHandler().getApi(pixieIndexJson["provider"]);
    print(pixieIndexJson["providerArgs"]);
    InstallController installController =
        InstallController(processid: process_id, handler: api, modpackData: pixieIndexJson["providerArgs"]);
    installController.install();
  }

  Future export(String processId, List<FileSystemEntity> files, String filename) async {
    List manifest = jsonDecode(File(await getinstances() + "\\instance\\manifest.json").readAsStringSync());

    for (Map modpack in manifest) {
      if (modpack["processId"] == processId) {
        String? pathTo = await FilePicker.platform
            .saveFile(dialogTitle: "Save your project", fileName: filename + ".mcmp", lockParentWindow: true);
        if (pathTo == null) return;

        print('exportModpack in modrinth');
        _state = ExportImport.exporting;
        notifyListeners();

        String path = pathbase.join(await getTempCommandPath(), "export-$processId", "override");

        await Directory(path).create(recursive: true);

        for (var i = 0; i < files.length; i++) {
          FileSystemEntity file = files[i];
          String desinationPath = path + "\\" + file.path.replaceFirst(await getInstancePath() + "\\$processId", "");
          if (file is File) {
            print(desinationPath);
            String parentDirectory = pathbase.dirname(desinationPath);
            await Directory(parentDirectory).create(recursive: true);
            await File(desinationPath).writeAsBytes(await file.readAsBytes());
          } else if (file is Directory) {
            await Directory(desinationPath).create();
          }

          _progress = i / files.length;
          notifyListeners();
        }

        // await Utils.copyDirectory(
        //     Directory(await getInstancePath() + "\\$processId"),
        //     Directory(path + "\\override"));
        _state = ExportImport.fetching;
        notifyListeners();

        await Future.delayed(Duration(milliseconds: 200));

        String dirpath = pathbase.join(await getTempCommandPath(), "export-$processId");

        File pixieIndex = File(dirpath + "\\pixie.index.json");
        modpack["override"] = "/override";
        pixieIndex.createSync();
        pixieIndex.writeAsStringSync(jsonEncode(modpack));

        var encoder = ZipFileEncoder();

        encoder.create(pathTo);
        print("after create");
        await encoder.addDirectory(
          Directory(dirpath),
          includeDirName: false,
        );
        print("add dir");
        encoder.close();
        print("after close");
        await Directory(dirpath).delete(recursive: true);
      }
    }
  }
}
