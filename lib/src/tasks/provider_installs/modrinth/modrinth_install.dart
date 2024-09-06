import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/models/modloader_type.dart';
import 'package:mclauncher4/src/tasks/models/object_type.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/tasks/provider_installs/provider_installer.dart';
import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/models/version_object.dart';
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
  Future install(
      {required UMF umfData,
      required String instanceName,
      required InstallModel installModel}) async {
    installModel.setInstallState(InstallState.installing);
    installModel.setState("installing Project");
    var modpackData = umfData.original;

    print("downloading mods");

    await _downloadMrPack(modpackData["files"][0], instanceName, installModel);

    installModel.setState("Downloading Mods");

    String destination =
        path.join(getInstancePath(), instanceName, "modrinth.index.json");
    Map depend = (jsonDecode(await File(destination).readAsString()));

    int _total = depend["files"].length + 1;
    int _received = 0;

    final downloads_at_same_time = 15;
    int _totalitems = depend["files"].length;
    print(_totalitems);
    List<Map> installedDependencies = [];
    for (var i = 0; depend["files"].length > i;) {
      print(i);
      Iterable<Future<dynamic>> downloads = Iterable.generate(
          downloads_at_same_time > _totalitems
              ? _totalitems
              : downloads_at_same_time, (index) async {
        print("downloading:" + i.toString());

        // print(dependenceJson);
        var fileData = depend["files"][i + index];
        String destination =
            path.join(getInstancePath(), instanceName, fileData["path"]);

        Downloader _downloader = Downloader(fileData["downloads"][0],
            destination); //takes always the first download

        await _downloader.startDownload();
        print(fileData["path"]);
        print(fileData["hashes"]);
        if(fileData["hashes"] != null) {

        
        var res = await http.get(Uri.parse(
            "https://api.modrinth.com/v2/version_file/${fileData["hashes"]["sha512"]}"));

        if(res.statusCode != 200) return;

        var projecthashRes = jsonDecode(utf8.decode(res.bodyBytes));
        var res2 = await http.get(Uri.parse(
            "https://api.modrinth.com/v2/project/${projecthashRes["project_id"]}"));

         var author =jsonDecode(utf8.decode( (await http.get(Uri.parse(
            "https://api.modrinth.com/v2/user/${projecthashRes["author_id"]}") ) ).bodyBytes))["username"];

        var modpackData = jsonDecode(utf8.decode(res2.bodyBytes));

        late ObjectType objectType;

        switch (modpackData["project_type"]) {
          case "mod":
            objectType = ObjectType.mod;
          case "modpack":
            objectType = ObjectType.modpack;
          case "shader":
            objectType = ObjectType.shader;
          case "world":
            objectType = ObjectType.world;
          case "resourcepack":
            objectType = ObjectType.resource;
          default:
            throw "Couldnt find project Type";
        }

        installedDependencies.add(UMF.toJson(UMF(
          objectPath: destination,
            providerId: "modrinth",
            author: author,
            name: modpackData["title"],
            slug: modpackData["slug"],
            description: modpackData["description"],
            downloads: modpackData["downloads"],
            icon: modpackData["icon_url"],
            type: objectType,
            original: fileData)));}
      });
      
      await Future.wait(downloads);

      i += downloads_at_same_time;
      _totalitems = _totalitems - downloads_at_same_time;
      _received += downloads_at_same_time > _totalitems
          ? _totalitems
          : downloads_at_same_time;
      installModel.setProgress(((_received / _total) * 100).ceilToDouble());
    }

    var depManifest =
        File(path.join(getInstancePath(), instanceName, "manifest.json"));

    if (!depManifest.existsSync()) {
      await depManifest.create();
      await depManifest.writeAsString("[]");
    }

    var dependencies = jsonDecode(await depManifest.readAsString());

    dependencies.addAll(installedDependencies);
    depManifest.writeAsString(jsonEncode(dependencies));

    umfData.MCVersion = depend["dependencies"]["minecraft"];
    if (depend["dependencies"]["fabric-loader"] != null) {
      umfData.modloader = ModloaderType.fabric;
      umfData.MLVersion = "${depend["dependencies"]["fabric-loader"]}";
    } else if (depend["dependencies"]["forge"] != null) {
      umfData.modloader = ModloaderType.forge;
      umfData.MLVersion = "${depend["dependencies"]["forge"]}";
    } else {
      umfData.modloader = ModloaderType.vanilla;
    }
    print(umfData.modloader);
  }

  _downloadMrPack(
      Map file, String instanceName, InstallModel installModel) async {
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

  @override
  Future installFile(
      {required UMF umfData,
      required String instanceName,
      required InstallModel installModel}) {
    // TODO: implement installFile
    throw UnimplementedError();
  }
}
