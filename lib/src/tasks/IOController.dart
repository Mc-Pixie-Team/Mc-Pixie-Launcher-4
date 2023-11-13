import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive_io.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mclauncher4/src/getApiHandler.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/installController.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:path/path.dart' as pathbase;
import 'package:uuid/uuid.dart';

class ImportExportController {
  void import(filepath) async {
    String process_id = Uuid().v1();
    String path = await getTempCommandPath() + "\\$process_id";
    InstallController installController = InstallController(process_id);

    print("extracting");
    Utils.extractZip(File(filepath).readAsBytesSync(), path);
    Map pixieIndexJson =
        jsonDecode(File(path + "\\pixie.index.json").readAsStringSync());
    pixieIndexJson["processId"] = process_id;

    await Utils.copyDirectory(Directory(path + pixieIndexJson["override"]),
        Directory("${await getinstances()}\\instance\\$process_id"));

    Api api = ApiHandler().getApi(pixieIndexJson["provider"]);
    print(pixieIndexJson["providerArgs"]);
    installController.install(api, pixieIndexJson["providerArgs"]);
  }

  void export(String processId, List<FileSystemEntity> files) async {
    List manifest = jsonDecode(
        File(await getinstances() + "\\instance\\manifest.json")
            .readAsStringSync());

    for (Map modpack in manifest) {
      if (modpack["processId"] == processId) {
        String? pathTo = await FilePicker.platform.saveFile(
            dialogTitle: "Save your project", fileName: "project.mcmp");
        if (pathTo == null) return;

        print('exportModpack in modrinth');
        var encoder = ZipFileEncoder();
        String path = pathbase.join( await getTempCommandPath(), "export-$processId") ;

        await Directory(path).create();


        for (FileSystemEntity file in files){
          String desinationPath =  path +"\\"+ file.path.replaceFirst(await getInstancePath() + "\\$processId", "");
          if(file is File) {

          

            print(desinationPath);
           String parentDirectory = pathbase.dirname(desinationPath);
           await Directory(parentDirectory).create(recursive: true);
          await File(desinationPath).writeAsBytes(await file.readAsBytes());

          }else if(file is Directory) {

           await Directory(desinationPath).create();

          }

        }
        // await Utils.copyDirectory(
        //     Directory(await getInstancePath() + "\\$processId"),
        //     Directory(path + "\\override"));

        File pixieIndex = File(path + "\\pixie.index.json");
        modpack["override"] = "/override";
        pixieIndex.createSync();
        pixieIndex.writeAsStringSync(jsonEncode(modpack));

        encoder.create(pathTo);

        await encoder.addDirectory(Directory(path), includeDirName: false);
        encoder.close();

        await Directory(path).delete(recursive: true);
      }
    }
  }
}
