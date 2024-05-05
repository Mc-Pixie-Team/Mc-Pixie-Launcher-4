import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/get_api_handler.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/install_controller.dart';
import 'package:mclauncher4/src/tasks/models/download_states.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/tasks/models/value_notifier_list.dart';
import 'package:mclauncher4/src/widgets/cards/installed_card.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';

import 'package:path/path.dart' as path;

class InstalledModpacksHandler {
  static generateManifest() async {
    File manifest = File("${ getInstancePath()}/manifest.json");
    if (manifest.existsSync()) return;
    manifest.createSync(recursive: true);
    manifest.writeAsStringSync("[]");
  }

  static ValueNotifierList<Widget> globalinstallContollers = ValueNotifierList([]);
  static Future<List<Widget>> getPacksformManifest() async {
    
    List manifest =  jsonDecode(await File(path.join(getInstancePath(), "manifest.json")).readAsString());

    return List.generate(manifest.length, (index) {
      Api _handler = ApiHandler().getApi(manifest[index]["provider"]);

      InstallController installcontroller = InstallController(
          replace: false,
          mainstate: MainState.installed,
          processid: manifest[index]["processId"],
          handler: _handler,
          modpackData: UMF.parse(manifest[index])); // MainState.installed

      return AnimatedBuilder(
        animation: installcontroller,
        key: Key(installcontroller.processId),
        builder: (context, child) => InstalledCard(
          stdout: installcontroller.stdout,
          processId: installcontroller.processId,
          modpackData: installcontroller.modpackData,
          state: installcontroller.state,
          progress: installcontroller.progress,
          onCancel: installcontroller.cancel,
          onDelete: installcontroller.delete,
          onOpen: installcontroller.start
        ),
      );
    });
  }
}


class InstalledModpacksUIHandler {
  //test

  static ValueNotifierList<Widget> installCardChildren = ValueNotifierList([]);

}

