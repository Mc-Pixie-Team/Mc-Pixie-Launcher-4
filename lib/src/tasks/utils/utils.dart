import 'dart:io';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive_io.dart';
import 'package:mclauncher4/src/tasks/models/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/models/version_object.dart';
import './path.dart';

class Utils {
  static extractNativesfromjar(String pathfrom, String version) async {
    List<int> _bytes = [];

    _bytes = await File("${await getlibarypath()}\\libraries\\$pathfrom")
        .readAsBytes();
    final archive = ZipDecoder().decodeBytes(_bytes);
    for (var data in archive) {
      final filename = data.name;
      if (data.isFile) {
        final datadir = data.content as List<int>;
        File(await getbinpath() + "\\$version\\" + filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(datadir);
      } else {
        Directory(await getbinpath() + "\\$version\\" + filename)
            .create(recursive: true);
      }
    }
  }

  static extractZip(
    List<int> _bytes,
    String filePath,
  ) {
    final archive = ZipDecoder().decodeBytes(_bytes);

    for (var data in archive) {
      final filename = data.name;
      if (data.isFile) {
        final datadir = data.content as List<int>;
        File(filePath + '\\' + filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(datadir);
      } else {
        Directory(filePath + '\\' + filename).create(recursive: true);
      }
    }
  }

  static Future copyDirectory(Directory source, Directory destination) async {
    /// create destination folder if not exist
    if (!destination.existsSync()) {
      await destination.create(recursive: true);
    }
    

    /// get all files from source (recursive: false is important here)
   await for (var entity in  source.list(recursive: false)){
      final newPath = destination.path +
          Platform.pathSeparator +
          path.basename(entity.path);
      if (entity is File) {
        await entity.copy(newPath);
      } else if (entity is Directory) {
        await copyDirectory(entity, Directory(newPath));
      }
    }
  }

  static extractForgeInstaller(
      List<int> _bytes, Version version, ModloaderVersion modloaderVersion,
      [String? additional]) async {
    String filepath = await getTempForgePath() +
        "\\${version.toString()}\\${modloaderVersion.toString()}\\${version.toString()}-${modloaderVersion.toString()}${additional == null ? "" : "-" + additional}-installer.jar";

    String parentDirectory = path.dirname(filepath);
    await Directory(parentDirectory).create(recursive: true);
    File(filepath).writeAsBytes(_bytes);

    final archive = ZipDecoder().decodeBytes(_bytes);
    for (var data in archive) {
      final filename = data.name;
      if (data.isFile) {
        final datadir = data.content as List<int>;
        File(await getTempForgePath() +
            "\\${version.toString()}\\${modloaderVersion.toString()}\\" +
            filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(datadir);
      } else {
        Directory(await getTempForgePath() +
                "\\${version.toString()}\\${modloaderVersion.toString()}\\" +
                filename)
            .create(recursive: true);
      }
    }
  }

  static Future<List<int>> extractFilefromjar(
      String filepath, String filepathinjar) async {
    List<int> _bytes = [];

    _bytes = await File(filepath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(_bytes);
    for (var data in archive) {
      final filename = data.name;
      if (data.isFile) {
        final datadir = data.content as List<int>;
        if (filename == filepathinjar) {
          return datadir;
        }
      }
    }
    throw Exception('unable to find file in jar:' + filepathinjar);
  }

  static bool isSurrounded(String str, String prefix, String suffix) {
    return str.startsWith(prefix) && str.endsWith(suffix);
  }

  static convertLibraries(Map versionJson, List<String> ignoreList,
      [additionallib]) {
    List libraries = versionJson["libraries"];
    List newlibraries = [];
    if (additionallib != null) {
      newlibraries.addAll(additionallib);
    }

    for (int i = 0; i < libraries.length; i++) {
      Map current = libraries[i];
      if (!(current["clientreq"] == null && current["serverreq"] == null)) {}

      // if (current["url"] == null || current["url"] == "") continue;
      if (ignoreList.contains(current["name"])) continue;
      if (current["url"] == null || current["url"] == "") {
        newlibraries.add({
          "name": current["name"],
          "downloads": {
            "artifact": {
              "path": Utils.parseMaven(current["name"]),
              "url": "https://repo1.maven.org/maven2/" +
                  Utils.parseMaven(current["name"]),
              "size": 100000
            }
          }
        });
        continue;
      }

      newlibraries.add({
        "name": current["name"],
        "downloads": {
          "artifact": {
            "path": Utils.parseMaven(current["name"]),
            "url": current["url"] + Utils.parseMaven(current["name"]),
            "size": 100000
          }
        }
      });
    }

    versionJson["libraries"] = newlibraries;
    return versionJson;
  }

  static List parseMavenList(String mavenString) {
    //Maven Parse

    if (isSurrounded(mavenString, "[", "]")) {
      mavenString = mavenString.split("[").join("").split("]").join("");
    }

    String packageGroup = mavenString.split(":")[0].replaceAll(".", "/");

    String packageName = mavenString.split(":")[1];

    String packageVersion = mavenString.split(":")[2].split("@")[0];
    String packageVersion2;
    if (mavenString.split(":").length > 3) {
      packageVersion2 =
          '${mavenString.split(":")[2].split("@")[0]}-${mavenString.split(":")[3].split("@")[0]}';
    } else {
      packageVersion2 = packageVersion;
    }

    String packageExtension;

    if (mavenString.split("@").length < 2) {
      packageExtension = "jar";
    } else {
      packageExtension = mavenString.split("@")[1];
    }

    return [
      "$packageGroup/$packageName/$packageVersion",
      "$packageName-$packageVersion2.$packageExtension"
    ];
  }

  static String parseMaven(String mavenString) {
    List mavenlist = parseMavenList(mavenString);

    return mavenlist[0] + "/" + mavenlist[1];
  }
}
