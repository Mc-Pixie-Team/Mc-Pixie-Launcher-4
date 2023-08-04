import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mclauncher4/tasks/version.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../config/apis.dart';

class Download {
  final Future<Directory> appDocumentsDir = getApplicationDocumentsDirectory();
  bool? isForge;
  int received = 0;
  Download({this.isForge});
  String os = "windows";

  Future downloadLibaries(Map profile) async {
    List libraries = profile["libraries"];
    print(libraries.length);
    for (int i = 0; i < libraries.length; i++) {
      
    Map current = libraries[i];

    if(current["natives"] != null && current["natives"][os] != null) {
      print('downloading native: '+ current["name"] );
     await _downloadForLibraries(current["downloads"]["classifiers"][current["natives"][os]], altpath: 'assets\\');
    }    
    await _downloadForLibraries(current["downloads"]["artifact"]);
      
      
    }
  }

  _downloadForLibraries(Map current,{ String? altpath}) async{
    List<int> _bytes = [];
    int total = current["size"],
          received = 0,
          receivedControll = 0;

    http.StreamedResponse? response = await http.Client().send(http.Request(
          'GET', Uri.parse(current["url"])));
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
      String filepath =
          '${(await appDocumentsDir).path}\\PixieLauncherInstances\\debug\\libraries\\${ altpath != null ? altpath + path.basename(((current["path"] as String).replaceAll('/', '\\'))) :((current["path"] as String).replaceAll('/', '\\'))}';
          
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
    await File(filepath).writeAsBytes(utf8.encode(packagejson.toString()));

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
    //Sweet spot: 15 || 1:35 || 1.19.2
    int downloads_at_same_time = 15;
    int _totalitems = objects.length;
    for (var i = 0; objects.length > i;) {
      print('generating');
      Iterable<Future<dynamic>> downloads = Iterable.generate(
          downloads_at_same_time >_totalitems ? _totalitems : downloads_at_same_time,
          (index) =>
              _downloadForAssets(objects, objectEnteries, total, i + index));
      await Future.wait(downloads);
      i += downloads_at_same_time;
      _totalitems = _totalitems - downloads_at_same_time;
      print(((received / total) * 100).roundToDouble().toString() + '%');
      print(_totalitems);
    }
  }

  //private Method
  _downloadForAssets(Map objects, List objectEnteries, int total, int i) async {
    // print('downloading is called' + i.toString());
    String url = minecraftResources +
        objects[objectEnteries[i]]["hash"].substring(0, 2) +
        '/' +
        objects[objectEnteries[i]]["hash"];

    //Downloading..
    List<int> _bytes = [];
    http.StreamedResponse? response =
        await http.Client().send(http.Request('GET', Uri.parse(url)));

    await response.stream.listen((value) {
      _bytes.addAll(value);
      received += value.length;
    }).asFuture();

    String filepath =
        '${(await appDocumentsDir).path}\\PixieLauncherInstances\\debug\\assets\\objects\\' + objects[objectEnteries[i]]["hash"].substring(0, 2) + '\\' +
            objects[objectEnteries[i]]["hash"];
    String parentDirectory = path.dirname(filepath);
    await Directory(parentDirectory).create(recursive: true);
    await File(filepath).writeAsBytes(_bytes);
    //   print('done with ' + i.toString());
  }
}
