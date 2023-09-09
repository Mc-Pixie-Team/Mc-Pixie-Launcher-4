import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/fabric/fabric.dart';
import 'package:mclauncher4/src/tasks/forge/forge.dart';
import 'package:mclauncher4/src/tasks/minecraft/client.dart';
import 'package:mclauncher4/src/tasks/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/modloaders.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/version.dart';

class InstallController with ChangeNotifier {
  Modloader? _modloader;
  Minecraft _minecraft = Minecraft();

  install(Api _handler, Map modpackVersion) async {
    String mloaderS = modpackVersion["loaders"].first;
     await _handler.downloadModpack(modpackVersion, modpackVersion["id"]);

    Map versions = await _handler.getMMLVersion(
        modpackVersion, modpackVersion["id"], mloaderS);

    Version version = versions["version"];
    ModloaderVersion modloaderVersion = versions["modloader"];

    if (mloaderS == "forge") {
      _modloader = Forge();
    } else if (mloaderS == "fabric") {
      _modloader = Fabric();
    }

    _minecraft.addListener(() {
      print('${_minecraft.installstate} ${_minecraft.progress}');
    });
    String mfilePath =
        '${await getworkpath()}\\versions\\$version\\$version.json';

    if (!(await File(mfilePath).exists())) {
      print('need to install minecraft: $version');
      print(mfilePath);
      await _minecraft.install(version);
    }

    if (_modloader == null) throw 'no modloader was found';

    _modloader!.addListener(() {
      print(
          'state: ${_modloader!.installstate}, progress: ${_modloader!.progress}');
    });

    if (_checkForInstall(
        await _modloader!.getSafeDir(version, modloaderVersion))) {
      print('need to install $mloaderS: $version-$modloaderVersion');
     await _modloader!.install(version, modloaderVersion);
    }
      print('trying to start...');
    _modloader!.run(modpackVersion["id"], version, modloaderVersion);
  }

  bool _checkForInstall(String path) {
    return (!(File(path).existsSync()));
  }
}
