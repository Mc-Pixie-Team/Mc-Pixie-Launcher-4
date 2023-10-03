import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/downloadState.dart';
import 'package:mclauncher4/src/tasks/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/version.dart';
import 'package:path/path.dart' as path;
import 'utils.dart';
import 'package:path_provider/path_provider.dart';
import '../config/apis.dart';

class Download with ChangeNotifier{
  DownloadState _state = DownloadState.notDownloaded;
  DownloadState get downloadstate => _state;
  double _progress = 0.0;
  double get progress => _progress;

  bool? isForge;
  int received = 0;
  Download({this.isForge});
  String os = "windows";
  String arch = "64";

  Future downloadLibaries(Map profile,
      [Version? version, ModloaderVersion? modloaderVersion]) async {
    if (profile["libraries"] == null) return;
    
    List libraries = profile["libraries"];
    for (int i = 0; i < libraries.length; ) {
      Map current = libraries[i];
     // print(current["downloads"]["artifact"]);

      if (current["natives"] != null && current["natives"][os] != null) {

        await _downloadForLibraries(current["downloads"]["classifiers"]
            [current["natives"][os].replaceAll("\${arch}", arch)]);
        await Utils.extractNativesfromjar(
            current["downloads"]["classifiers"]
                [current["natives"][os].replaceAll("\${arch}", arch)]["path"],
            profile["id"]);
      }
      if (current["downloads"]["artifact"] != null) {
              await _downloadForLibraries(current["downloads"]["artifact"],
          version: version, modloaderVersion: modloaderVersion);
      }

      i++;
      _progress = (i / libraries.length) * 100;
      _state = DownloadState.downloadingLibraries;
      notifyListeners();
    }
  }

 _downloadForLibraries(Map current,
      {String? altpath, Version? version, ModloaderVersion? modloaderVersion}) async {
    List<int> _bytes = [];
    int total = current["size"], received = 0, receivedControll = 0;

    if (current["url"] == "" || current["url"] == null) {
      if (version == null || modloaderVersion == null)
        throw "unable to handle version cause it empty.";
      _bytes = await File(
              '${await getTempForgePath()}\\$version\\$modloaderVersion\\maven\\${current["path"]}')
          .readAsBytes();
    } else {
      http.StreamedResponse? response = await http.Client()
          .send(http.Request('GET', Uri.parse(current["url"])));
      await response.stream.listen((value) {
        _bytes.addAll(value);
        received += value.length;
        receivedControll += value.length;
        if (receivedControll > total / 10) {
          receivedControll = 0;
        }
      }).asFuture();
    }

    String filepath =
        '${await getDocumentsPath()}\\PixieLauncherInstances\\debug\\libraries\\${altpath != null ? altpath + path.basename(((current["path"] as String).replaceAll('/', '\\'))) : ((current["path"] as String).replaceAll('/', '\\'))}';

    String parentDirectory = path.dirname(filepath);

    await Directory(parentDirectory).create(recursive: true);

    await File(filepath).writeAsBytes(_bytes);
    _bytes = []; //reset;
  }

  getOldUniversal(
      Map install_profileJson, Version version, ModloaderVersion modloaderVersion) async {
       
         if(install_profileJson["install"] == null) return;
          Map install_profile = install_profileJson["install"];
      File path = File(
            '${await getlibarypath()}\\libraries\\${Utils.parseMaven(install_profile["path"])}');
            print('parsing ${path.path} ');

        if(!(await path.exists())) throw "the file does not exist, mabye you called the method before you installed the libraries";
    List<int> _bytes = await File(
            '${await getTempForgePath()}\\$version\\$modloaderVersion\\${install_profile["filePath"]}')
        .readAsBytes();
    await File(
            '${await getlibarypath()}\\libraries\\${Utils.parseMaven(install_profile["path"])}')
        .writeAsBytes(_bytes);
  }

  Future<Map> getJson(Version version) async {
  late String url;
    var minecraftManifestRES = await http.get(Uri.parse('https://launchermeta.mojang.com/mc/game/version_manifest_v2.json'));
    List minecraftManifest = jsonDecode(minecraftManifestRES.body)['versions'];
    
    for ( Map versionjson in minecraftManifest) {
        if(versionjson["id"] == "$version") url = versionjson["url"];
    }
    var packagejsonRES = await http.get(Uri.parse(url));
    Map packagejson = jsonDecode(packagejsonRES.body);
    return packagejson;
  }

