import 'dart:convert';
import 'dart:io';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class RunProcessors {
 static Future<void> runProcessors(Map<String, dynamic> data, String minecraftDirectory, String installerPath, String lzmaPath, String javaPath) async {
  String path = minecraftDirectory;

  Map<String, String> argumentVars = {
    "{MINECRAFT_JAR}": p.join(path, "versions", data["minecraft"], "${data["minecraft"]}.jar")
  };

  data["data"].forEach((dataKey, dataValue) {
    if (dataValue["client"].startsWith("[") && dataValue["client"].endsWith("]")) {
      argumentVars["{$dataKey}"] = getLibraryPath(dataValue["client"].substring(1, dataValue["client"].length - 1), path);
    } else {
      argumentVars["{$dataKey}"] = dataValue["client"];
    }
  });


    argumentVars["{INSTALLER}"] = installerPath;
    argumentVars["{BINPATCH}"] = lzmaPath;
    argumentVars["{ROOT}"] = getTempForgePath();
    argumentVars["{SIDE}"] = "client";

    String classpathSeparator = getClasspathSeparator();



    for (int count = 0; count < data["processors"].length; count++) {
      var i = data["processors"][count];

      if (!i.containsKey("sides") || i["sides"].contains("client")) {
 

        String classpath = "";
        for (var c in i["classpath"]) {
          classpath += getLibraryPath(c, path) + classpathSeparator;
        }
        classpath += getLibraryPath(i["jar"], path);

        String mainClass =  await getJarMainClass(getLibraryPath(i["jar"], path));
        List<String> command = [javaPath, "-cp", classpath, mainClass];

        for (var c in i["args"]) {
          String vari = argumentVars.containsKey(c) ? argumentVars[c]! : c;
          if (vari.startsWith("[") && vari.endsWith("]")) {
            command.add(getLibraryPath(vari.substring(1, vari.length - 1), path));
          } else {
            command.add(vari);
          }
        }

        argumentVars.forEach((argumentKey, argumentValue) {
          for (int pos = 0; pos < command.length; pos++) {
            command[pos] = command[pos].replaceAll(argumentKey, argumentValue);
          }
        });
      List<int> log = [];
      var result = await Process.start(command.first, command.sublist(1));

      result.stderr.listen((out) { 
         print(String.fromCharCodes(out));
      });
      //TODO: Implement better log system for processors of forge
      result.stdout.listen((i) {log.addAll(i);});
      var logfilePath = p.join(pixieInstances(), "logs", "processors", '$count.log');
      Directory(p.dirname(logfilePath)).createSync(recursive: true);
      File(logfilePath).writeAsBytesSync(log);

      await result.exitCode;
      print("Done with: $count/${data["processors"].length -1}");
      }
    }
  
}

static String getLibraryPath(String name, String basePath) {
  // Initial library path
  String libPath = p.join(basePath, 'libraries');

  // Split the name into parts
  List<String> parts = name.split(':');
  String baseName = parts[0];
  String libName = parts[1];
  String version = parts[2];

  // Build the path using the base name parts
  List<String> baseNameParts = baseName.split('.');
  for (String part in baseNameParts) {
    libPath = p.join(libPath, part);
  }

  // Handle the version and file extension
  String fileEnd = 'jar';
  if (version.contains('@')) {
    List<String> versionParts = version.split('@');
    version = versionParts[0];
    fileEnd = versionParts[1];
  }

  // Construct the filename with the remaining parts
  String remainingParts = parts.sublist(3).map((p) => '-$p').join('');
  String filename = '$libName-$version$remainingParts.$fileEnd';

  // Final library path
  libPath = p.join(libPath, libName, version, filename);
  return libPath;
}

static String getClasspathSeparator() {
  // Implement this function based on your requirements
  return Platform.isWindows ? ";" : ":";
}

 static Future<String> getJarMainClass(String jarPath) async{
  // Implement this function based on your requirements
      List<int> byte_MANIFEST = await Utils.extractFilefromjar(
          jarPath, "META-INF/MANIFEST.MF"); //TODO: check if succsesfull (error handling)



  String mainClass = _parseMainClass(utf8.decode(byte_MANIFEST));
  print(mainClass);
  return mainClass;
}

 static String _parseMainClass(String manifest) {
    final lines = manifest.split('\n');
    for (var line in lines) {
      if (line.startsWith('Main-Class:')) {
        return line.split(':').last.trim();
      }
    }
    throw "No MainClass found";
  }

}