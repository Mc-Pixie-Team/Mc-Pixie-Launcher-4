import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:mclauncher4/src/tasks/models/download_states.dart';
import 'package:mclauncher4/src/tasks/java/java.dart';
import 'package:mclauncher4/src/tasks/modloaders.dart';
import '../models/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/forge/processor.dart';
import "package:path_provider/path_provider.dart" as path_provider;
import 'package:mclauncher4/src/tasks/minecraft/minecraft_install.dart';
import 'package:mclauncher4/src/tasks/utils/downloads_utils.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;
import '../utils/path.dart';

class Forge with ChangeNotifier implements Modloader {
  ModloaderInstallState _state = ModloaderInstallState.downloadingClient;
  @override
  ModloaderInstallState get installstate => _state;
  double _progress = 0.0;
  @override
  double get progress => _progress;
  double _mainprogress = 0.0;
  double get mainprogress => _mainprogress;

  @override
  getSafeDir(Version version, ModloaderVersion modloaderVersion) async {
    return path.join(getworkpath(), "versions", "$version-forge-$modloaderVersion","$version-forge-$modloaderVersion.json" );
  }

  @override
  getsteps(Version version, [ModloaderVersion? modloaderVersion]) {
    if (version > Version(1, 12, 2)) {
      return 3;
    }
    return 2;
  }

  //1.19.4-forge-45.1.16

  //  Version version = Version(1, 12, 2);
  // ModloaderVersion ModloaderVersion = ModloaderVersion(14, 23, 5, 2860);

  //   Version version = Version(1, 18, 1);
  // ModloaderVersion ModloaderVersion = ModloaderVersion(39, 1, 2);

  String os = "windows";
  @override
  Future<Process> run(String instanceName, Version version, ModloaderVersion ModloaderVersion) async {
    Map vanillaVersionJson = 
        (jsonDecode(await File(path.join(getworkpath(), "versions", version.toString(), "$version.json")).readAsString()));

    Map versionJson = (jsonDecode(await File(
          path.join(getworkpath(), "versions", "$version-forge-$ModloaderVersion", "$version-forge-$ModloaderVersion.json"))
        .readAsString()));

    List testlib = [];

    testlib.addAll(versionJson["libraries"]);
    testlib.addAll(vanillaVersionJson["libraries"]);

    vanillaVersionJson["libraries"] = testlib;
    vanillaVersionJson["mainClass"] = versionJson["mainClass"];
    if (version < Version(1, 13, 0)) {
      vanillaVersionJson["minecraftArguments"] = versionJson["minecraftArguments"];
    } else {
      if (versionJson["arguments"]["jvm"] != null) {
        (vanillaVersionJson["arguments"]["jvm"] as List).addAll(versionJson["arguments"]["jvm"]);
      }
      if (versionJson["arguments"]["game"] != null) {
        (vanillaVersionJson["arguments"]["game"] as List).addAll(versionJson["arguments"]["game"]);
      }
    }

    List<String> launchcommand = await Minecraft().getlaunchCommand(
      instanceName,
      vanillaVersionJson,
      version,
      ModloaderVersion,
    );

    print(launchcommand);
    // var tempFile = File(
    //     "${(await path_provider.getTemporaryDirectory()).path}/pixie/temp_command.ps1");
    // await tempFile.create(recursive: true);
    // await tempFile.writeAsString(launchcommand);

    var result = await Process.start(Java.getJavaJdk(version), launchcommand,
        workingDirectory: path.join(getInstancePath(), instanceName));

    return result;
  }

