import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mclauncher4/src/getApiHandler.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/installController.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:uuid/uuid.dart';

class ImportExportController {
  void import(filepath) async{

     String process_id = Uuid().v1();
     String path = await getTempCommandPath() + "\\$process_id";
     InstallController installController = InstallController(process_id);

      print("extracting");
      Utils.extractZip(File(filepath).readAsBytesSync(),  path);
      Map pixieIndexJson = jsonDecode(File(path + "\\pixie.index.json").readAsStringSync());
      pixieIndexJson["processId"] = process_id;

      Utils.copyDirectory(Directory(path + pixieIndexJson["override"]), Directory(await getinstances() + "\\instance\\${process_id}"));

    Api api = ApiHandler().getApi(pixieIndexJson["provider"]);

    installController.install(api, pixieIndexJson["providerArgs"]);

  }
  void export(String processId) async{
   List manifest = jsonDecode( File(await getinstances() + "\\instance\\manifest.json").readAsStringSync());
    
    for (Map modpack in manifest) {
      if( modpack["processId"] == processId) {
       
        _compareMods(modpack);
      }
    }

  }

  void _compareMods(Map modpack) {
     var encoder = ZipFileEncoder();

   Api _handler = ApiHandler().getApi(modpack["provider"]);


    

  }

}