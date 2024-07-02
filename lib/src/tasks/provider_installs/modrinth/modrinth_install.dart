import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/provider_installs/provider_installer.dart';
import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:mclauncher4/src/tasks/models/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/installs/fabric/fabric_install.dart';
import 'package:mclauncher4/src/tasks/installs/forge/forge_install.dart';
import 'package:mclauncher4/src/tasks/installs/minecraft/minecraft_install.dart';
import 'package:mclauncher4/src/tasks/installs/install_model.dart';
import 'package:mclauncher4/src/tasks/utils/downloader.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

class ModrinthInstaller implements ProviderInstaller {


  @override
  Future<Process> start(String processId, InstallModel installModel) async {
    String destination =
        path.join(getInstancePath(), processId, "modrinth.index.json");
    Map depend =
        (jsonDecode(await File(destination).readAsString()))["dependencies"];

    if (depend["fabric-loader"] != null) {
      return await FabricInstall.run(depend["fabric-loader"], depend["minecraft"], getlibarypath(),processId, installModel);
    } else if (depend["forge"] != null) {
       return await ForgeInstall.run("${depend["minecraft"]}-${depend["forge"]}", getlibarypath(),processId, installModel);     
    } else {
      return await MinecraftInstall.run(Version.parse(depend["minecraft"]),processId, installModel);
    }

  }
  @override
  Future install( {required Map modpackData, required String instanceName, required InstallModel installModel}) async {
    installModel.setInstallState(InstallState.installing);
    installModel.setState("installing Project");
    print(modpackData);

    print("downloading mods");

    await _downloadMrPack(modpackData["files"][0], instanceName, installModel);

    installModel.setState("Downloading Mods");

    String destination =
        path.join(getInstancePath(), instanceName, "modrinth.index.json");
    Map depend =
        (jsonDecode(await File(destination).readAsString()));

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
      installModel.setProgress(((_received / _total) * 100).ceilToDouble());
    }

    if (depend["dependencies"]["fabric-loader"] != null) {
     await FabricInstall.install(depend["dependencies"]["fabric-loader"], depend["dependencies"]["minecraft"], getlibarypath(), installModel);
    } else if (depend["dependencies"]["forge"] != null) {
        await ForgeInstall.install("${depend["dependencies"]["minecraft"]}-${depend["dependencies"]["forge"]}", getlibarypath(), installModel);     
    } else {
       await MinecraftInstall.install(Version.parse(depend["dependencies"]["minecraft"]),getlibarypath(), installModel);
    }

  }

  _downloadMrPack(Map file, String instanceName, InstallModel installModel) async {
    if (file["url"] == null ||
        file["filename"] == null ||
        (!(file["filename"].split('.').last == 'mrpack')))
      throw "Mrpack is not valid !";

    String filepath = path.join(getTempCommandPath(), instanceName);
    String destination = path.join(getInstancePath(), instanceName);
    Downloader _downloader =
        Downloader(file["url"], path.join(filepath, file["filename"]));
    await _downloader.startDownload(
      onProgress: (p0) => installModel.setProgress(p0),
    );

    installModel.setState("Unzipping Mrpack");

    await _downloader.unzip(
        deleteOld: true, onZipProgress: (p0) => installModel.setProgress(p0));

    Utils.copyDirectory(
        source: Directory(path.join(filepath, "overrides")),
        destination: Directory(destination));
    await Utils.copyFile(
        source: File(path.join(filepath, "modrinth.index.json")),
        destination: File(path.join(destination, "modrinth.index.json")));
      Directory(path.join(filepath)).deleteSync(recursive: true);
  }

  _downloadFiles(Map file, String instanceName) async {

      String destination = path.join(getInstancePath(), instanceName, file["path"] );      

        Downloader _downloader = Downloader(file["downloads"][0], destination); //takes always the first download

        await _downloader.startDownload();
      
    
  }
}
