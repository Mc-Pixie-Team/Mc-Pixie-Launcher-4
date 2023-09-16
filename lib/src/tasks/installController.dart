import 'dart:io';

import 'package:dart_discord_rpc/generated/bindings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/apis/modrinth.download.dart';
import 'package:mclauncher4/src/tasks/downloadState.dart';
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
  MainState _mainState = MainState.notinstalled;

  double _progress = 0.0;
  double _mainprogress = 0.0;
  var _installState;

  get installState => _installState;
  double get progress => _progress;
  double get mainprogress => _mainprogress;
  MainState get mainState => _mainState;

  start(
    Api _handler,
    Map modpackVersion,
  ) async {
    String mloaderS = modpackVersion["loaders"].first;
    if (mloaderS == "forge") {
      _modloader = Forge();
    } else if (mloaderS == "fabric") {
      _modloader = Fabric();
    }
    if (_modloader == null) throw 'no modloader was found';
  	
    Map versions = await _handler.getMMLVersion(
        modpackVersion, modpackVersion["id"], mloaderS);
    Version version = versions["version"];
    ModloaderVersion modloaderVersion = versions["modloader"];
    _mainState = MainState.running;
    notifyListeners();
    _modloader!.run(modpackVersion["id"], version, modloaderVersion);
  }

  install(Api _handler, Map modpackVersion) async {
    ModrinthApiDownloader downloader = _handler.getDownloaderObject();
    String mloaderS = modpackVersion["loaders"].first;
    Version version = Version.parse(modpackVersion["game_versions"].first);

    if (mloaderS == "forge") {
      _modloader = Forge();
    } else if (mloaderS == "fabric") {
      _modloader = Fabric();
    }
    if (_modloader == null) throw 'no modloader was found';

    downloader.addListener(() {
      _mainState = MainState.downloadingMods;
      _mainprogress = downloader.progress;
      _progress = downloader.progress;
      notifyListeners();
    });

    _minecraft.addListener(() {
      // print('${_minecraft.installstate} ${_minecraft.progress}');
      _mainState = MainState.downloadingMinecraft;
      _installState = _minecraft.installstate;
      _mainprogress = _minecraft.mainprogress;
      _progress = _minecraft.progress;
      notifyListeners();
    });
    _modloader!.addListener(() {
      // print(
      //     'state: ${_modloader!.installstate}, progress: ${_modloader!.progress}');
      _mainState = MainState.downloadingML;
      _installState = _modloader!.installstate;
      _mainprogress = _modloader!.mainprogress;
      _progress = _modloader!.progress;
      notifyListeners();
    });

    await downloader.downloadModpack(modpackVersion, modpackVersion["id"]);
    Map versions = await _handler.getMMLVersion(
        modpackVersion, modpackVersion["id"], mloaderS);

    version = versions["version"];
    ModloaderVersion modloaderVersion = versions["modloader"];

    String mfilePath =
        '${await getworkpath()}\\versions\\$version\\$version.json';

    if (_checkForInstall(
        '${await getworkpath()}\\versions\\$version\\$version.json')) {
      print('need to install minecraft: $version');
      print(mfilePath);
      await _minecraft.install(version!);
    }

    if (_checkForInstall(
        await _modloader!.getSafeDir(version, modloaderVersion))) {
      print('need to install $mloaderS: $version-$modloaderVersion');
      await _modloader!.install(version, modloaderVersion);
    }
    print('trying to start...');
    _mainState = MainState.installed;
    notifyListeners();
    // _modloader!.run(modpackVersion["id"], version, modloaderVersion);
  }

  bool _checkForInstall(String path) {
    return (!(File(path).existsSync()));
  }
}
