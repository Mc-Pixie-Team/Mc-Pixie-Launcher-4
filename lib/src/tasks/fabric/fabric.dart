import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/models/download_states.dart';
import 'package:mclauncher4/src/tasks/java/java.dart';
import 'package:mclauncher4/src/tasks/minecraft/minecraft_install.dart';
import 'package:mclauncher4/src/tasks/models/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/modloaders.dart';
import 'package:mclauncher4/src/tasks/utils/downloads_utils.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:path/path.dart' as path;
import "package:path_provider/path_provider.dart" as path_provider;

class Fabric with ChangeNotifier implements Modloader {
  ModloaderInstallState _state = ModloaderInstallState.downloadingLibraries;
  @override
  ModloaderInstallState get installstate => _state;
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
  getSafeDir(Version version, ModloaderVersion modloaderVersion) async {
    return path.join(getworkpath(), "versions", "fabric-loader-$modloaderVersion-$version", "fabric-loader-$modloaderVersion-$version.json");
  }


  @override
  Future<Process> run(String instanceName, Version version, ModloaderVersion modloaderVersion) async {
    Map vanillaVersionJson =
        (jsonDecode(await File(path.join(getworkpath(), "versions", version.toString(), "$version.json")).readAsString()));

    Map versionJson = (jsonDecode(await File(
            path.join(getworkpath(), "versions", "fabric-loader-$modloaderVersion-$version", "fabric-loader-$modloaderVersion-$version.json"))
        .readAsString()));

    List testlib = [];

    testlib.addAll(versionJson["libraries"]);
    testlib.addAll(vanillaVersionJson["libraries"]);

    vanillaVersionJson["libraries"] = testlib;
    vanillaVersionJson["mainClass"] = versionJson["mainClass"];

    if (versionJson["arguments"]["jvm"] != null) {
      (vanillaVersionJson["arguments"]["jvm"] as List).addAll(versionJson["arguments"]["jvm"]);
    }
    if (versionJson["arguments"]["game"] != null) {
      (vanillaVersionJson["arguments"]["game"] as List).addAll(versionJson["arguments"]["game"]);
    }

    List<String> launchcommand = await Minecraft().getlaunchCommand(
      instanceName,
      vanillaVersionJson,
      version,
      modloaderVersion,
    );

    print(launchcommand);
    // var tempFile = File(
    //     "${(await path_provider.getTemporaryDirectory()).path}\\pixie\\temp_command3.ps1");
    // await tempFile.create(recursive: true);
    // await tempFile.
    // writeAsString(launchcommand);

    String exec = Java.getJavaJdk(version);
    print(exec);

    var result =
        await Process.start(exec, launchcommand, workingDirectory: path.join(getInstancePath(), instanceName));

    // stdout.addStream(result.stdout);
    // stderr.addStream(result.stderr);

    // print(result.pid);

    //  Future.delayed(Duration(seconds: 15)).then((value) {
    //   print('trying to kill with pid');
    //   Process.killPid(result.pid);
    //  });

    return result;
  }

  @override
  install(Version version, ModloaderVersion modloaderVersion, [additional]) async {
    var res = await http
        .get(Uri.parse('https://meta.fabricmc.net/v2/versions/loader/$version/$modloaderVersion/profile/json'));

    Map profileJson = jsonDecode(utf8.decode(res.bodyBytes));

    profileJson = Utils.convertLibraries(profileJson, []);

    DownloadUtils _downloader = DownloadUtils();
    _downloader.addListener(() {
      if (_downloader.downloadstate == DownloadState.downloadingLibraries) {
        _mainprogress = _downloader.progress;
        _progress = _downloader.progress;
        _state = ModloaderInstallState.downloadingLibraries;
        notifyListeners();
      }
    });

    await _downloader.downloadLibaries(profileJson);
    await _createVersionDir(profileJson, version, modloaderVersion);
  }

  _createVersionDir(Map versionJson, Version version, ModloaderVersion modloaderVersion) async {
    String filepath =
       path.join(getworkpath(), "versions", "fabric-loader-$modloaderVersion-$version", "fabric-loader-$modloaderVersion-$version.json");
    String parentDirectory = path.dirname(filepath);
    await Directory(parentDirectory).create(recursive: true);
    await File(filepath).writeAsString(jsonEncode(versionJson));
    // created versionsDir
  }
}
