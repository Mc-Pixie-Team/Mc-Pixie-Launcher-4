import 'dart:async';
import 'dart:io';

import 'package:mclauncher4/src/objects/accounts/minecraft.dart';
import 'package:mclauncher4/src/tasks/installs/install_utils.dart';
import 'package:mclauncher4/src/tasks/installs/java/rutime.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:path/path.dart' as p;

class MinecraftCommand {

  static Future<List<String>> getlaunchCommand( Map versiondata, String path, String processId) async {
    List command = [];

    if (versiondata["arguments"] != null) {
      Map arguments = versiondata["arguments"];
      
      // Adding all Java Runtime Arguments + Classpath
      if (arguments["jvm"] != null) {
        command.addAll(_addRules(arguments["jvm"]));
      }
      if (versiondata["mainClass"] != null) {
        command.add(versiondata["mainClass"]);
      }
      // Adding all Game Arguments
      if (arguments["game"] != null) {
        command.addAll(_addRules(arguments["game"]));
      }
    } else if (versiondata["minecraftArguments"] != null) {

      List<String> game = (versiondata["minecraftArguments"] as String).split(" ");
      command.addAll([
        "-Djava.library.path=\${natives_directory}",
        "-cp",
        "\${classpath}",
        versiondata["mainClass"],
        ...game
      ]);
    }

    List<String> returncommand = await overrideArguments(command, versiondata, path, processId);
    return returncommand;
  }

  static List<dynamic> _addRules(List command) {
    List deepCopy = [];
    for (var arg in command) {
      if (arg is String) {
        deepCopy.add(arg);
      } else if (arg is Map) {
        if (InstallUtils.parseRuleList(arg["rules"], options: [])) {
          if (arg["value"] is Iterable) {
            deepCopy.addAll(arg["value"]);
          } else {
            deepCopy.add(arg["value"]);
          }
        }
      }
    }
    return deepCopy;
  }

//MARK: Arguments Override

  static Future<List<String>> overrideArguments(
      List<dynamic> command, Map versionData, String path, String processId) async {
    print("Getting Minecraft credentials...");
    MinecraftAccount? minecraftAccount = await MinecraftAccountUtils().getStandard();
    Map minecraftToken = await MinecraftAccountUtils().reAuthenticateAndUpdateAccount(minecraftAccount!);
    print("Done!");
    print(versionData["nativesPath"]);

    String natives_directory = p.join(versionData["nativesPath"]);
    String launcher_name = "Mc-pixie";
    String launcher_version = "4";
    String auth_player_name = minecraftAccount.username;
    String version_name = versionData["id"];
    String game_directory = p.join(getInstancePath(), processId);
    String assets_root = p.join(path, "assets");
    String assets_index_name = versionData["assets"];
    String auth_uuid = minecraftAccount.uuid;
    String auth_access_token = minecraftToken["authToken"] ?? "dfdffdfd";
    String clientid = "";
    String auth_xuid = "";
    String user_type = "mojang";
    String version_type = "Pixie";
    String classpath_separator = "${Platform.isWindows ? ";" : ":"}";
    String library_directory = p.join(getlibarypath(), "libraries");
    String user_properties = '{}';

    List<String> deepCopy = [];
    for (var arg in command) {
      if (!(arg is String)) {
        print("not a String found!");
        continue;
      }

      deepCopy.add(arg
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
          .replaceAll("\${user_properties}", user_properties)
          .replaceAll("\${natives_directory}", natives_directory)
          .replaceAll("\${launcher_name}", launcher_name)
          .replaceAll("\${launcher_version}", launcher_version)
          .replaceAll("\${classpath}", '${await getCP(versionData)}')
          .replaceAll("\${library_directory}", library_directory)
          .replaceAll("\${classpath_separator}", classpath_separator)
          .replaceAll("\${version_name}", version_name));
    }
    return deepCopy;
  }

  static Future<String> getCP(Map versionData) async {
    String libpath = p.join(getlibarypath(), "libraries");
    List libraries = versionData["libraries"];
    late String os;

    if (Platform.isMacOS) {
      os = "osx";
    } else if (Platform.isWindows) {
      os = "windows";
    } else if (Platform.isLinux) {
      os = "linux";
    } else {
      throw "plattform not supported!";
    }

    String stack =
        '${p.join(getworkpath(), "versions", versionData["id"], versionData["id"] + ".jar")}${Platform.isWindows ? ";" : ":"}';

    for (var i = 0; i < libraries.length; i++) {
      Map libary = libraries[i];
      if (libary["rules"] != null) {
        if (!InstallUtils.parseRuleList(libary["rules"])) continue;
      }

      if (libary["natives"] != null && libary["natives"][os] != null) {
        stack += "$libpath/${libary["downloads"]["classifiers"][libary["natives"][os].replaceAll("\${arch}", "64")]["path"]}${Platform.isWindows ? ";" : ":"}";
      }

      if (libary["downloads"]["artifact"] == null) continue;
      stack += "$libpath/${libary["downloads"]["artifact"]["path"]}${Platform.isWindows ? ";" : ":"}";
    }
    return stack;
  }
}
