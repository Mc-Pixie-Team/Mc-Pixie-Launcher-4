import "package:flutter/material.dart";
import "package:mclauncher4/src/objects/accounts/minecraft.dart";
import 'package:mclauncher4/src/tasks/models/download_states.dart';
import 'package:mclauncher4/src/tasks/models/modloaderVersion.dart';
import "package:mclauncher4/src/tasks/java/java.dart";
import 'package:mclauncher4/src/tasks/models/version_object.dart';
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

    List<String> launchcommand =
        await getlaunchCommand(instanceName, packagejson, os, version);

    print(launchcommand);
    // var tempFile = File(
    //     "${(await path_provider.getTemporaryDirectory()).path}\\pixie\\temp_command.ps1");
    // await tempFile.create(recursive: true);
    // await tempFile.writeAsString(launchcommand);

    var result = await Process.start(
        Java.getJavaJdk(version), launchcommand,
        runInShell: true);

    stdout.addStream(result.stdout);
    stderr.addStream(result.stderr);
  }

  Future<List<String>> getlaunchCommand(
      String instanceName, Map packagejson, String os, Version version,
      [ModloaderVersion? modloaderVersion]) async {
    List<String> launchcommand;
    Map<String, List> args;
    String majorVer = Java.getJavaJdk(version);

    if (version < Version(1, 13, 0)) {
 
      List<String> gameArgs = (packagejson["minecraftArguments"] as String).split(" ");
      print('installing under 1.13.0 !');
      print(gameArgs);

    
     args = await overrideArguments(["-Djava.library.path=\${natives_directory}", "-cp", "\${classpath}" ],
         gameArgs, packagejson,instanceName, os);

      
   
    }else {
      args = await getArgs(packagejson, os,instanceName);
    }

    
    print(args);
    launchcommand =
        ["-Xmx16064m", "-Xms256m", ...args["jvm"]!,  packagejson["mainClass"], ...args["game"]!];

    return launchcommand;
  }

  Future<Map<String, List>> getArgs(
    Map packagejson,
    String os,
    String instanceName
  ) async {
    Map vanillaArgs = packagejson["arguments"];
    List<String> jvmArgs = [];
    List<String> gameArgs = [];
    for (var i = 0; i < vanillaArgs["jvm"].length; i++) {
      if (vanillaArgs["jvm"][i] is String) {
         jvmArgs.add( '${vanillaArgs["jvm"][i]}');
      } else {
        if (chechAllowed(
          (vanillaArgs["jvm"][i]["rules"]),
          "windows",
          "x64",
        )) {
          if (vanillaArgs["jvm"][i]["value"] is List) {
            for (var j = 0; j < vanillaArgs["jvm"][i]["value"].length; j++) {
              jvmArgs.add( '${vanillaArgs["jvm"][i]["value"][j]}');
            }
          } else {
              jvmArgs.add( '${vanillaArgs["jvm"][i]["value"]}');
          }
        }
      }
    }
    for (var i = 0; i < vanillaArgs["game"].length; i++) {
      if (vanillaArgs["game"][i] is String) {
        gameArgs.add( "${vanillaArgs["game"][i]}");
      } else {
        if (chechAllowed(
          (vanillaArgs["game"][i]["rules"]),
          "windows",
          "x64",
        )) {
          gameArgs.add( "${vanillaArgs["game"][i]["value"]}");
        }
      }
    }
    return await overrideArguments(jvmArgs, gameArgs, packagejson,instanceName, os);
  }

 Future<Map<String, List<String>>> overrideArguments(List<String> jvmArgs, List<String> gameArgs, packagejson, String instanceName, os) async {
    MinecraftAccount? minecraftAccount = await MinecraftAccountUtils().getStandard();
    Map minecraftToken = await MinecraftAccountUtils().reAuthenticateAndUpdateAccount(minecraftAccount!);



    String natives_directory =
        "${await getworkpath()}\\bin\\${packagejson["id"]}";
    String launcher_name = "Mc-pixie";
    String launcher_version = "4";
    String auth_player_name = minecraftAccount.username;
    String version_name = packagejson["id"];
    String game_directory = '${await getInstancePath()}\\$instanceName';
    String assets_root = "${await getworkpath()}\\assets";
    String assets_index_name = packagejson["assets"];
    String auth_uuid = minecraftAccount.uuid;
    String auth_access_token = minecraftToken["authToken"];
       
    String clientid = "";
    String auth_xuid = "";
    String user_type = "mojang";
    String version_type = "Pixie";
    String classpath_separator = "${(os == "windows") ? ";" : ":"}";

    String library_directory = "${await getlibarypath()}\\libraries";
    String user_properties = '{}';
    print(jvmArgs);
    print(gameArgs);

    for (var i = 0; i < jvmArgs.length; i++) {
      String arg = jvmArgs[i];
     arg = arg
        .replaceAll("\${natives_directory}", natives_directory)
        .replaceAll("\${launcher_name}", launcher_name)
        .replaceAll("\${launcher_version}", launcher_version)
        .replaceAll("\${classpath}", '${await getCP(packagejson, os)}')
        .replaceAll("\${auth_player_name}", '"${await getCP(packagejson, os)}"')
        .replaceAll("\${library_directory}", library_directory)
        .replaceAll("\${classpath_separator}", classpath_separator)
        .replaceAll("\${version_name}", version_name);
      jvmArgs[i] = arg;
    }

      
    for (var i = 0; i < gameArgs.length; i++) {
        String arg = gameArgs[i];
        
        arg = arg
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

        gameArgs[i] = arg;
      }
  

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
