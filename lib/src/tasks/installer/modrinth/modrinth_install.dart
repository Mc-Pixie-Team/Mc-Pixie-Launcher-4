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

  getModpack(String id) async {
    var res = await http.get(Uri.parse('https://api.modrinth.com/v2/project/$id'));
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  Future<Map<String, dynamic>> getModpackVersion(String version) async {
    var res = await http.get(Uri.parse('https://api.modrinth.com/v2/version/$version'));
    // TODO: implement getModpack
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

 Future<Process> start(String processId) async{
    late ModloaderVersion modloaderVersion;
   late Modloader modloader;
    String destination =
       path.join(getInstancePath(), processId, "modrinth.index.json");
    Map depend =
        (jsonDecode(await File(destination).readAsString()))["dependencies"];
   


    if (depend["fabric-loader"] != null) {
      modloader = Fabric();
        modloaderVersion = ModloaderVersion.parse(depend["fabric-loader"]);
    }else if (depend["forge"] != null) {
        modloader = Forge();
      modloaderVersion = ModloaderVersion.parse(depend["forge"]);
    }

    Version version = Version.parse(depend["minecraft"]);

      return  await modloader.run(processId, version, modloaderVersion);


  }


  install( {required Map modpackData, required String instanceName, Version? localversion}) async {
    

    if(modpackData["name"] == null) {
          Map modpackproject = await getModpack(modpackData["project_id"]);
    modpackData = await getModpackVersion( (modpackproject["versions"] as List).last);
    }


    _state = MainState.downloadingMods;
    print("downloading mods");

    int _total = modpackData["dependencies"].length + 1;
    int _received = 0;

    await _downloadFiles(modpackData["files"], instanceName);
    _received++;

    _progress = (_received / _total) * 100;

    final downloads_at_same_time  = 15;
    int _totalitems = modpackData["dependencies"].length;
    print(_totalitems);
    for (var i = 0; modpackData["dependencies"].length > i; ) {
      print(i);
     Iterable<Future<dynamic>> downloads = Iterable.generate(
          downloads_at_same_time > _totalitems ? _totalitems : downloads_at_same_time,
          (index) async {
            print("downloading:" + i.toString());
        var dependence = modpackData["dependencies"][i + index];
      var res = await http.get(Uri.parse('https://api.modrinth.com/v2/version/${dependence["version_id"]}'));
      // print(dependence["version_id"]);
      if (dependence["version_id"] == null) return;
      Map dependenceJson = jsonDecode(utf8.decode(res.bodyBytes));
      // print(dependenceJson);
      await _downloadFiles(dependenceJson["files"], instanceName);

          });
    await Future.wait(downloads);

      i += downloads_at_same_time;
      _totalitems = _totalitems - downloads_at_same_time;
      _received += downloads_at_same_time > _totalitems ? _totalitems : downloads_at_same_time;
      _progress = (_received / _total) * 100;
      
    }

    String destination = path.join(getInstancePath(), instanceName, "modrinth.index.json");
    Map depend = (jsonDecode(await File(destination).readAsString()))["dependencies"];
    Version version = Version.parse(depend['minecraft']);

    if (depend["forge"] != null) {
      modloaderVersion = ModloaderVersion.parse(depend["forge"]);
      modloader = Forge();
    } else if (depend["fabric-loader"] != null) {
      modloaderVersion = ModloaderVersion.parse(depend["fabric-loader"]);
      modloader = Fabric();
    } else {
      throw Exception(
          "Could not find a mod loader in modrinth.index.json! \n is the file corupted? Please check the formatting");
    }

    String mfilePath = path.join(getworkpath(), "versions", version.toString(), "$version.json");

    modloader!.addListener(() {
      _progress = modloader!.mainprogress;
    });

    minecraft.addListener(() {
      _progress = minecraft.mainprogress;
    });

    ///check if minecraft is installed
    if (_checkForInstall( mfilePath)) {
      _state = MainState.downloadingMinecraft;
      //install minecraft
      print('need to install minecraft: $version');
      print(mfilePath);
      await minecraft.install(version);
    }

    //check with dynamic [Modloader] if installed
    if (_checkForInstall(await modloader!.getSafeDir(version, modloaderVersion))) {
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
  
     String filepath = path.join(getTempCommandPath(), instanceName);
      String destination = path.join(getInstancePath(), instanceName);

      if (file["filename"].split('.').last == 'mrpack') {
        Downloader _downloader =  Downloader(file["url"],path.join(filepath, file["filename"]) );
        await _downloader.startDownload(onProgress: (p0) => _progress = p0,);

        await _downloader.unzip(deleteOld: true);

        await Utils.copyDirectory(source: Directory(path.join(filepath, "overrides")), destination: Directory(destination));
        await Utils.copyFile(source: File(path.join(filepath, "modrinth.index.json")), destination: File(path.join(destination, "modrinth.index.json")));

      } else if (file["url"].split('.').last == 'jar') {
        if (!(file["primary"])) continue;

        String filepath2 = path.join(destination, 'mods', file["filename"]);
        Downloader _downloader =  Downloader(file["url"], filepath2);

       await _downloader.startDownload();

      }
    }
   
  }
}
