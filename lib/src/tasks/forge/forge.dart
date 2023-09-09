import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:mclauncher4/src/tasks/downloadState.dart';
import 'package:mclauncher4/src/tasks/modloaders.dart';
import '../modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/forge/processor.dart';
import "package:path_provider/path_provider.dart" as path_provider;
import 'package:mclauncher4/src/tasks/minecraft/client.dart';
import 'package:mclauncher4/src/tasks/utils/downloads.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:mclauncher4/src/tasks/version.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;
import '../utils/path.dart';

class Forge extends Modloader{
  ForgeInstallState _state = ForgeInstallState.downloadingClient;
  @override
  ForgeInstallState get installstate => _state;
  double _progress = 0.0;
  @override
  double get progress => _progress;
    @override
    getSafeDir(Version version, ModloaderVersion modloaderVersion) async{
    return '${await getworkpath()}\\versions\\$version-forge-$modloaderVersion\\$version-forge-$modloaderVersion.json';
  }

  //1.19.4-forge-45.1.16

  //  Version version = Version(1, 12, 2);
  // ModloaderVersion ModloaderVersion = ModloaderVersion(14, 23, 5, 2860);

  //   Version version = Version(1, 18, 1);
  // ModloaderVersion ModloaderVersion = ModloaderVersion(39, 1, 2);

  String os = "windows";
  @override
  run(String instanceName, Version version,
      ModloaderVersion ModloaderVersion) async {
    Map vanillaVersionJson = (jsonDecode(
        await File("${await getworkpath()}\\versions\\$version\\$version.json")
            .readAsString()));

    Map versionJson = (jsonDecode(await File(
            "${await getworkpath()}\\versions\\$version-forge-$ModloaderVersion\\$version-forge-$ModloaderVersion.json")
        .readAsString()));

    List testlib = [];

    testlib.addAll(versionJson["libraries"]);
    testlib.addAll(vanillaVersionJson["libraries"]);

    vanillaVersionJson["libraries"] = testlib;
    vanillaVersionJson["mainClass"] = versionJson["mainClass"];
    if (version < Version(1, 13, 0)) {
      vanillaVersionJson["minecraftArguments"] =
          versionJson["minecraftArguments"];
    } else {
      if (versionJson["arguments"]["jvm"] != null) {
        (vanillaVersionJson["arguments"]["jvm"] as List)
            .addAll(versionJson["arguments"]["jvm"]);
      }
      if (versionJson["arguments"]["game"] != null) {
        (vanillaVersionJson["arguments"]["game"] as List)
            .addAll(versionJson["arguments"]["game"]);
      }
    }

    String launchcommand = await Minecraft().getlaunchCommand(
      instanceName,
      vanillaVersionJson,
      os,
      version,
      ModloaderVersion,
    );

    print(launchcommand);
    var tempFile = File(
        "${(await path_provider.getTemporaryDirectory()).path}\\pixie\\temp_command.ps1");
    await tempFile.create(recursive: true);
    await tempFile.writeAsString(launchcommand);

    var result = await Process.start(
        "powershell", ["-ExecutionPolicy", "Bypass", "-File", tempFile.path],
        runInShell: true,
        workingDirectory: '${await getInstancePath()}\\$instanceName');

    stdout.addStream(result.stdout);
    stderr.addStream(result.stderr);
  }
  @override
  install(Version version, ModloaderVersion modloaderVersion,
      [additional]) async {
    Map versionJson = Map();

    print("installing now: $version-$modloaderVersion");
    //example: https://maven.minecraftforge.net/net/minecraftforge/forge/1.19.4-45.1.16/forge-1.19.4-45.1.16-installer.jar

    if (version < Version(1, 10, 2) && additional == null) {
      additional = version.toString();
      print('set additional');
    }

    await Download().downloadForgeClient(version, modloaderVersion, additional);

    Map install_profileJson = jsonDecode(await File(
            "${await getTempForgePath()}\\${version.toString()}\\${modloaderVersion.toString()}\\install_profile.json")
        .readAsString());

    String versionJsonPath =
        "${await getTempForgePath()}\\${version.toString()}\\${modloaderVersion.toString()}\\version.json";
    if (File(versionJsonPath).existsSync()) {
      versionJson = jsonDecode(await File(
              "${await getTempForgePath()}\\${version.toString()}\\${modloaderVersion.toString()}\\version.json")
          .readAsString());
    } else {
      List additionalLibs = [];

      additionalLibs.add({
        "name": "net.minecraft:launchwrapper:1.12",
        "downloads": {
          "artifact": {
            "path": "net/minecraft/launchwrapper/1.12/launchwrapper-1.12.jar",
            "url":
                "https://libraries.minecraft.net/net/minecraft/launchwrapper/1.12/launchwrapper-1.12.jar",
            "size": 32999
          }
        }
      });
      additionalLibs.add({
        "name": "lzma:lzma:0.0.1",
        "downloads": {
          "artifact": {
            "path": "lzma/lzma/0.0.1/lzma-0.0.1.jar",
            "url":
                "https://phoenixnap.dl.sourceforge.net/project/kcauldron/lzma/lzma/0.0.1/lzma-0.0.1.jar",
            "size": 100000
          }
        }
      });
      additionalLibs.add({
        "name": "java3d:vecmath:1.5.2",
        "downloads": {
          "artifact": {
            "path": "java3d/vecmath/1.5.2/vecmath-1.5.2.jar",
            "url":
                "https://repo1.maven.org/maven2/javax/vecmath/vecmath/1.5.2/vecmath-1.5.2.jar",
            "size": 100000
          }
        }
      });

      List<String> ignoreList = [
        "net.minecraft:launchwrapper:1.12",
        "lzma:lzma:0.0.1",
        "java3d:vecmath:1.5.2"
      ];
      versionJson = Utils.convertLibraries(
          install_profileJson["versionInfo"], ignoreList, additionalLibs);
    }

    // print(versionJson);
    Download _downloader = Download();
    Processor _processor = Processor();
    _downloader.addListener(() {
      if (_downloader.downloadstate == DownloadState.downloadingLibraries) {
        _progress = _downloader.progress;
        _state = ForgeInstallState.downloadingLibraries;
        notifyListeners();
      }
    });

    _processor.addListener(() {
      if (_state == ForgeInstallState.patching) {
        _progress = _processor.progress;
        notifyListeners();
      }
    });

    _state = ForgeInstallState.downloadingLibraries;
    await _downloader.downloadLibaries(
        install_profileJson, version, modloaderVersion);
    _state = ForgeInstallState.patching;
    await _processor.run(install_profileJson, version, modloaderVersion);
    //install_profile is finished

    _state = ForgeInstallState.downloadingLibraries;
    await _downloader.downloadLibaries(versionJson, version, modloaderVersion);
    await _downloader.getOldUniversal(
        install_profileJson, version, modloaderVersion);
    await _createVersionDir(versionJson, version, modloaderVersion);
    //version is finished
    _state = ForgeInstallState.finished;
    notifyListeners();
  }

  _createVersionDir(Map versionJson, Version version,
      ModloaderVersion modloaderVersion) async {
    String filepath =
        "${await getworkpath()}\\versions\\$version-forge-$modloaderVersion\\$version-forge-$modloaderVersion.json";
    String parentDirectory = path.dirname(filepath);
    await Directory(parentDirectory).create(recursive: true);
    await File(filepath).writeAsString(jsonEncode(versionJson));
    // created versionsDir
  }
}
