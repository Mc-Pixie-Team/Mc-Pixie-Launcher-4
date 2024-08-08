import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/get_api_handler.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/install_controller.dart';

import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/tasks/models/value_notifier_list.dart';
import 'package:mclauncher4/src/tasks/installs/install_model.dart';
import 'package:mclauncher4/src/widgets/cards/installed_card.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/widgets/cards/recently_played_card.dart';

import 'package:path/path.dart' as path;

class InstalledModpacksHandler {
  static generateManifest() async {
    File manifest = File("${getInstancePath()}/manifest.json");
    if (manifest.existsSync()) return;
    manifest.createSync(recursive: true);
    manifest.writeAsStringSync("[]");
  }

  static ValueNotifierList<InstallController> globalInstallControllers = ValueNotifierList([]);

  static void getPacksformManifest() async {
    List manifest = jsonDecode(
        await File(path.join(getInstancePath(), "manifest.json"))
            .readAsString());

    for(var object in manifest) {   
      Api _handler = ApiHandler().getApi(object["provider"]);

      InstallController installcontroller = InstallController(
          installState: InstallState.installed,
          processid: object["processId"],
          handler: _handler,
          modpackData: UMF.parse(object));

      globalInstallControllers.value
          .removeWhere((element) {  
          if (element.processId == installcontroller.processId) return true;
        return false;
      });

      globalInstallControllers.add(installcontroller);
    }

  }
}


