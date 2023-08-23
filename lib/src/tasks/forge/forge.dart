import 'dart:convert';
import 'dart:io';
import "package:path_provider/path_provider.dart" as path_provider;
import 'package:mclauncher4/src/tasks/forgeversion.dart';
import 'package:mclauncher4/src/tasks/minecraft/client.dart';
import 'package:mclauncher4/src/tasks/utils/downloads.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:mclauncher4/src/tasks/version.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;
import '../utils/path.dart';

class Forge {
  //1.19.4-forge-45.1.16

  //  Version version = Version(1, 12, 2);
  // ForgeVersion forgeVersion = ForgeVersion(14, 23, 5, 2860);

  //   Version version = Version(1, 18, 1);
  // ForgeVersion forgeVersion = ForgeVersion(39, 1, 2);

  String os = "windows";
  run() async {
    Version version = Version(1, 7, 10);
    ForgeVersion forgeVersion = ForgeVersion(10, 13, 4, 1614);

    Map vanillaVersionJson = (jsonDecode(
        await File("${await getworkpath()}\\versions\\$version\\$version.json")
            .readAsString()));

    Map versionJson = (jsonDecode(await File(
            "${await getworkpath()}\\versions\\$version-forge-$forgeVersion\\$version-forge-$forgeVersion.json")
        .readAsString()));

    (vanillaVersionJson["libraries"] as List).addAll(versionJson["libraries"]);
    vanillaVersionJson["mainClass"] = versionJson["mainClass"];
    if (version < Version(1, 13, 0)) {
      vanillaVersionJson["minecraftArguments"] =
          (versionJson["minecraftArguments"]);
    } else {
      (vanillaVersionJson["arguments"]["jvm"] as List)
          .addAll(versionJson["arguments"]["jvm"]);
      (vanillaVersionJson["arguments"]["game"] as List)
          .addAll(versionJson["arguments"]["game"]);
    }

    String launchcommand = await Minecraft()
        .getlaunchCommand(vanillaVersionJson, os, version, forgeVersion);

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

  install() async {
    Version version = Version(1, 7, 10);
    ForgeVersion forgeVersion = ForgeVersion(10, 13, 4, 1614);
    String? additional = "1.7.10";
    Map versionJson =  Map();

    print("installing now: $version-$forgeVersion");
    //example: https://maven.minecraftforge.net/net/minecraftforge/forge/1.19.4-45.1.16/forge-1.19.4-45.1.16-installer.jar
     await Download().downloadForgeClient(version, forgeVersion, additional);

   Map install_profileJson = jsonDecode(await File(
            "${await getTempForgePath()}\\${version.toString()}\\${forgeVersion.toString()}\\install_profile.json")
        .readAsString());

  String versionJsonPath = "${await getTempForgePath()}\\${version.toString()}\\${forgeVersion.toString()}\\version.json"; 
  if(File(versionJsonPath).existsSync()){
     versionJson = jsonDecode(await File(
            "${await getTempForgePath()}\\${version.toString()}\\${forgeVersion.toString()}\\version.json")
        .readAsString());
  }else {
    versionJson = Utils.convertLibraries(install_profileJson["versionInfo"]);
  }
  
  print(versionJson);

    await Download()
        .downloadLibaries(install_profileJson, version, forgeVersion);
    await _processor(install_profileJson, version, forgeVersion);
    print('install_profile is finished');

    await Download().downloadLibaries(versionJson, version, forgeVersion);
    await _createVersionDir(versionJson, version, forgeVersion);
    print('version is finished');
  }

  _createVersionDir(
      Map versionJson, Version version, ForgeVersion forgeVersion) async {
    String filepath =
        "${await getworkpath()}\\versions\\$version-forge-$forgeVersion\\$version-forge-$forgeVersion.json";
    String parentDirectory = path.dirname(filepath);
    await Directory(parentDirectory).create(recursive: true);
    await File(filepath).writeAsString(jsonEncode(versionJson));
    print('created versionsDir');
  }

  Future<String> _checkkeys(
      List args, Map data, Version version, ForgeVersion forgeVersion) async {
    String outputArgs = "";

    for (var i = 0; i < args.length; i++) {
      String arg = args[i];
      if (Utils.isSurrounded(arg, "[", "]")) {
        //als erstes checken wir ob das argument (die argumente werden von dem Forloop einzeln'd abgearbeitet) von [] um klammert wird,
        // wenn das der fall ist dann wird die datei gedownloaded in den ordner den wir aus dem Mavenparser herausbekommen.
        // Der Datei pfad wird nun an den outputArgs heran gehängt

        print('downloading');

        String path = Utils.parseMaven(arg);
        Download().downloadSingeFile("https://maven.minecraftforge.net/$path",
            "${await getlibarypath()}\\libraries\\$path");
        outputArgs += "${await getlibarypath()}\\libraries\\$path ";
      } else if (Utils.isSurrounded(arg, "{", "}")) {
        //hier checken wir ob das argument mit {} umklammert ist, wenn ja, dann entfernen wir diese. Wir suchen nun in der "DATA" (gucke in der install_profile.json nach) nach dem passenden schlüssel der gleich bennant ist
        //wie der grade, neu erstellte String. Wenn wir einen passenden KEY gefunden haben gucken wir auch dort um welche Art es sich hierbei andelt. Wenn es mit [] umgeben ist übernimmt der mavenparser
        //TODO: extrahier methode hinzufügen bzw. /data/client.lzma nd direkt den arg zum outputarg hinzufügen wenn keiner der punkte zu trifft.

        arg = arg.split("{").join("").split("}").join("");
        List data_keys = data.keys.toList();
        if (arg == "MINECRAFT_JAR") {
          outputArgs +=
              await getworkpath() + "\\versions\\$version\\$version.jar ";
        } else if (arg == "SIDE") {
          outputArgs += "client ";
        } else if (arg == "MINECRAFT_VERSION") {
          outputArgs += "$version ";
        } else if (arg == "ROOT") {
          outputArgs += await getworkpath() + " ";
        } else if (arg == "INSTALLER") {
          outputArgs += await getTempForgePath() +
              "\\${version.toString()}\\${forgeVersion.toString()}\\${version.toString()}-${forgeVersion.toString()}-installer.jar ";
        } else if (arg == "LIBRARY_DIR") {
          outputArgs += await getlibarypath() + "\\libraries\\";
        } else {
          //checking if data has information about it
          for (var j = 0; j < data_keys.length; j++) {
            if (data_keys[j] == arg) {
              String argoutput = "${data[arg]["client"]}";

              if (Utils.isSurrounded(argoutput, "[", "]")) {
                //TODO: manche outputs von DATA haben keine Endung z.B "[net.minecraft:client:1.19.4-20230314.122934:unpacked]",
                // deswegen weiß der Mavenparser nicht damit umzugehen FIXEN und herausfindet was mit denen zu tun ist.
                //TODO: Mavenparser fixen, andere individuelle, nicht im DATA verhandene KEY hinzufügen (checken). gucken was passiert wenn mit '' umgeben (oftmals ein hash drinn) und direkt den arg zum outputarg hinzufügen
                //wenn keiner der punkte zu trifft.

                outputArgs +=
                    "${await getlibarypath()}\\libraries\\${Utils.parseMaven(argoutput)} "
                        .replaceAll("/", "\\");
                print("found []");
                break;
              } else if (Utils.isSurrounded(argoutput, "'", "'")) {
                outputArgs += "$argoutput ";
                //ich denke das diese hashes die hierbei raus kommen nur zur überprüfung dienen (SHA) //TODO: überprüfung des Outputs der anderen jars
                print("found ''");
                break;
              } else if (argoutput.startsWith("/")) {
                //this part is mostly called Patching
                outputArgs +=
                    "${await getTempForgePath()}\\${version.toString()}\\${forgeVersion.toString()}\\$argoutput "
                        .replaceAll("/", "\\");

                print("found /");
                break;
              } else {
                continue;
              }
            } else {
              print('nothing found in data keys');
            }
          }
        }
      } else {
        outputArgs += "$arg ";
      }
    }
    return outputArgs;
  }

  _processor(
      Map install_profile, Version version, ForgeVersion forgeVersion) async {

        if(install_profile["processors"] == null || install_profile["processors"] == []) return;
    //NOTE:
    // alternative individuelle heys

    String javaVer17 = "C:\\Program Files\\Java\\jdk-17\\bin\\java.exe";

    String javaVer8 =
        "C:\\Users\\zepat\\Documents\\PixieLauncherInstances\\install debug\\runtime\\jre-legacy\\windows-x64\\jre-legacy\\bin\\java.exe";
    List processor = install_profile["processors"];

    for (var i = 0; i < processor.length; i++) {
      Map current = processor[i];

      if (_checkAllowed(current)) continue;

      print(
          "================================================================================> new processor:" +
              current["jar"]);
      String stack = await _getStack(
          current["classpath"], install_profile["libraries"], current["jar"]);
      String processor_jar =
          await searchforjar(current["jar"], install_profile["libraries"]);
      stack += processor_jar;

      //Getting the mainclass
      List<int> byte_MANIFEST = await Utils.extractFilefromjar(processor_jar,
          "META-INF/MANIFEST.MF"); //TODO: check if succsesfull (error handling)

      String mainClass = loadYaml(utf8.decode(byte_MANIFEST))[
          "Main-Class"]; //TODO: erro handlung einbauen falls loadYAML oder utf8decoder fehlschlägt.

      String _args = await _checkkeys(
          current["args"], install_profile["data"], version, forgeVersion);

      String command =
          'java -cp "${stack.replaceAll('/', "\\")}" $mainClass $_args';

      var tempFile = File("${await getTempCommandPath()}temp_command_2.ps1");
      await tempFile.create(recursive: true);
      await tempFile.writeAsString(command);

      var result = await Process.start(
          "powershell", ["-ExecutionPolicy", "Bypass", "-File", tempFile.path],
          runInShell: true);
      String filepath = await getworkpath() + '\\${i.toString()}\\log.txt';
      String parentDirectory = path.dirname(filepath);
      await Directory(parentDirectory).create(recursive: true);

      String log = "";

      result.stdout.listen((i) => {log += String.fromCharCodes(i) + '\n'});
      result.stderr.listen(onHandleStdout);

      await result.exitCode;
      await File(filepath).writeAsString(log);
    }
  }
}

onHandleStdout(Iterable<int> out) {
  print(String.fromCharCodes(out));
}

Future<String> _getStack(List classes, List libraries, String jarname) async {
  String stack = "";
  for (int i = 0; i < classes.length; i++) {
    stack += "${await searchforjar(classes[i], libraries)};";
  }
  return stack;
}

Future<String> searchforjar(String name, List libraries) async {
  for (var i = 0; i < libraries.length; i++) {
    Map currentLib = libraries[i];
    if (currentLib["name"] != name) continue;
    return "${await getlibarypath()}\\libraries\\${currentLib["downloads"]["artifact"]["path"]}";
  }
  return "!!";
}

_checkAllowed(Map current) {
  // true is not allowed

  if (current["sides"] != null) {
    for (var i = 0; i < current["sides"].length; i++) {
      if (current["sides"][i] == "client") return false;
      return true;
    }
  }
  return false;
}
