import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/forgeversion.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/version.dart';
import 'package:path/path.dart' as path;
import 'utils.dart';
import 'package:path_provider/path_provider.dart';
import '../config/apis.dart';

class Download {
  final Future<Directory> appDocumentsDir = getApplicationDocumentsDirectory();
  bool? isForge;
  int received = 0;
  Download({this.isForge});
  String os = "windows";
  String arch = "64";

  Future downloadLibaries(Map profile,
      [Version? version, ForgeVersion? forgeVersion]) async {
       if( profile["libraries"] == null) return;
    List libraries = profile["libraries"];
    print(libraries.length);
    for (int i = 0; i < libraries.length; i++) {
      Map current = libraries[i];

      if (current["natives"] != null && current["natives"][os] != null) {
        print('downloading native: ' + current["name"]);

        await _downloadForLibraries(current["downloads"]["classifiers"]
            [current["natives"][os].replaceAll("\${arch}", arch)]);
        await Utils.extractNativesfromjar(
            current["downloads"]["classifiers"]
                [current["natives"][os].replaceAll("\${arch}", arch)]["path"],
            profile["id"]);
      }
      if (current["downloads"]["artifact"] == null) continue;
      await _downloadForLibraries(current["downloads"]["artifact"],
          version: version, forgeVersion: forgeVersion);
    }
  }

  _downloadForLibraries(Map current,
      {String? altpath, Version? version, ForgeVersion? forgeVersion}) async {
    List<int> _bytes = [];
    int total = current["size"], received = 0, receivedControll = 0;

    if (current["url"] == "" || current["url"] == null) {
      if (version == null || forgeVersion == null)
        throw "unable to handle version cause it empty.";
      _bytes = await File(
              '${await getTempForgePath()}\\$version\\$forgeVersion\\maven\\${current["path"]}')
          .readAsBytes();
    } else {
      http.StreamedResponse? response = await http.Client()
          .send(http.Request('GET', Uri.parse(current["url"])));
      print('downloading: ' + current["path"].toString());
      await response.stream.listen((value) {
        _bytes.addAll(value);
        received += value.length;
        receivedControll += value.length;
        if (receivedControll > total / 10) {
          print(((received / total) * 100).toString() + '%');
          receivedControll = 0;
        }
      }).asFuture();
    }

    String filepath =
        '${(await appDocumentsDir).path}\\PixieLauncherInstances\\debug\\libraries\\${altpath != null ? altpath + path.basename(((current["path"] as String).replaceAll('/', '\\'))) : ((current["path"] as String).replaceAll('/', '\\'))}';

    String parentDirectory = path.dirname(filepath);

    await Directory(parentDirectory).create(recursive: true);

    await File(filepath).writeAsBytes(_bytes);
    _bytes = []; //reset;
  }

  Future<Map> getJson(String url) async {
    var packagejsonRES = await http.get(Uri.parse(url));
    Map packagejson = jsonDecode(packagejsonRES.body);
    return packagejson;
  }

  Future downloadClient(Map packagejson) async {
    String mcversion = packagejson["id"];

    String filepath =
        '${(await appDocumentsDir).path}\\PixieLauncherInstances\\debug\\versions\\$mcversion\\$mcversion.json';

    String parentDirectory = path.dirname(filepath);
    await Directory(parentDirectory).create(recursive: true);
    await File(filepath).writeAsBytes(utf8.encode(jsonEncode(packagejson)));

    print(packagejson);
    var clientRES =
        await http.get(Uri.parse(packagejson["downloads"]["client"]["url"]));
    await File(
            '${(await appDocumentsDir).path}\\PixieLauncherInstances\\debug\\versions\\$mcversion\\$mcversion.jar')
        .writeAsBytes(clientRES.bodyBytes);
  }

  _writeAssetsjson(Map packagejson) async {
    String filepath =
        '${(await appDocumentsDir).path}\\PixieLauncherInstances\\debug\\assets\\indexes\\${packagejson["assets"]}.json';
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
    print(objects[objectEnteries[0]]);

    //sorts all hashes to donwloads
    //Sweet spot: 10 || 40 sec || 1.20.1
    int downloads_at_same_time = 10;

    int _totalitems = objects.length;
    http.Client client = http.Client();
    for (var i = 0; objects.length > i;) {
      print('generating');
      Iterable<Future<dynamic>> downloads = Iterable.generate(
          downloads_at_same_time > _totalitems
              ? _totalitems
              : downloads_at_same_time,
          (index) => _downloadForAssets(
              objects, objectEnteries, total, i + index, client));
      await Future.wait(downloads);
      i += downloads_at_same_time;
      _totalitems = _totalitems - downloads_at_same_time;
      print(((received / total) * 100).roundToDouble().toString() + '%');
      print(_totalitems);
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
        '${(await appDocumentsDir).path}\\PixieLauncherInstances\\debug\\assets\\objects\\' +
            objects[objectEnteries[i]]["hash"].substring(0, 2) +
            '\\' +
            objects[objectEnteries[i]]["hash"];
    String parentDirectory = path.dirname(filepath);
    await Directory(parentDirectory).create(recursive: true);
    await File(filepath).writeAsBytes(_bytes);
    //   print('done with ' + i.toString());
  }

  downloadForgeClient(Version version, ForgeVersion forgeVersion,
      [String? additional]) async {
    //https://maven.minecraftforge.net/net/minecraftforge/forge/1.19.4-45.1.16/forge-1.19.4-45.1.16-installer.jar

    String url =
        "https://maven.minecraftforge.net/net/minecraftforge/forge/${version.toString()}-${forgeVersion.toString()}${additional == null ? "" : "-" + additional}/forge-${version.toString()}-${forgeVersion.toString()}${additional == null ? "" : "-" + additional}-installer.jar";

    List<int> _bytes = [];
    int received = 0;
    http.StreamedResponse? response =
        await http.Client().send(http.Request('GET', Uri.parse(url)));

    await response.stream.listen((value) {
      _bytes.addAll(value);
      received += value.length;
    }).asFuture();

    await Utils.extractForgeInstaller(_bytes, version, forgeVersion);
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
