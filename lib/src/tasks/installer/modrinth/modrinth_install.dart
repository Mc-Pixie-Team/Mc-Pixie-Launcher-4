import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/fabric/fabric.dart';
import 'package:mclauncher4/src/tasks/forge/forge.dart';
import 'package:mclauncher4/src/tasks/minecraft/minecraft_install.dart';
import 'package:mclauncher4/src/tasks/models/download_states.dart';
import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:mclauncher4/src/tasks/models/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/modloaders.dart';
import 'package:mclauncher4/src/tasks/utils/downloader.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

class ModrinthInstaller {
  late ModloaderVersion modloaderVersion;
  Modloader? modloader;
  Minecraft minecraft = Minecraft();

  double _progress = 0.0;
  MainState _state = MainState.downloadingML;

  MainState get installState => _state;
  double get progress => _progress;

  _getModpack(String id) async {
    var res =
        await http.get(Uri.parse('https://api.modrinth.com/v2/project/$id'));
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  Future<Map<String, dynamic>> _getModpackVersion(String version) async {
    var res = await http
        .get(Uri.parse('https://api.modrinth.com/v2/version/$version'));
    // TODO: implement getModpack
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  Future<Process> start(String processId) async {
    late ModloaderVersion modloaderVersion;
    late Modloader modloader;
    String destination =
        path.join(getInstancePath(), processId, "modrinth.index.json");
    Map depend =
        (jsonDecode(await File(destination).readAsString()))["dependencies"];

    if (depend["fabric-loader"] != null) {
      modloader = Fabric();
      modloaderVersion = ModloaderVersion.parse(depend["fabric-loader"]);
    } else if (depend["forge"] != null) {
      modloader = Forge();
      modloaderVersion = ModloaderVersion.parse(depend["forge"]);
    }

    Version version = Version.parse(depend["minecraft"]);

    return await modloader.run(processId, version, modloaderVersion);
  }

  install(
      {required Map modpackData,
      required String instanceName,
      Version? localversion}) async {

    print(modpackData);

    _state = MainState.downloadingMods;
    print("downloading mods");

    await _downloadMrPack(modpackData["files"][0], instanceName);

    String destination =
        path.join(getInstancePath(), instanceName, "modrinth.index.json");
    Map depend =
        (jsonDecode(await File(destination).readAsString()));
    Version version = Version.parse(depend["dependencies"]['minecraft']);

    int _total = depend["files"].length + 1;
    int _received = 0;

    final downloads_at_same_time = 15;
    int _totalitems = depend["files"].length;
    print(_totalitems);
    for (var i = 0; depend["files"].length > i;) {
      print(i);
      Iterable<Future<dynamic>> downloads = Iterable.generate(
          downloads_at_same_time > _totalitems
              ? _totalitems
              : downloads_at_same_time, (index) async {
        print("downloading:" + i.toString());

        // print(dependenceJson);
        await _downloadFiles(
            depend["files"][i + index], instanceName);
      });
      await Future.wait(downloads);

      i += downloads_at_same_time;
      _totalitems = _totalitems - downloads_at_same_time;
      _received += downloads_at_same_time > _totalitems
          ? _totalitems
          : downloads_at_same_time;
      _progress = (_received / _total) * 100;
    }

    if (depend["dependencies"]["forge"] != null) {
      modloaderVersion = ModloaderVersion.parse(depend["dependencies"]["forge"]);
      modloader = Forge();
    } else if (depend["dependencies"]["fabric-loader"] != null) {
      modloaderVersion = ModloaderVersion.parse(depend["dependencies"]["fabric-loader"]);
      modloader = Fabric();
    } else {
      throw Exception(
          "Could not find a mod loader in modrinth.index.json! \n is the file corupted? Please check the formatting");
    }

    String mfilePath = path.join(
        getworkpath(), "versions", version.toString(), "$version.json");

    modloader!.addListener(() {
      _progress = modloader!.mainprogress;
    });

    minecraft.addListener(() {
      _progress = minecraft.mainprogress;
    });

    ///check if minecraft is installed
    if (_checkForInstall(mfilePath)) {
      _state = MainState.downloadingMinecraft;
      _progress = 0.0;
      //install minecraft
      print('need to install minecraft: $version');
      print(mfilePath);
      await minecraft.install(version);
    }

    //check with dynamic [Modloader] if installed
    if (_checkForInstall(
        await modloader!.getSafeDir(version, modloaderVersion))) {
      _state = MainState.downloadingML;
      print('need to install : $version-$modloaderVersion');
      await modloader!.install(version, modloaderVersion);
    }
    _state = MainState.installed;
    print('finfished');
  }

  bool _checkForInstall(String path) {
    return (!(File(path).existsSync()));
  }

  _downloadMrPack(Map file, String instanceName) async {
    if (file["url"] == null ||
        file["filename"] == null ||
        (!(file["filename"].split('.').last == 'mrpack')))
      throw "Mrpack is not valid !";

    String filepath = path.join(getTempCommandPath(), instanceName);
    String destination = path.join(getInstancePath(), instanceName);
    Downloader _downloader =
        Downloader(file["url"], path.join(filepath, file["filename"]));
    await _downloader.startDownload(
      onProgress: (p0) => _progress = p0,
    );

    _state = MainState.unzipping;
    _progress = 0.0;
    await _downloader.unzip(
        deleteOld: true, onZipProgress: (p0) => _progress = p0);

    Utils.copyDirectory(
        source: Directory(path.join(filepath, "overrides")),
        destination: Directory(destination));
    await Utils.copyFile(
        source: File(path.join(filepath, "modrinth.index.json")),
        destination: File(path.join(destination, "modrinth.index.json")));
      Directory(path.join(filepath)).deleteSync(recursive: true);
    _state = MainState.downloadingMods;
    _progress = 0.0;
  }

  _downloadFiles(Map file, String instanceName) async {
   
      // print(file["url"]);


      String destination = path.join(getInstancePath(), instanceName, file["path"] );
      

        Downloader _downloader = Downloader(file["downloads"][0], destination); //takes always the first download

        await _downloader.startDownload();
      
    
  }
}
