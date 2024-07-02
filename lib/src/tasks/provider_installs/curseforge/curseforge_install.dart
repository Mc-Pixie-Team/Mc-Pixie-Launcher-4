import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/provider_installs/provider_installer.dart';
import 'package:mclauncher4/src/tasks/provider_installs/modrinth/modrinth_install.dart';

import 'package:mclauncher4/src/tasks/models/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:mclauncher4/src/tasks/installs/fabric/fabric_install.dart';
import 'package:mclauncher4/src/tasks/installs/forge/forge_install.dart';
import 'package:mclauncher4/src/tasks/installs/minecraft/minecraft_install.dart';
import 'package:mclauncher4/src/tasks/installs/install_model.dart';
import 'package:mclauncher4/src/tasks/utils/downloader.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';

import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:path/path.dart' as path;

class CurseforgeInstaller  implements ProviderInstaller {



  Map<String, String> userHeader = {
    "Content-type": "application/json",
    "Accept": "application/json",
    "x-api-key":
        "\$2a\$10\$zApu4/n/e1nylJMTZMv5deblPpAWUHXc226sEIP1vxCjlYQoQG3QW",
  };

  final baseUrl = "https://api.curseforge.com";

  @override
  Future install({required Map modpackData,required String instanceName, required InstallModel installModel}) async {
    installModel.setInstallState(InstallState.installing);
    installModel.setState("installing Project");
    //Getting classIds for Curseforge
    final resClassCatergories = await http.get(
        Uri.parse('$baseUrl/v1/categories?gameId=432&classesOnly=true'),
        headers: userHeader);

    List<dynamic> classCatergories =
        await jsonDecode(utf8.decode(resClassCatergories.bodyBytes))["data"];

    int modClassifier = classCatergories
        .where((element) => element["slug"] == "mc-mods")
        .first["id"];
    int shaderClassifier = classCatergories
        .where((element) => element["slug"] == "shaders")
        .first["id"];
    int resourcePackClassifier = classCatergories
        .where((element) => element["slug"] == "texture-packs")
        .first["id"];
    int worldClassifier = classCatergories
        .where((element) => element["slug"] == "worlds")
        .first["id"];

    if (modClassifier == null ||
        shaderClassifier == null ||
        resourcePackClassifier == null ||
        worldClassifier == null) {
      throw "Couldn't find Class Categories";
    }

    Downloader _downloader = Downloader(
        modpackData["downloadUrl"],
        path.join(
            getTempCommandPath(), instanceName, "modpack-$instanceName.zip"));

    installModel.setState("Downloading Project");

    await _downloader.startDownload(onProgress: (p0) {
      installModel.setProgress(p0);
    });

    installModel.setState("Unzipping");

    await _downloader.unzip(
        deleteOld: true,
        onZipProgress: (p0) {
          installModel.setProgress(p0);
        });

    Map manifest = jsonDecode(
        File(path.join(getTempCommandPath(), instanceName, "manifest.json"))
            .readAsStringSync());

    Utils.copyDirectory(
        source: Directory(path.join(
            getTempCommandPath(), instanceName, manifest["overrides"])),
        destination: Directory(path.join(getInstancePath(), instanceName)));

    await File(path.join(
            getInstancePath(), instanceName, "curseforge.manifest.json"))
        .writeAsString(jsonEncode(manifest));

    await Directory(path.join(getTempCommandPath(), instanceName))
        .delete(recursive: true);



    final downloads_at_same_time = 10;
    int _totalitems = (manifest["files"] as List).length;

     installModel.setState("Downloading Mods");

    for (var i = 0; (manifest["files"] as List).length > i;) {
      Iterable<Future<dynamic>> downloads = Iterable.generate(
          downloads_at_same_time > _totalitems
              ? _totalitems
              : downloads_at_same_time, (index) async {
        Map current = manifest["files"][i + index];

        final res = await http.get(
            Uri.parse(
                '$baseUrl/v1/mods/${current["projectID"]}/files/${current["fileID"]}'),
            headers: userHeader);
        final res2 = await http.get(
            Uri.parse('$baseUrl/v1/mods/${current["projectID"]}'),
            headers: userHeader);

        Map hitmod = await jsonDecode(utf8.decode(res.bodyBytes))["data"];
        Map hitproj = await jsonDecode(utf8.decode(res2.bodyBytes))["data"];

        late String innerDownloadPath;
        String? url;
        String? filename = hitmod["fileName"];

        if (hitproj["classId"] == modClassifier) {
          innerDownloadPath = "mods";
        } else if (hitproj["classId"] == shaderClassifier) {
          innerDownloadPath = "shaderpacks";
        } else if (hitproj["classId"] == resourcePackClassifier) {
          innerDownloadPath = "resourcepacks";
        } else if (hitproj["classId"] == worldClassifier) {
          innerDownloadPath = "saves";
        } else {
          print("could find any classifier moving on");
          return;
        }

        if (hitmod["downloadUrl"] == null || hitmod["downloadUrl"] == "") {
          print("no inner modurl found for: ${modpackData["fileID"]}");
          url =
              'https://www.curseforge.com/api/v1/mods/${current["projectID"]}/files/${current["fileID"]}/download';
        } else {
          url = hitmod["downloadUrl"];
        }

        if (url == null) throw "Cannot find any download url";
        print("using url: " + url + " with: " + filename.toString());

        Downloader _downloader = Downloader(
            url,
            path.join(
                getInstancePath(), instanceName, innerDownloadPath, filename));

        await _downloader.startDownload();
      });

      await Future.wait(downloads);

      _totalitems -= downloads_at_same_time;
      i += downloads_at_same_time;
      installModel.setProgress(((i / ((manifest["files"] as List).length)) * 100).roundToDouble());
    }


    String version = manifest["minecraft"]["version"];
    String loaderversion = manifest["minecraft"]["modLoaders"][0]["id"];

    switch (loaderversion.split("-").first) {
      case "forge":
        await ForgeInstall.install("$version-${loaderversion.split("-")[1]}", getlibarypath(), installModel);
      case "fabric":
        await FabricInstall.install(loaderversion.split("-")[1], version,  getlibarypath(), installModel);
      default:
        await MinecraftInstall.install(Version.parse(version), getlibarypath(), installModel);
    }

  }

  @override
  Future<Process> start(String processId, InstallModel installModel) async {
    String destination =
        path.join(getInstancePath(), processId, "curseforge.manifest.json");
    Map manifest = (jsonDecode(await File(destination).readAsString()));

    String version = manifest["minecraft"]["version"];
    String loaderversion = manifest["minecraft"]["modLoaders"][0]["id"];

    switch (loaderversion.split("-").first) {
      case "forge":
        return await ForgeInstall.run("$version-${loaderversion.split("-")[1]}", getlibarypath(),processId, installModel);
      case "fabric":
        return await FabricInstall.run(loaderversion.split("-")[1], version,  getlibarypath(),processId, installModel);
      default:
        return await MinecraftInstall.run(Version.parse(version),processId, installModel);
    }
}
}