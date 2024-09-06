import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/date_symbols.dart';
import 'package:mclauncher4/src/tasks/models/modloader_type.dart';
import 'package:mclauncher4/src/tasks/models/object_type.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/tasks/provider_installs/provider_installer.dart';
import 'package:mclauncher4/src/tasks/provider_installs/modrinth/modrinth_install.dart';

import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:mclauncher4/src/tasks/installs/fabric/fabric_install.dart';
import 'package:mclauncher4/src/tasks/installs/forge/forge_install.dart';
import 'package:mclauncher4/src/tasks/installs/minecraft/minecraft_install.dart';
import 'package:mclauncher4/src/tasks/installs/install_model.dart';
import 'package:mclauncher4/src/tasks/utils/downloader.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';

import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:path/path.dart' as p;

class CurseforgeInstaller implements ProviderInstaller {
  Map<String, String> userHeader = {
    "Content-type": "application/json",
    "Accept": "application/json",
    "x-api-key":
        "\$2a\$10\$zApu4/n/e1nylJMTZMv5deblPpAWUHXc226sEIP1vxCjlYQoQG3QW",
  };

  final baseUrl = "https://api.curseforge.com";

  @override
  Future installFile(
      {required UMF umfData,
      required String instanceName,
      required InstallModel installModel}) async {
    installModel.setInstallState(InstallState.installing, notify: false);
    installModel.setState('Installing ${umfData.name ?? "Mod"} ');

    var modpackData = umfData.original;
    var fullModpackData;

    // If classid is not available we need to get the whole project
    final res2 = await http.get(
        Uri.parse('$baseUrl/v1/mods/${modpackData["modId"]}'),
        headers: userHeader);
    if (res2.statusCode != 200) {
      throw res2.statusCode;
    }
    fullModpackData = await jsonDecode(utf8.decode(res2.bodyBytes))["data"];


    final resClassCatergories = await http.get(Uri.parse('$baseUrl/v1/categories?gameId=432&classesOnly=true'), headers: userHeader);

    List<dynamic> classCatergories = await jsonDecode(utf8.decode(resClassCatergories.bodyBytes))["data"];

    var id = classCatergories.singleWhere((element) => element["id"] == fullModpackData["classId"])["id"];

    ObjectType? type;

    switch (id) {
      case 6:
        type = ObjectType.mod;
      case 6552:
        type = ObjectType.shader;
      case 12:
        type = ObjectType.resource;
      case 17:
        type = ObjectType.world;
      default:
        throw "Couldn't find type";
    }

    var path = p.join(getInstancePath(), instanceName,
        ObjectTypeTools.todir(type), modpackData["fileName"]);
    var url;

    if (modpackData["downloadUrl"] == "" ||
        modpackData["downloadUrl"] == null) {
      url =
          'https://www.curseforge.com/api/v1/mods/${fullModpackData["id"]}/files/${modpackData["id"]}/download';
    } else {
      url = modpackData["downloadUrl"];
    }

    print(url);

    await Downloader(url, path).startDownload(onProgress: (p0) {
      installModel.setProgress(p0);
    });
    umfData.objectPath = path;
  }

  @override
  Future install(
      {required UMF umfData,
      required String instanceName,
      required InstallModel installModel}) async {
    installModel.setInstallState(InstallState.installing);
    installModel.setState("installing Project");

    var modpackData = umfData.original;

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
        p.join(
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
        File(p.join(getTempCommandPath(), instanceName, "manifest.json"))
            .readAsStringSync());

    Utils.copyDirectory(
        source: Directory(
            p.join(getTempCommandPath(), instanceName, manifest["overrides"])),
        destination: Directory(p.join(getInstancePath(), instanceName)));

    await File(
            p.join(getInstancePath(), instanceName, "curseforge.manifest.json"))
        .writeAsString(jsonEncode(manifest));

    await Directory(p.join(getTempCommandPath(), instanceName))
        .delete(recursive: true);

    final downloads_at_same_time = 10;
    int _totalitems = (manifest["files"] as List).length;

    installModel.setState("Downloading Mods");

    List<Map> installedDependencies = [];

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

        late ObjectType objectType;
        String? url;
        String? filename = hitmod["fileName"];

        if (hitproj["classId"] == modClassifier) {
          objectType =ObjectType.mod;
     
        } else if (hitproj["classId"] == shaderClassifier) {
          objectType =ObjectType.shader;
        } else if (hitproj["classId"] == resourcePackClassifier) {
          objectType =ObjectType.resource;
        } else if (hitproj["classId"] == worldClassifier) {
          objectType =ObjectType.world;
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
        var filepath = p.join(
            getInstancePath(), instanceName, ObjectTypeTools.todir(objectType), filename);
        Downloader _downloader = Downloader(url, filepath);

        await _downloader.startDownload();


        installedDependencies.add(UMF.toJson( UMF(
          objectPath: filepath,
        providerId: "curseforge",
        original: hitproj,
        description: hitproj["summary"],
        name: hitproj["name"],
        slug: hitproj["slug"],
        versionName: hitproj["displayName"],
        downloads: hitproj["downloadCount"],
        icon: hitproj["logo"]["thumbnailUrl"],
        author: hitproj["authors"][0]["name"],
        type: objectType
      )) );
      });

      await Future.wait(downloads);

      var depManifest = File(p.join(getInstancePath(), instanceName, "manifest.json"));

      if(!depManifest.existsSync()) {
        await depManifest.create();
        await depManifest.writeAsString("[]");
      }

      var dependencies =jsonDecode(await depManifest.readAsString());

      dependencies.addAll(installedDependencies);
      depManifest.writeAsString(jsonEncode(dependencies));

      _totalitems -= downloads_at_same_time;
      i += downloads_at_same_time;
      installModel.setProgress(
          ((i / ((manifest["files"] as List).length)) * 100).roundToDouble());
    }


    String loaderversion = manifest["minecraft"]["modLoaders"][0]["id"];
    umfData.MCVersion = manifest["minecraft"]["version"];
    switch (loaderversion.split("-").first) {
      case "forge":
        
        umfData.modloader = ModloaderType.forge;
        umfData.MLVersion = "${loaderversion.split("-")[1]}";
      case "fabric":
        umfData.modloader = ModloaderType.fabric;
        umfData.MLVersion = "${loaderversion.split("-")[1]}";

      default:
        umfData.modloader = ModloaderType.vanilla;

    }
  }

}
