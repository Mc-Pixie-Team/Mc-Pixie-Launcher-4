import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/apis/modrinth.download.dart';
import 'package:mclauncher4/src/tasks/downloadState.dart';
import 'package:mclauncher4/src/tasks/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:mclauncher4/src/tasks/version.dart';
import '../config/apis.dart';
import 'package:path/path.dart' as path;

class ModrinthApi implements Api {
  int limit = 50;
  int offset = 50;
   

  @override
  String query = "";
  @override
  String version = "";

  @override
  getModpackList() async {

    print(
        'https://api.modrinth.com/v2/search?query=$query&facets=[["project_type:modpack"],${version == "" ? "": '["versions:$version"],'} ["categories:forge", "categories:fabric"]]&index=relevance&limit=$limit');
    var res = await http.get(Uri.parse(
        'https://api.modrinth.com/v2/search?query=$query&facets=[["project_type:modpack"],${version == "" ? "":'["versions:$version"],'} ["categories:forge", "categories:fabric"]]&index=relevance&limit=$limit'));

    return jsonDecode(utf8.decode(res.bodyBytes))["hits"];
  }

  @override
  getDownloaderObject() {
    return  ModrinthApiDownloader();
  }

  @override
  getMoreModpacks() async {
      String ver = '["versions:$version"]';
    var res = await http.get(Uri.parse(
        'https://api.modrinth.com/v2/search?query=$query&offset=$offset&facets=[["project_type:modpack"], ["categories:forge", "categories:fabric"]]&index=relevance&limit=$limit'));
    offset += limit;
    return jsonDecode(utf8.decode(res.bodyBytes))["hits"];
  }
  //2022-06-03T01:09:54.072846Z
  //2022-06-16T17:45:30.690271Z
  //2023-07-27T18:48:11.519091Z

  @override
  getModpack(String id) async {
    var res =
        await http.get(Uri.parse('https://api.modrinth.com/v2/project/$id'));
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  @override
  getModpackVersion(String version) async {
    var res = await http
        .get(Uri.parse('https://api.modrinth.com/v2/version/$version'));
    // TODO: implement getModpack
    return jsonDecode(utf8.decode(res.bodyBytes));
  }



  @override
  getMMLVersion(modpackVersion, String instanceName, String modloader) async {
    Map return_value = {};
    late ModloaderVersion modloaderVersion;
    String destination =
        '${await getInstancePath()}\\$instanceName\\modrinth.index.json';
    Map depend =
        (jsonDecode(await File(destination).readAsString()))["dependencies"];
    Version _version = Version.parse(depend['minecraft']);

    if (modloader == "forge") {
      modloaderVersion = ModloaderVersion.parse(depend["forge"]);
    }
    if (modloader == "fabric") {
      modloaderVersion = ModloaderVersion.parse(depend["fabric-loader"]);
    }
    return_value = {"version": _version, "modloader": modloaderVersion};
    return return_value;
  }




  @override
  getAllMV() async {
    var res = await http
        .get(Uri.parse('https://api.modrinth.com/v2/tag/game_version'));

    List allMCversions = jsonDecode(utf8.decode(res.bodyBytes));
    List return_value = [];

    for (var i in allMCversions) {
      if (i["major"]) {
        return_value.add(i);
      }
      continue;
    }

    return return_value;
  }

  @override
  getTitlename() {
    return "Modrinth";
  }
}
