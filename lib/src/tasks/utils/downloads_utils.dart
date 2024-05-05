import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/models/download_states.dart';
import 'package:mclauncher4/src/tasks/models/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/utils/downloader.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:path/path.dart' as path;
import 'utils.dart';
import '../config/apis.dart';

class DownloadUtils with ChangeNotifier {
  DownloadState _state = DownloadState.notDownloaded;
  DownloadState get downloadstate => _state;
  double _progress = 0.0;
  double get progress => _progress;

  late String os;
  late String arch;
  bool? isForge;
  int received = 0;
  DownloadUtils({this.isForge}) {
    if (Platform.isMacOS) {
      os = "osx";
      arch = "arm64";
    } else if (Platform.isWindows) {
      os = "windows";
      arch = "x86";
    } else if (Platform.isLinux) {
      os = "linux";
      arch = "x86";
    } else {
      //  throw "plattform not supported!";
    }
  }

  Future downloadLibaries(Map profile,
      [Version? version, ModloaderVersion? modloaderVersion]) async {
    if (profile["libraries"] == null) return;

    List libraries = profile["libraries"];

    int downloads_at_same_time = 20;
    int totalitems = libraries.length;

    for (var i = 0; i <= libraries.length; i += downloads_at_same_time) {

      Iterable<Future<dynamic>> downloads = Iterable.generate(
          downloads_at_same_time > totalitems
              ? totalitems
              : downloads_at_same_time, (index) async {
        Map current = libraries[i + index];
        // print(current["downloads"]["artifact"]);

        if (current["rules"] != null) {
          if (current["rules"].last["os"]["name"] == os &&
              current["rules"].last["action"] == "disallow") {
            print(current["name"]);
            return;
          }
        }


        if (current["natives"] != null && current["natives"][os] != null) {
          print("found valid native!");
          final lib = current["downloads"]["classifiers"]
              [current["natives"][os].replaceAll("\${arch}", arch)];
          print(lib);

          String filepath = path.join(
              getDocumentsPath(),
              "PixieLauncherInstances",
              "debug",
              "libraries",
              ((lib["path"] as String).replaceAll('/', path.separator)));

          if (lib["url"] == "" || lib["url"] == null) {
            File movepath = File(path.join(
                getTempForgePath(),
                version.toString(),
                modloaderVersion.toString(),
                "maven",
                current["path"]));

            if (movepath.existsSync()) {
              Utils.copyFile(source: movepath, destination: File(filepath));
            }
          } else {
            print("need to download and extract: " +
                filepath +
                " | from: " +
                lib["url"]);

            var _downloader = Downloader(lib["url"], filepath);

            await _downloader.startDownload();
            //unzipPath: path.join(getbinpath(), version.toString())
          await  _downloader.unzip(
                unzipPath: path.join(getbinpath(), version.toString()));
            print("done with export");
          }
        }

        if (current["downloads"]["artifact"] != null) {
          final lib = current["downloads"]["artifact"];

          String filepath = path.join(
              getDocumentsPath(),
              "PixieLauncherInstances",
              "debug",
              "libraries",
              ((lib["path"] as String).replaceAll('/', path.separator)));

          var _downloader = Downloader(lib["url"], filepath);

          if (lib["url"] != null && lib["url"] != "") {
            print("artifact can be downloaded: " + filepath);
            await _downloader.startDownload();
        
          } else {
            File movepath = File(path.join(
                getTempForgePath(),
                version.toString(),
                modloaderVersion.toString(),
                "maven",
                lib["path"]));

            print("need to move: " + movepath.path + " | To: " + filepath);

            if (movepath.existsSync()) {
              Utils.copyFile(source: movepath, destination: File(filepath));
            }
          }
        }
      });

      await Future.wait(downloads);

      totalitems -= downloads_at_same_time;
      print((i / libraries.length));
      print(totalitems);
      _progress = (i / libraries.length) * 100;
      _state = DownloadState.downloadingLibraries;
      notifyListeners();
    }
    print("done with libraries <==========");
  }

  getOldUniversal(Map install_profileJson, Version version,
      ModloaderVersion modloaderVersion) async {
    if (install_profileJson["install"] == null) return;
    Map install_profile = install_profileJson["install"];
    File filepath = File(path.join(getlibarypath(), "libraries",
        Utils.parseMaven(install_profile["path"])));
    print('parsing ${filepath.path} ');

    if (!(await filepath.exists()))
      throw "the file does not exist, mabye you called the method before you installed the libraries";

    List<int> _bytes = await File(path.join(
            getTempForgePath(),
            version.toString(),
            modloaderVersion.toString(),
            install_profile["filePath"]))
        .readAsBytes();
    await File(path.join(getlibarypath(), "libraries",
            Utils.parseMaven(install_profile["path"])))
        .writeAsBytes(_bytes);
  }

