import "package:mclauncher4/src/tasks/forgeversion.dart";
import "package:mclauncher4/src/tasks/version.dart";
import "package:path_provider/path_provider.dart" as path_provider;
import "dart:convert";
import "dart:io";
import "../utils/downloads.dart";
import '../utils/path.dart';

class Minecraft {
  final Future<Directory> appDocumentsDir =
      path_provider.getApplicationDocumentsDirectory();

  install(String url) async {
    Map res = await Download().getJson(url);

    await Download().downloadLibaries(res);
    await Download().downloadClient(res);
    await Download().downloadAssets(res);
  }

  void run(Map packagejson, String path) async {
    String os = "windows";
    String accessToken = "3423423jdisgjsdf";
    String username = "Fridolin";
    String stack = "";
    List<String> valuesString = (packagejson["id"] as String).split('.');
    Version version = new Version(int.parse(valuesString[0]),
        int.parse(valuesString[1]), int.parse(valuesString[2]));

    if (version < Version(1, 13, 0)) {
      throw ("Version not compatible");
    }

    //C:\\Users\\zepat\\Documents\\PixieLauncherInstances\\debug\\bin
    // print(stack);
    // C:\\Program Files\\Java\\jdk-17\\bin\\java.exe"

    String javaVer17 =
        "C:\\Users\\zepat\\Documents\\PixieLauncherInstances\\install debug\\runtime\\java-runtime-gamma\\windows-x64\\java-runtime-gamma\\bin\\java.exe";
    String javaVer8 =
        "C:\\Users\\zepat\\Documents\\PixieLauncherInstances\\install debug\\runtime\\jre-legacy\\windows-x64\\jre-legacy\\bin\\java.exe";
    String majorVer = javaVer8;

    if (version > Version(1, 16, 4)) {
      majorVer = javaVer17;
    }

    String launchcommand =
        '& "$majorVer" "-XX:HeapDumpPath=MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.heapdump" "-Dos.name=Windows 10" "-Dos.version=10.0" "-Djava.library.path=C:\\Users\\zepat\\Documents\\PixieLauncherInstances\\debug\\bin\\${packagejson["id"]}" -cp "$stack" net.minecraft.client.main.Main --username $username --version ${packagejson["id"]} --gameDir ${await getworkpath()} --assetsDir C:\\Users\\zepat\\Documents\\PixieLauncherInstances\\debug\\assets --assetIndex ${packagejson["assets"]} --uuid 122334dsgfds --accessToken $accessToken';
    Map args = await getArgs(packagejson, "windows");
    print(args);
    // var tempFile = File(
    //     "${(await path_provider.getTemporaryDirectory()).path}\\pixie\\temp_command.ps1");
    // await tempFile.create(recursive: true);
    // await tempFile.writeAsString(launchcommand);

    // var result = await Process.start(
    //     "powershell", ["-ExecutionPolicy", "Bypass", "-File", tempFile.path],
    //     runInShell: true);

    // stdout.addStream(result.stdout);
    // stderr.addStream(result.stderr);
  }

  Future<Map> getArgs(Map packagejson, String os) async {
    Map vanillaArgs = packagejson["arguments"];
    String jvmArgs = "";
    String gameArgs = "";
    for (var i = 0; i < vanillaArgs["jvm"].length; i++) {
      print(vanillaArgs["jvm"][i]);
      if (vanillaArgs["jvm"][i] is String) {
        jvmArgs += "${vanillaArgs["jvm"][i]} ";
      } else {
        if (chechAllowed(
              (vanillaArgs["jvm"][i]["rules"]),
              "windows",
              "x64",
            ) ==
            false) {
          if (vanillaArgs["jvm"][i]["value"] is List) {
            for (var j = 0; j < vanillaArgs["jvm"][i]["value"].length; j++) {
              jvmArgs += "${vanillaArgs["jvm"][i]["value"][i]} ";
            }
          } else {
            jvmArgs += "${vanillaArgs["jvm"][i]["value"]} ";
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
            ) ==
            false) {
          gameArgs += "${vanillaArgs["game"][i]["value"]} ";
        }
      }
    }
    String natives_directory =
        "C:\\Users\\zepat\\Documents\\PixieLauncherInstances\\debug\\bin\\${packagejson["id"]}";
    String launcher_name = "Mc-pixie";
    String launcher_version = "4";
    String auth_player_name = "Fridolin";
    String version_name = packagejson["id"];
    String game_directory = await getworkpath();
    String assets_root = "${await getworkpath()}\\assets";
    String assets_index_name = packagejson["assets"];
   

    jvmArgs = jvmArgs
        .replaceAll("\${natives_directory}", natives_directory)
        .replaceAll("\${launcher_name}", launcher_name)
        .replaceAll("\${launcher_version}", launcher_version)
        .replaceAll("\${classpath}", '"${await getCP(packagejson, os)}"')
        .replaceAll(
            "\${auth_player_name}", '"${await getCP(packagejson, os)}"');

    gameArgs = gameArgs
        .replaceAll("\${auth_player_name}", auth_player_name)
        .replaceAll("\${version_name}", version_name)
        .replaceAll("\${game_directory}", game_directory)
        .replaceAll("\${assets_root}", assets_root)
        .replaceAll("\${assets_index_name}", assets_index_name);

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
            "$path/${libary["downloads"]["classifiers"][libary["natives"][os]]["path"]}${(os == "windows") ? ";" : ":"}";
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
      return true; //Not a really good solution but it will do it
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
