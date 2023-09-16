import "package:flutter/material.dart";
import "package:mclauncher4/src/tasks/downloadState.dart";
import 'package:mclauncher4/src/tasks/modloaderVersion.dart';
import "package:mclauncher4/src/tasks/java/java.dart";
import "package:mclauncher4/src/tasks/version.dart";
import "package:path_provider/path_provider.dart" as path_provider;
import "dart:convert";
import "dart:io";
import "../utils/downloads.dart";
import '../utils/path.dart';

class Minecraft with ChangeNotifier {
  ClientInstallState _state = ClientInstallState.downloadingLibraries;
  ClientInstallState get installstate => _state;
  double _progress = 0.0;
  double get progress => _progress;
  double _mainprogress = 0.0; 
  double get mainprogress => _mainprogress;
  Download _downloader = Download();


   getsteps(Version? version, [ModloaderVersion? modloaderVersion]) {
    return 2;
   }

  install(Version version) async {
      var _1 = 0.0;
      var _2 = 0.0;
      var _raw = 0.0;
    _downloader.addListener(() {
      if (_downloader.downloadstate == DownloadState.downloadingLibraries) {
        _raw  += _downloader.progress - _1;
        _1 = _downloader.progress;
        _progress = _downloader.progress;
        _state = ClientInstallState.downloadingLibraries;
        _mainprogress =  _raw / getsteps(version);
        notifyListeners();
      } else if (_downloader.downloadstate == DownloadState.downloadAssets) {
         _raw  += _downloader.progress - _2;
        _2 = _downloader.progress;
        _progress = _downloader.progress;
        _state = ClientInstallState.downloadAssets;
        
         _mainprogress = _raw / getsteps(version);
        notifyListeners();
      }
    });
    Map res = await _downloader.getJson(version);
    await Future.wait([_downloader.downloadLibaries(res),_downloader.downloadAssets(res) ]);
    await _downloader.downloadClient(res);
  

    // await _downloader.downloadLibaries(res);
    // _state = InstallState.downloadingClient;
    // await _downloader.downloadClient(res);
    // _state = InstallState.downloadAssets;
    // await _downloader.downloadAssets(res);
  }

  void run(Map packagejson, String instanceName) async {
    String os = "windows";
    String accessToken = "3423423jdisgjsdf";
    String username = "Fridolin";
    String stack = "";
    List<String> valuesString = (packagejson["id"] as String).split('.');
    Version version = new Version(int.parse(valuesString[0]),
        int.parse(valuesString[1]), int.parse(valuesString[2]));

    String launchcommand =
        await getlaunchCommand(instanceName, packagejson, os, version);

    print(launchcommand);
    var tempFile = File(
        "${(await path_provider.getTemporaryDirectory()).path}\\pixie\\temp_command.ps1");
    await tempFile.create(recursive: true);
    await tempFile.writeAsString(launchcommand);

    var result = await Process.start(
        "powershell", ["-ExecutionPolicy", "Bypass", "-File", tempFile.path],
        runInShell: true);

    stdout.addStream(result.stdout);
    stderr.addStream(result.stderr);
  }

  getlaunchCommand(
      String instanceName, Map packagejson, String os, Version version,
      [ModloaderVersion? modloaderVersion]) async {
    String launchcommand;
    Map args;
    String majorVer = Java.getJavaJdk(version);

    if (version < Version(1, 13, 0)) {
      Map args = await overrideArguments('"-Djava.library.path=\${natives_directory}" -cp "\${classpath}" ',
          packagejson["minecraftArguments"], packagejson,instanceName, os);

      launchcommand =
          '& "$majorVer" "-Xmx16064m" "-Xms256m" ${args["jvm"]}${packagejson["mainClass"]} ${args["game"]}';
      return launchcommand;
    }

    args = await getArgs(packagejson, os,instanceName);
    launchcommand =
        '& "$majorVer" "-Xmx16064m" "-Xms256m" ${args["jvm"]}${packagejson["mainClass"]} ${args["game"]}';

    return launchcommand;
  }

  Future<Map> getArgs(
    Map packagejson,
    String os,
    String instanceName
  ) async {
    Map vanillaArgs = packagejson["arguments"];
    String jvmArgs = "";
    String gameArgs = "";
    for (var i = 0; i < vanillaArgs["jvm"].length; i++) {
      if (vanillaArgs["jvm"][i] is String) {
        if (vanillaArgs["jvm"][i].startsWith("--")) {
          jvmArgs += '${vanillaArgs["jvm"][i]} ';
        } else {
          jvmArgs += '"${vanillaArgs["jvm"][i]}" ';
        }
      } else {
        if (chechAllowed(
          (vanillaArgs["jvm"][i]["rules"]),
          "windows",
          "x64",
        )) {
          if (vanillaArgs["jvm"][i]["value"] is List) {
            for (var j = 0; j < vanillaArgs["jvm"][i]["value"].length; j++) {
              if (vanillaArgs["jvm"][i]["value"][j].startsWith("--")) {
                jvmArgs += '${vanillaArgs["jvm"][i]["value"][j]} ';
              } else {
                jvmArgs += '"${vanillaArgs["jvm"][i]["value"][j]}" ';
              }
            }
          } else {
            if (vanillaArgs["jvm"][i]["value"].startsWith("--")) {
              jvmArgs += '${vanillaArgs["jvm"][i]["value"]} ';
            } else {
              jvmArgs += '"${vanillaArgs["jvm"][i]["value"]}" ';
            }
          }
        }
      }
    }
    for (var i = 0; i < vanillaArgs["game"].length; i++) {
      if (vanillaArgs["game"][i] is String) {
        gameArgs += "${vanillaArgs["game"][i]} ";
      } else {
        if (chechAllowed(
          (vanillaArgs["game"][i]["rules"]),
          "windows",
          "x64",
        )) {
          gameArgs += "${vanillaArgs["game"][i]["value"]} ";
        }
      }
    }
    return await overrideArguments(jvmArgs, gameArgs, packagejson,instanceName, os);
  }

