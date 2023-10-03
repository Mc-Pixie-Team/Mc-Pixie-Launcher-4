import 'package:mclauncher4/src/tasks/downloadState.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/downloadState.dart';
import 'package:mclauncher4/src/tasks/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:mclauncher4/src/tasks/version.dart';
import '../config/apis.dart';
import 'package:path/path.dart' as path;

class ModrinthApiDownloader with ChangeNotifier{

    double _progress = 0.0;
  Modinstall _state = Modinstall.downloadingMod;

   @override
  get installState => _state;

  @override
  get progress => _progress;

    downloadModpack(Map modpackVersion, String instanceName) async {
    _state = Modinstall.downloadingMod;
    notifyListeners();

    int _total = modpackVersion["dependencies"].length + 1;
    int _received = 0;


    await _downloadFiles(modpackVersion["files"], instanceName);
    _received++;
    
    _progress = (_received / _total) * 100;
    notifyListeners();
    for (var dependence in modpackVersion["dependencies"]) {
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
      notifyListeners();
    }
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
            Directory(filepath + '\\overrides'), Directory(destination));
        await File(destination + '\\modrinth.index.json').writeAsBytes(
            await File(filepath + '\\modrinth.index.json').readAsBytes());
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