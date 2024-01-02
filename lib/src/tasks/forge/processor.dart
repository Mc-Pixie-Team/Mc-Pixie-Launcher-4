import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:mclauncher4/src/tasks/java/java.dart';
import 'package:mclauncher4/src/tasks/models/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/utils/downloads_utils.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:path/path.dart' as path;
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:yaml/yaml.dart';

class Processor with ChangeNotifier {
  double _progress = 0.0;
  double get progress => _progress;

  Future<String> _checkkeys(List args, Map data, Version version, ModloaderVersion modloaderVersion) async {
    String outputArgs = "";

    for (var i = 0; i < args.length; i++) {
      String arg = args[i];
      if (Utils.isSurrounded(arg, "[", "]")) {
        //als erstes checken wir ob das argument (die argumente werden von dem Forloop einzeln'd abgearbeitet) von [] um klammert wird,
        // wenn das der fall ist dann wird die datei gedownloaded in den ordner den wir aus dem Mavenparser herausbekommen.
        // Der Datei pfad wird nun an den outputArgs heran gehängt

        String path = Utils.parseMaven(arg);
        DownloadUtils()
            .downloadSingeFile("https://maven.minecraftforge.net/$path", "${await getlibarypath()}\\libraries\\$path");
        outputArgs += "${await getlibarypath()}\\libraries\\$path ";
      } else if (Utils.isSurrounded(arg, "{", "}")) {
        //hier checken wir ob das argument mit {} umklammert ist, wenn ja, dann entfernen wir diese. Wir suchen nun in der "DATA" (gucke in der install_profile.json nach) nach dem passenden schlüssel der gleich bennant ist
        //wie der grade, neu erstellte String. Wenn wir einen passenden KEY gefunden haben gucken wir auch dort um welche Art es sich hierbei andelt. Wenn es mit [] umgeben ist übernimmt der mavenparser
        //TODO: extrahier methode hinzufügen bzw. /data/client.lzma nd direkt den arg zum outputarg hinzufügen wenn keiner der punkte zu trifft.

        arg = arg.split("{").join("").split("}").join("");
        List data_keys = data.keys.toList();
        if (arg == "MINECRAFT_JAR") {
          outputArgs += await getworkpath() + "\\versions\\$version\\$version.jar ";
        } else if (arg == "SIDE") {
          outputArgs += "client ";
        } else if (arg == "MINECRAFT_VERSION") {
          outputArgs += "$version ";
        } else if (arg == "ROOT") {
          outputArgs += await getworkpath() + " ";
        } else if (arg == "INSTALLER") {
          outputArgs += await getTempForgePath() +
              "\\${version.toString()}\\${modloaderVersion.toString()}\\${version.toString()}-${modloaderVersion.toString()}-installer.jar ";
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
                    "${await getlibarypath()}\\libraries\\${Utils.parseMaven(argoutput)} ".replaceAll("/", "\\");
                //  print("found []");
                break;
              } else if (Utils.isSurrounded(argoutput, "'", "'")) {
                outputArgs += "$argoutput ";
                //ich denke das diese hashes die hierbei raus kommen nur zur überprüfung dienen (SHA) //TODO: überprüfung des Outputs der anderen jars
                //  print("found ''");
                break;
              } else if (argoutput.startsWith("/")) {
                //this part is mostly called Patching
                outputArgs +=
                    "${await getTempForgePath()}\\${version.toString()}\\${modloaderVersion.toString()}\\$argoutput "
                        .replaceAll("/", "\\");

                // print("found /");
                break;
              } else {
                continue;
              }
            } else {
              //  print('nothing found in data keys');
            }
          }
        }
      } else {
        outputArgs += "$arg ";
      }
    }
    return outputArgs;
  }

  run(Map install_profile, Version version, ModloaderVersion modloaderVersion) async {
    if (install_profile["processors"] == null || install_profile["processors"].length == 0) return;
    //NOTE:
    // alternative individuelle keys
    List processor = install_profile["processors"];

    for (var i = 0; i < processor.length;) {
      Map current = processor[i];

      if (_checkAllowed(current)) {
        i++;
        continue;
      }

      print("================================================================================> new processor:" +
          current["jar"]);
      String stack = await _getStack(current["classpath"], install_profile["libraries"], current["jar"]);
      String processor_jar = await searchforjar(current["jar"], install_profile["libraries"]);
      stack += processor_jar;

      //Getting the mainclass
      List<int> byte_MANIFEST = await Utils.extractFilefromjar(
          processor_jar, "META-INF/MANIFEST.MF"); //TODO: check if succsesfull (error handling)

      String mainClass = loadYaml(utf8.decode(byte_MANIFEST))[
          "Main-Class"]; //TODO: erro handlung einbauen falls loadYAML oder utf8decoder fehlschlägt.

      String _args = await _checkkeys(current["args"], install_profile["data"], version, modloaderVersion);

      final javaPath = Java.getJavaJdk(version);

      String command = '$javaPath -cp "${stack.replaceAll('/', "\\")}" $mainClass $_args';

      var tempFile = File("${await getTempCommandPath()}temp_command_2.ps1");
      await tempFile.create(recursive: true);
      await tempFile.writeAsString(command);

      var result =
          await Process.start("powershell", ["-ExecutionPolicy", "Bypass", "-File", tempFile.path], runInShell: true);
      String filepath = await getworkpath() + '\\logs\\${i.toString()}\\log.txt';
      String parentDirectory = path.dirname(filepath);
      await Directory(parentDirectory).create(recursive: true);

      String log = "";

      result.stdout.listen((i) => {log += String.fromCharCodes(i) + '\n'});
      result.stderr.listen(onHandleStdout);

      await result.exitCode;
      await File(filepath).writeAsString(log);
      i++;
      _progress = (i / processor.length) * 100;
      notifyListeners();
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
}