  Future<Map> getJson(Version version) async {
    late String url;
    var minecraftManifestRES = await http.get(Uri.parse(
        'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json'));
    List minecraftManifest = jsonDecode(minecraftManifestRES.body)['versions'];

    for (Map versionjson in minecraftManifest) {
      if (versionjson["id"] == "$version") url = versionjson["url"];
    }
    var packagejsonRES = await http.get(Uri.parse(url));
    Map packagejson = jsonDecode(packagejsonRES.body);
    return packagejson;
  }

  Future downloadClient(Map packagejson) async {
    _state = DownloadState.downloadingClient;
    notifyListeners();
    String mcversion = packagejson["id"];

    String filepath = path.join(getDocumentsPath(), "PixieLauncherInstances",
        "debug", "versions", mcversion, mcversion + ".json");

    String parentDirectory = path.dirname(filepath);
    await Directory(parentDirectory).create(recursive: true);
    await File(filepath).writeAsBytes(utf8.encode(jsonEncode(packagejson)));

    var clientRES =
        await http.get(Uri.parse(packagejson["downloads"]["client"]["url"]));
    await File(path.join(getDocumentsPath(), "PixieLauncherInstances", "debug",
            "versions", mcversion, mcversion + ".jar"))
        .writeAsBytes(clientRES.bodyBytes);
  }

  _writeAssetsjson(Map packagejson) async {
    String filepath = path.join(getDocumentsPath(), "PixieLauncherInstances",
        "debug", "assets", "indexes", '${packagejson["assets"]}.json');
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
    int downloads_at_same_time = 120;

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
      _progress = (i / objects.length) * 100;
      _state = DownloadState.downloadAssets;
      notifyListeners();
    }
    print("done with ASSETS <=======================");
  }

  //private Method
  _downloadForAssets(Map objects, List objectEnteries, int total, int i,
      http.Client client) async {
    // print('downloading is called' + i.toString());
    String url = minecraftResources +
        objects[objectEnteries[i]]["hash"].substring(0, 2) +
        '/' +
        objects[objectEnteries[i]]["hash"];

    String filepath = path.join(
        getDocumentsPath(),
        "PixieLauncherInstances",
        "debug",
        "assets",
        "objects",
        objects[objectEnteries[i]]["hash"].substring(0, 2),
        objects[objectEnteries[i]]["hash"]);
    //Downloading..
    await Downloader(url, filepath).startDownload();

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

    http.Response head_response = await http.head(Uri.parse(url));

    int _totalsize = int.parse(head_response.headers["content-length"] ?? "");
    int received = 0;
    int receivedControll = 0;
    print(_totalsize);

    http.StreamedResponse? response =
        await http.Client().send(http.Request('GET', Uri.parse(url)));

    await response.stream.listen((value) {
      _bytes.addAll(value);
      received += value.length;
      receivedControll += value.length;
      if (receivedControll > _totalsize / 100) {
        _progress = received / _totalsize;
        _state = DownloadState.customDownload;
        notifyListeners();
        receivedControll = 0;
      }
    }).asFuture();

    String parentDirectory = path.dirname(to);
    await Directory(parentDirectory).create(recursive: true);
    await File(to).writeAsBytes(_bytes);
    _bytes = [];
  }

  Future<List<int>> downloadSingeFileAsBytes(String url) async {
    List<int> _bytes = [];

    http.Response head_response = await http.head(Uri.parse(url));

    int _totalsize = int.parse(head_response.headers["content-length"] ?? "");
    int received = 0;
    int receivedControll = 0;
    print(_totalsize);

    http.StreamedResponse? response =
        await http.Client().send(http.Request('GET', Uri.parse(url)));

    await response.stream.listen((value) {
      _bytes.addAll(value);
      received += value.length;
      receivedControll += value.length;
      if (receivedControll > _totalsize / 100) {
        _progress = received / _totalsize;
        _state = DownloadState.customDownload;
        notifyListeners();
        receivedControll = 0;
      }
    }).asFuture();

    return _bytes;
  }
}
