import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/downloadState.dart';
import 'package:mclauncher4/src/tasks/minecraft/client.dart';
import 'package:mclauncher4/src/tasks/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/modloaders.dart';
import 'package:mclauncher4/src/tasks/utils/downloads.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:mclauncher4/src/tasks/version.dart';
import 'package:path/path.dart' as path;
import "package:path_provider/path_provider.dart" as path_provider;

class Fabric with ChangeNotifier implements Modloader  {
  FabricInstallState _state = FabricInstallState.downloadingLibraries;
  @override
  FabricInstallState get installstate => _state;
  double _progress = 0.0;
  @override
  double get progress => _progress;
  double _mainprogress = 0.0; 
  double get mainprogress => _mainprogress;
  
   @override
   getsteps(Version version, [ModloaderVersion? modloaderVersion]) {
    return 1;
   }


  @override
  getSafeDir(Version version, ModloaderVersion modloaderVersion) async{
    return "${await getworkpath()}\\versions\\fabric-loader-$modloaderVersion-$version\\fabric-loader-$modloaderVersion-$version.json";
  }
  @override
  run(String instanceName, Version version,
      ModloaderVersion modloaderVersion) async {
    Map vanillaVersionJson = (jsonDecode(
        await File("${await getworkpath()}\\versions\\$version\\$version.json")
            .readAsString()));

    Map versionJson = (jsonDecode(await File(
            "${await getworkpath()}\\versions\\fabric-loader-$modloaderVersion-$version\\fabric-loader-$modloaderVersion-$version.json")
        .readAsString()));

    List testlib = [];

    testlib.addAll(versionJson["libraries"]);
    testlib.addAll(vanillaVersionJson["libraries"]);

    vanillaVersionJson["libraries"] = testlib;
    vanillaVersionJson["mainClass"] = versionJson["mainClass"];

    if (versionJson["arguments"]["jvm"] != null) {
      (vanillaVersionJson["arguments"]["jvm"] as List)
          .addAll(versionJson["arguments"]["jvm"]);
    }
    if (versionJson["arguments"]["game"] != null) {
      (vanillaVersionJson["arguments"]["game"] as List)
          .addAll(versionJson["arguments"]["game"]);
    }

    String launchcommand = await Minecraft().getlaunchCommand(
      instanceName,
      vanillaVersionJson,
      "windows",
      version,
      modloaderVersion,
    );

    print(launchcommand);
    var tempFile = File(
        "${(await path_provider.getTemporaryDirectory()).path}\\pixie\\temp_command3.ps1");
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
  install(Version version, ModloaderVersion modloaderVersion, [additional]) async {
    var res = await http.get(Uri.parse(
        'https://meta.fabricmc.net/v2/versions/loader/$version/$modloaderVersion/profile/json'));

    Map profileJson = jsonDecode(utf8.decode(res.bodyBytes));

    profileJson = Utils.convertLibraries(profileJson, []);

    Download _downloader = Download();
    _downloader.addListener(() {
      if (_downloader.downloadstate == DownloadState.downloadingLibraries) {
         _mainprogress = _downloader.progress;
        _progress = _downloader.progress;
        _state = FabricInstallState.downloadingLibraries;
        notifyListeners();
      }
    });

    await _downloader.downloadLibaries(profileJson);
    await _createVersionDir(profileJson, version, modloaderVersion);
  }

  _createVersionDir(Map versionJson, Version version,
      ModloaderVersion modloaderVersion) async {
    String filepath =
        "${await getworkpath()}\\versions\\fabric-loader-$modloaderVersion-$version\\fabric-loader-$modloaderVersion-$version.json";
    String parentDirectory = path.dirname(filepath);
    await Directory(parentDirectory).create(recursive: true);
    await File(filepath).writeAsString(jsonEncode(versionJson));
    // created versionsDir
  }
}
