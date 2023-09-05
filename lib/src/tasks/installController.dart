import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/forge/forge.dart';
import 'package:mclauncher4/src/tasks/forgeversion.dart';
import 'package:mclauncher4/src/tasks/minecraft/client.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/version.dart';

class InstallController with ChangeNotifier {
  Forge _forge = Forge();
  Minecraft _minecraft = Minecraft();

  install(Api _handler, Map modpackVersion) async {



          // await _handler.downloadModpack(
          //     modpackVersion, modpackVersion["project_id"]);

   Map versions = await _handler.getMMLVersion(modpackVersion, modpackVersion["project_id"]);


    Version version = versions["version"];
    ForgeVersion forgeVersion = versions["modloader"];

    _minecraft.addListener(() {
      print('${_minecraft.installstate} ${_minecraft.progress}');
    });
    _forge.addListener(() {
      print('${_forge.installstate} ${_forge.progress}');
    });

    String mfilePath =
        '${await getworkpath()}\\versions\\$version\\$version.json';
    String ffilePath =
        '${await getworkpath()}\\versions\\$version-forge-$forgeVersion\\$version-forge-$forgeVersion.json';
    if (!(await File(mfilePath).exists())) {
      print('need to install minecraft: $version');
      print(mfilePath);
      await _minecraft.install(version);
    }
    if (!(await File(ffilePath).exists())) {
      print('need to install forge: $version-$forgeVersion');
      await _forge.install(version, forgeVersion);
    }

    _forge.run(modpackVersion["project_id"], version, forgeVersion);
  }
}