  overrideArguments(String jvmArgs, String gameArgs, packagejson, String instanceName, os) async {
    String natives_directory =
        "${await getworkpath()}\\bin\\${packagejson["id"]}";
    String launcher_name = "Mc-pixie";
    String launcher_version = "4";
    String auth_player_name = "joshiGaming_YT";
    String version_name = packagejson["id"];
    String game_directory = '${await getInstancePath()}\\$instanceName';
    String assets_root = "${await getworkpath()}\\assets";
    String assets_index_name = packagejson["assets"];
    String auth_uuid = "12d4995b6a234bafbd25fc606ba4299c";
    String auth_access_token =
        "eyJraWQiOiJhYzg0YSIsImFsZyI6IkhTMjU2In0.eyJ4dWlkIjoiMjUzNTQ0MTQxNTEzODMwNCIsImFnZyI6IkFkdWx0Iiwic3ViIjoiYzQ1ODdkYzktZWZlMy00NWFhLTk1NTYtM2UzNzkxNmFiYTMyIiwiYXV0aCI6IlhCT1giLCJucyI6ImRlZmF1bHQiLCJyb2xlcyI6W10sImlzcyI6ImF1dGhlbnRpY2F0aW9uIiwiZmxhZ3MiOlsidHdvZmFjdG9yYXV0aCIsIm9yZGVyc18yMDIyIl0sInBsYXRmb3JtIjoiUENfTEFVTkNIRVIiLCJ5dWlkIjoiMGQ3MDUwMjI3NGNkNTkzNWMyNDU4YTVlZjFiMjhjMzAiLCJuYmYiOjE2OTQwMjA0NzgsImV4cCI6MTY5NDEwNjg3OCwiaWF0IjoxNjk0MDIwNDc4fQ.XY8i-HKQ-yMimb8DqZLCfL_TS0i5XY_v1lPE3c9OmZY";
    String clientid = "";
    String auth_xuid = "";
    String user_type = "mojang";
    String version_type = "Pixie";
    String classpath_separator = "${(os == "windows") ? ";" : ":"}";

    String library_directory = "${await getlibarypath()}\\libraries";
    String user_properties = '"{}"';
    print(jvmArgs);
    print(gameArgs);
    jvmArgs = jvmArgs
        .replaceAll("\${natives_directory}", natives_directory)
        .replaceAll("\${launcher_name}", launcher_name)
        .replaceAll("\${launcher_version}", launcher_version)
        .replaceAll("\${classpath}", '${await getCP(packagejson, os)}')
        .replaceAll("\${auth_player_name}", '"${await getCP(packagejson, os)}"')
        .replaceAll("\${library_directory}", library_directory)
        .replaceAll("\${classpath_separator}", classpath_separator)
        .replaceAll("\${version_name}", version_name);

    gameArgs = gameArgs
        .replaceAll("\${auth_player_name}", auth_player_name)
        .replaceAll("\${version_name}", version_name)
        .replaceAll("\${game_directory}", game_directory)
        .replaceAll("\${assets_root}", assets_root)
        .replaceAll("\${assets_index_name}", assets_index_name)
        .replaceAll("\${auth_uuid}", auth_uuid)
        .replaceAll("\${auth_access_token}", auth_access_token)
        .replaceAll("\${clientid}", clientid)
        .replaceAll("\${auth_xuid}", auth_xuid)
        .replaceAll("\${user_type}", user_type)
        .replaceAll("\${version_type}", version_type)
        .replaceAll("\${user_properties}", user_properties);

    return {
      "jvm": jvmArgs,
      "game": gameArgs,
    };
  }

  Future<String> getCP(Map packagejson, String os) async {
    String path = "${await getlibarypath()}\\libraries";
    List libraries = packagejson["libraries"];

    String stack =
        "${await getworkpath()}\\versions\\${packagejson["id"]}\\${packagejson["id"]}.jar${(os == "windows") ? ";" : ":"}";
    for (var i = 0; i < libraries.length; i++) {
      Map libary = libraries[i];
      if (libary["rules"] == null) {
      } else if (chechAllowed(
            libary["rules"],
            os,
            "x64",
          ) ==
          false) {
        continue;
      }
      if (libary["natives"] != null && libary["natives"][os] != null) {
        stack +=
            "$path/${libary["downloads"]["classifiers"][libary["natives"][os].replaceAll("\${arch}", "64")]["path"]}${(os == "windows") ? ";" : ":"}";
      }
      if (libary["downloads"]["artifact"] == null) continue;
      stack +=
          "$path/${libary["downloads"]["artifact"]["path"]}${(os == "windows") ? ";" : ":"}";
    }
    return stack;
  }

  bool chechAllowed(List rules, String osName, String osArch) {
    if (rules.isEmpty) {
      return true;
    }

    if (rules.last["os"] == null) {
      return false; //Not a really good solution but it will do it
    }

    if (rules.length == 1) {
      if (rules.last["action"] == "allow" &&
          rules.last["os"]["name"] == osName) {
        return true;
      }
      return false;
    }

    if (rules.last["action"] == "disallow" &&
        rules.last["os"]["name"] == osName) {
      return false;
    }

    if (rules.first["action"] == "allow") {
      return true;
    }
    return false;
  }
}
