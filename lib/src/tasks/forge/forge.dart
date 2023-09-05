import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:mclauncher4/src/tasks/downloadState.dart';

import 'package:mclauncher4/src/tasks/forge/processor.dart';
import "package:path_provider/path_provider.dart" as path_provider;
import 'package:mclauncher4/src/tasks/forgeversion.dart';
import 'package:mclauncher4/src/tasks/minecraft/client.dart';
import 'package:mclauncher4/src/tasks/utils/downloads.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:mclauncher4/src/tasks/version.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;
import '../utils/path.dart';

class Forge with ChangeNotifier {
  
  ForgeInstallState  _state = ForgeInstallState .downloadingClient;
  ForgeInstallState  get installstate => _state;
  double _progress = 0.0;
  double get progress => _progress;

  //1.19.4-forge-45.1.16

  //  Version version = Version(1, 12, 2);
  // ForgeVersion forgeVersion = ForgeVersion(14, 23, 5, 2860);

  //   Version version = Version(1, 18, 1);
  // ForgeVersion forgeVersion = ForgeVersion(39, 1, 2);

  String os = "windows";
  run(String instanceName, Version version, ForgeVersion forgeVersion) async {

    Map vanillaVersionJson = (jsonDecode(
        await File("${await getworkpath()}\\versions\\$version\\$version.json")
            .readAsString()));

    Map versionJson = (jsonDecode(await File(
            "${await getworkpath()}\\versions\\$version-forge-$forgeVersion\\$version-forge-$forgeVersion.json")
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

       if(versionJson["arguments"]["jvm"] != null) {
         (vanillaVersionJson["arguments"]["jvm"] as List)
          .addAll(versionJson["arguments"]["jvm"]);
       }
      if(versionJson["arguments"]["game"] != null) {
              (vanillaVersionJson["arguments"]["game"] as List)
          .addAll(versionJson["arguments"]["game"]);
      }

    }

    String launchcommand = await Minecraft()
        .getlaunchCommand(instanceName, vanillaVersionJson, os, version, forgeVersion,);

    print(launchcommand);
    var tempFile = File(
        "${(await path_provider.getTemporaryDirectory()).path}\\pixie\\temp_command.ps1");
    await tempFile.create(recursive: true);
    await tempFile.writeAsString(launchcommand);

    var result = await Process.start(
        "powershell", ["-ExecutionPolicy", "Bypass", "-File", tempFile.path],
        runInShell: true, workingDirectory: "${await getworkpath()}");

    stdout.addStream(result.stdout);
    stderr.addStream(result.stderr);
  }

  install(Version version, ForgeVersion forgeVersion, [additional]) async {
    Map versionJson = Map();

    print("installing now: $version-$forgeVersion");
    //example: https://maven.minecraftforge.net/net/minecraftforge/forge/1.19.4-45.1.16/forge-1.19.4-45.1.16-installer.jar

    if(version < Version(1, 10,2) && additional == null){
      additional = version.toString();
      print('set additional');
    }

    await Download().downloadForgeClient(version, forgeVersion, additional);

    Map install_profileJson = jsonDecode(await File(
            "${await getTempForgePath()}\\${version.toString()}\\${forgeVersion.toString()}\\install_profile.json")
        .readAsString());

    String versionJsonPath =
        "${await getTempForgePath()}\\${version.toString()}\\${forgeVersion.toString()}\\version.json";
    if (File(versionJsonPath).existsSync()) {
      versionJson = jsonDecode(await File(
              "${await getTempForgePath()}\\${version.toString()}\\${forgeVersion.toString()}\\version.json")
          .readAsString());
    } else {
      versionJson = Utils.convertLibraries(install_profileJson["versionInfo"]);
    }

   // print(versionJson);
    Download _downloader = Download();
    Processor _processor = Processor();
    _downloader.addListener(() {
      if (_downloader.downloadstate == DownloadState.downloadingLibraries) {
        
        _progress = _downloader.progress;
        _state == ForgeInstallState.downloadingLibraries;
        notifyListeners();
      }
    });

    _processor.addListener(() { 
      if(_state ==ForgeInstallState.patching){
        _progress = _processor.progress;
         notifyListeners();
      }
    });



    _state = ForgeInstallState.downloadingLibraries;
    await _downloader.downloadLibaries(
        install_profileJson, version, forgeVersion);
    _state = ForgeInstallState.patching;
    await _processor.run(install_profileJson, version, forgeVersion);
    //install_profile is finished

    _state = ForgeInstallState.downloadingLibraries;
    await _downloader.downloadLibaries(versionJson, version, forgeVersion);
    await _downloader.getOldUniversal(
        install_profileJson, version, forgeVersion);
    await _createVersionDir(versionJson, version, forgeVersion);
    //version is finished
    _state = ForgeInstallState.finished;
    notifyListeners();
  }

  _createVersionDir(
      Map versionJson, Version version, ForgeVersion forgeVersion) async {
    String filepath =
        "${await getworkpath()}\\versions\\$version-forge-$forgeVersion\\$version-forge-$forgeVersion.json";
    String parentDirectory = path.dirname(filepath);
    await Directory(parentDirectory).create(recursive: true);
    await File(filepath).writeAsString(jsonEncode(versionJson));
   // created versionsDir
  }



}