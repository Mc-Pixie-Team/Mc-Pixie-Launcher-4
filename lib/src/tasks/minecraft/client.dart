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
    List libraries = packagejson["libraries"];
    String os = "windows";
    String accessToken = "3423423jdisgjsdf";
    String username = "Fridolin";
    String stack =
        "${await getworkpath()}\\versions\\${packagejson["id"]}\\${packagejson["id"]}.jar${(os == "windows") ? ";" : ":"}";

    for (var i = 0; i < libraries.length; i++) {
      Map libary = libraries[i];
      if (libary["rules"] == null) {
      } else if (chechAllowed(libary["rules"], os, "x64", libary["name"]) ==
          false) {
        continue;
      }
      if (libary["natives"] != null && libary["natives"][os] != null) {
        print("adding native");
        stack +=
            "$path/${libary["downloads"]["classifiers"][libary["natives"][os]]["path"]}${(os == "windows") ? ";" : ":"}";
      }
      if (libary["downloads"]["artifact"] == null) continue;
      stack +=
          "$path/${libary["downloads"]["artifact"]["path"]}${(os == "windows") ? ";" : ":"}";
    }
    //C:\\Users\\zepat\\Documents\\PixieLauncherInstances\\debug\\bin
    // print(stack);
    // C:\\Program Files\\Java\\jdk-17\\bin\\java.exe"
    List<String> valuesString = (packagejson["id"] as String).split('.');
    Version version = new Version(int.parse(valuesString[0]),
        int.parse(valuesString[1]), int.parse(valuesString[2]));
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

  bool chechAllowed(List rules, String osName, String osArch, String name) {
    if (rules.isEmpty) {
      return true;
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