  @override
  install(Version version, ModloaderVersion modloaderVersion, [additional]) async {
    Map versionJson = Map();

    print("installing now: $version-$modloaderVersion");
    //example: https://maven.minecraftforge.net/net/minecraftforge/forge/1.19.4-45.1.16/forge-1.19.4-45.1.16-installer.jar

    if (version < Version(1, 10, 2) && additional == null) {
      additional = version.toString();
      print('set additional');
    }

    await DownloadUtils().downloadForgeClient(version, modloaderVersion, additional);

    Map install_profileJson = jsonDecode(await File(
           path.join(getTempForgePath(), version.toString(), modloaderVersion.toString(), "install_profile.json"))
        .readAsString());

    String versionJsonPath =
       path.join(getTempForgePath(), version.toString(), modloaderVersion.toString(), "version.json");
    if (File(versionJsonPath).existsSync()) {
      versionJson = jsonDecode(
          await File(versionJsonPath)
              .readAsString());
    } else {
      List additionalLibs = [];

      additionalLibs.add({
        "name": "net.minecraft:launchwrapper:1.12",
        "downloads": {
          "artifact": {
            "path": "net/minecraft/launchwrapper/1.12/launchwrapper-1.12.jar",
            "url": "https://libraries.minecraft.net/net/minecraft/launchwrapper/1.12/launchwrapper-1.12.jar",
            "size": 32999
          }
        }
      });
      additionalLibs.add({
        "name": "lzma:lzma:0.0.1",
        "downloads": {
          "artifact": {
            "path": "lzma/lzma/0.0.1/lzma-0.0.1.jar",
            "url": "https://phoenixnap.dl.sourceforge.net/project/kcauldron/lzma/lzma/0.0.1/lzma-0.0.1.jar",
            "size": 100000
          }
        }
      });
      additionalLibs.add({
        "name": "java3d:vecmath:1.5.2",
        "downloads": {
          "artifact": {
            "path": "java3d/vecmath/1.5.2/vecmath-1.5.2.jar",
            "url": "https://repo1.maven.org/maven2/javax/vecmath/vecmath/1.5.2/vecmath-1.5.2.jar",
            "size": 100000
          }
        }
      });

      List<String> ignoreList = ["net.minecraft:launchwrapper:1.12", "lzma:lzma:0.0.1", "java3d:vecmath:1.5.2"];
      versionJson = Utils.convertLibraries(install_profileJson["versionInfo"], ignoreList, additionalLibs);
    }

    // print(versionJson);
    DownloadUtils _downloader = DownloadUtils();
    Processor _processor = Processor();
    var _1 = 0.0;
    var _2 = 0.0;
    var _raw = 0.0;
    _downloader.addListener(() {
      if (_downloader.downloadstate == DownloadState.downloadingLibraries) {
        print(getsteps(version));
        _raw += _downloader.progress - _1;
        _1 = _downloader.progress;
        _progress = _downloader.progress;
        _state = ModloaderInstallState.downloadingLibraries;
        _mainprogress = _raw / getsteps(version);
        notifyListeners();
      }
    });

    _processor.addListener(() {
      if (_state == ModloaderInstallState.patching) {
        _raw += _downloader.progress - _2;
        _2 = _downloader.progress;
        _progress = _processor.progress;
        _mainprogress = _raw / getsteps(version);
        notifyListeners();
      }
    });

    _state = ModloaderInstallState.downloadingLibraries;
    await _downloader.downloadLibaries(install_profileJson, version, modloaderVersion);
    _state = ModloaderInstallState.patching;
    await _processor.run(install_profileJson, version, modloaderVersion);
    //install_profile is finished

    _state = ModloaderInstallState.downloadingLibraries;
    _1 = 0.0;
    await _downloader.downloadLibaries(versionJson, version, modloaderVersion);
    await _downloader.getOldUniversal(install_profileJson, version, modloaderVersion);
    await _createVersionDir(versionJson, version, modloaderVersion);
    //version is finished
    _state = ModloaderInstallState.finished;
    notifyListeners();
  }

  _createVersionDir(Map versionJson, Version version, ModloaderVersion modloaderVersion) async {
    String filepath =
        path.join(getworkpath(), "versions", "$version-forge-$modloaderVersion", "$version-forge-$modloaderVersion.json");
    String parentDirectory = path.dirname(filepath);
    await Directory(parentDirectory).create(recursive: true);
    await File(filepath).writeAsString(jsonEncode(versionJson));
    // created versionsDir
  }
}
