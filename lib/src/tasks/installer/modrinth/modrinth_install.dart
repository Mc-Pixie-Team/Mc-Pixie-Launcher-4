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
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

class ModrinthInstaller {
  late ModloaderVersion modloaderVersion;
  Modloader? modloader;
  Minecraft minecraft = Minecraft();

  double _progress = 0.0;
  MainState _state = MainState.notinstalled;

 MainState get installState => _state;
 double get progress => _progress;


  getModpack(String id) async {
    var res =
        await http.get(Uri.parse('https://api.modrinth.com/v2/project/$id'));
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

    Future<Map<String, dynamic>> getModpackVersion(String version) async {
    var res = await http
        .get(Uri.parse('https://api.modrinth.com/v2/version/$version'));
    // TODO: implement getModpack
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

   install(Map modpackData, String instanceName) async {

    Map modpackproject = await getModpack(modpackData["project_id"]);
    modpackData = await
      getModpackVersion((modpackproject["versions"] as List).last);

    _state = MainState.downloadingMods; print("downloading mods");

    int _total = modpackData["dependencies"].length + 1;
    int _received = 0;

    await _downloadFiles(modpackData["files"], instanceName);
    _received++;

    _progress = (_received / _total) * 100;

    for (var dependence in modpackData["dependencies"]) {
      var res = await http.get(Uri.parse(
          'https://api.modrinth.com/v2/version/${dependence["version_id"]}'));
      // print(dependence["version_id"]);
      if (dependence["version_id"] == null) continue;
      Map dependenceJson = jsonDecode(utf8.decode(res.bodyBytes));
      // print(dependenceJson);
      await _downloadFiles(dependenceJson["files"], instanceName);
      if (dependenceJson["dependencies"].length > 0) {}
      _received++;
      _progress = (_received / _total) * 100;
    }

    String destination =
        '${await getInstancePath()}\\$instanceName\\modrinth.index.json';
    Map depend =
        (jsonDecode(await File(destination).readAsString()))["dependencies"];
    Version version = Version.parse(depend['minecraft']);

    if (depend["forge"] != null) {
       modloaderVersion = ModloaderVersion.parse(depend["forge"]);
      modloader = Forge();
    }
    else if (depend["fabric-loader"] != null) {
      modloaderVersion = ModloaderVersion.parse(depend["fabric-loader"]);
      modloader = Fabric();
    }else {
      throw Exception("Could not find a mod loader in modrinth.index.json! \n is the file corupted? Please check the formatting");
    }


    String mfilePath =
        '${await getworkpath()}\\versions\\$version\\$version.json';


    modloader!.addListener(() { 
       _progress = modloader!.mainprogress;
    });

     minecraft.addListener(() { 
       _progress = minecraft.mainprogress;
    });


    ///check if minecraft is installed
    if (_checkForInstall(
        '${await getworkpath()}\\versions\\$version\\$version.json')) {

      _state = MainState.downloadingMinecraft;
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

  _downloadFiles(List files, String instanceName) async {
    for (var file in files) {
      // print(file["url"]);

      int total = file["size"];
      int received = 0;

      List<int> _bytes = [];
      http.StreamedResponse? response =
          await http.Client().send(http.Request('GET', Uri.parse(file["url"])));

      await response.stream.listen((value) {
        _bytes.addAll(value);
        received += value.length;
      }).asFuture();

      String filepath = '${await getTempCommandPath()}\\$instanceName';
      String destination = '${await getInstancePath()}\\$instanceName';

      if (file["filename"].split('.').last == 'mrpack') {
        await Utils.extractZip(_bytes, filepath);
        await Utils.copyDirectory(
            Directory('$filepath\\overrides'), Directory(destination));
        await File('$destination\\modrinth.index.json').writeAsBytes(
            await File('$filepath\\modrinth.index.json').readAsBytes());
      } else if (file["url"].split('.').last == 'jar') {
        if (!(file["primary"])) continue;
        String filepath2 = destination + '\\mods\\${file["filename"]}';
        String parentDirectory = path.dirname(filepath2);

        await Directory(parentDirectory).create(recursive: true);

        await File(filepath2).writeAsBytes(_bytes);
      }
    }
  }
}