  Future downloadClient(Map packagejson) async {
    _state = DownloadState.downloadingClient;
    notifyListeners();
    String mcversion = packagejson["id"];

    String filepath =
        '${await getDocumentsPath()}\\PixieLauncherInstances\\debug\\versions\\$mcversion\\$mcversion.json';

    String parentDirectory = path.dirname(filepath);
    await Directory(parentDirectory).create(recursive: true);
    await File(filepath).writeAsBytes(utf8.encode(jsonEncode(packagejson)));

    var clientRES =
        await http.get(Uri.parse(packagejson["downloads"]["client"]["url"]));
    await File(
            '${await getDocumentsPath()}\\PixieLauncherInstances\\debug\\versions\\$mcversion\\$mcversion.jar')
        .writeAsBytes(clientRES.bodyBytes);
  }

  _writeAssetsjson(Map packagejson) async {
    String filepath =
        '${await getDocumentsPath()}\\PixieLauncherInstances\\debug\\assets\\indexes\\${packagejson["assets"]}.json';
    await Directory(path.dirname(filepath)).create(recursive: true);
    await File(filepath).create(recursive: true);
    await File(filepath).writeAsBytes(
        (await http.get(Uri.parse(packagejson["assetIndex"]["url"])))
            .bodyBytes);
  }

  Future downloadAssets(Map packagejson) async {

    await _writeAssetsjson(packagejson);

    int total = packagejson["assetIndex"]["totalSize"];
    received = 0;
    Map objects = jsonDecode(
        (await http.get(Uri.parse(packagejson["assetIndex"]["url"])))
            .body)["objects"];
    List objectEnteries = objects.keys.toList();

    //sorts all hashes to donwloads
    //Sweet spot: 10 || 40 sec || 1.20.1
    int downloads_at_same_time = 10;

    int _totalitems = objects.length;
    http.Client client = http.Client();
    for (var i = 0; objects.length > i;) {
      Iterable<Future<dynamic>> downloads = Iterable.generate(
          downloads_at_same_time > _totalitems
              ? _totalitems
              : downloads_at_same_time,
          (index) => _downloadForAssets(
              objects, objectEnteries, total, i + index, client));
      await Future.wait(downloads);
      i += downloads_at_same_time;
      _totalitems = _totalitems - downloads_at_same_time;
      _progress = (received / total) * 100;
       _state = DownloadState.downloadAssets;
      notifyListeners();
    }
  }

  //private Method
  _downloadForAssets(Map objects, List objectEnteries, int total, int i,
      http.Client client) async {
    // print('downloading is called' + i.toString());
    String url = minecraftResources +
        objects[objectEnteries[i]]["hash"].substring(0, 2) +
        '/' +
        objects[objectEnteries[i]]["hash"];

    //Downloading..
    List<int> _bytes = [];
    http.StreamedResponse? response =
        await client.send(http.Request('GET', Uri.parse(url)));

    await response.stream.listen((value) {
      _bytes.addAll(value);
      received += value.length;
    }).asFuture();

    String filepath =
        '${await getDocumentsPath()}\\PixieLauncherInstances\\debug\\assets\\objects\\' +
            objects[objectEnteries[i]]["hash"].substring(0, 2) +
            '\\' +
            objects[objectEnteries[i]]["hash"];
    String parentDirectory = path.dirname(filepath);
    await Directory(parentDirectory).create(recursive: true);
    await File(filepath).writeAsBytes(_bytes);
    //   print('done with ' + i.toString());
  }

  downloadForgeClient(Version version, ModloaderVersion modloaderVersion,
      [String? additional]) async {

    //https://maven.minecraftforge.net/net/minecraftforge/forge/1.19.4-45.1.16/forge-1.19.4-45.1.16-installer.jar

    String url =
        "https://maven.minecraftforge.net/net/minecraftforge/forge/${version.toString()}-${modloaderVersion.toString()}${additional == null ? "" : "-" + additional}/forge-${version.toString()}-${modloaderVersion.toString()}${additional == null ? "" : "-" + additional}-installer.jar";

        print(url);

    List<int> _bytes = [];
    int received = 0;
    http.StreamedResponse? response =
        await http.Client().send(http.Request('GET', Uri.parse(url)));

    await response.stream.listen((value) {
      _bytes.addAll(value);
      received += value.length;
    }).asFuture();

    await Utils.extractForgeInstaller(_bytes, version, modloaderVersion);
  }

  downloadSingeFile(String url, String to) async {
    List<int> _bytes = [];
    http.StreamedResponse? response =
        await http.Client().send(http.Request('GET', Uri.parse(url)));

    await response.stream.listen((value) {
      _bytes.addAll(value);
    }).asFuture();
    String parentDirectory = path.dirname(to);
    await Directory(parentDirectory).create(recursive: true);
    await File(to).writeAsBytes(_bytes);
  }
}
