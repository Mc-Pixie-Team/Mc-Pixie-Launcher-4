import 'dart:io';

import 'package:mclauncher4/src/get_api_handler.dart';
import 'package:mclauncher4/src/tasks/apis/files/curseforge.files.dart';
import 'package:mclauncher4/src/tasks/install_controller.dart';
import 'package:mclauncher4/src/tasks/installs/install_model.dart';
import 'package:mclauncher4/src/tasks/models/object_type.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';

class InstallObjectHandler {
  InstallObjectHandler({required this.types, required this.path});

  List<InstallController> installControllers = [];
  List<InstallController> globalInstallControllers = [];
  List<ObjectType> types;
  String path;

  initializing() async {
    var files = Directory(path).listSync();

    for (var file in files) {
      var modpackData = await _lookup(file.path);
      var install_controller = InstallController(
          installState: InstallState.installed,
          handler: ApiHandler().getApi(modpackData.providerId),
          modpackData: modpackData);

          if(modpackData.type == ObjectType.modpack) {
            globalInstallControllers.add(install_controller);
          }else {
            installControllers.add(install_controller);
          }
      }    
  }

  Future<UMF> _lookup(String path) async {
    return await CurseforgeFiles().getFileData(path);
  }
}
