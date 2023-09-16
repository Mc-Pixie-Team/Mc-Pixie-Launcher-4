import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/apis/api.dart';
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
  getModpackList() async {
    var res = await http.get(Uri.parse(
        'https://api.modrinth.com/v2/search?facets=[["project_type:modpack"], ["categories:forge", "categories:fabric"]]&index=relevance&limit=$limit'));

    return jsonDecode(utf8.decode(res.bodyBytes))["hits"];
  }

  @override
  getMoreModpacks() async {
    var res = await http.get(Uri.parse(
        'https://api.modrinth.com/v2/search?offset=$offset&facets=[["project_type:modpack"], ["categories:forge", "categories:fabric"]]&index=relevance&limit=$limit'));
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
  downloadModpack(Map modpackVersion, String instanceName) async {
    print('trying to download');
    await _downloadFiles(modpackVersion["files"], instanceName);

    for (var dependence in modpackVersion["dependencies"]) {
      var res = await http.get(Uri.parse(
          'https://api.modrinth.com/v2/version/${dependence["version_id"]}'));
      print(dependence["version_id"]);
      if (dependence["version_id"] == null) continue;
      Map dependenceJson = jsonDecode(utf8.decode(res.bodyBytes));
      print(dependenceJson);
      await _downloadFiles(dependenceJson["files"], instanceName);
      if (dependenceJson["dependencies"].length > 0) {}
    }
  }

  _downloadFiles(List files, String instanceName) async {
    for (var file in files) {
      print(file["url"]);

      if (!(file["primary"])) continue;
      int total = file["size"];
      int received = 0;

      List<int> _bytes = [];
      http.StreamedResponse? response =
          await http.Client().send(http.Request('GET', Uri.parse(file["url"])));

      await response.stream.listen((value) {
        _bytes.addAll(value);
        received += value.length;
      }).asFuture();

      print((received / total) * 100);

      String filepath = '${await getTempCommandPath()}\\$instanceName';
      String destination = '${await getInstancePath()}\\$instanceName';

      if (file["filename"].split('.').last == 'mrpack') {
        await Utils.extractZip(_bytes, filepath);
        await Utils.copyDirectory(
            Directory(filepath + '\\overrides'), Directory(destination));
        await File(destination + '\\modrinth.index.json').writeAsBytes(
            await File(filepath + '\\modrinth.index.json').readAsBytes());
      } else if (file["url"].split('.').last == 'jar') {
        String filepath2 = destination + '\\mods\\${file["filename"]}';
        String parentDirectory = path.dirname(filepath2);

        await Directory(parentDirectory).create(recursive: true);

        await File(filepath2).writeAsBytes(_bytes);
      }
    }
  }

  @override
  getAllMV() async {
    var res = await http
        .get(Uri.parse('https://api.modrinth.com/v2/tag/game_version'));

    List allMCversions = jsonDecode(utf8.decode(res.bodyBytes));
    List return_value = [];

    for (var i in allMCversions){
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
