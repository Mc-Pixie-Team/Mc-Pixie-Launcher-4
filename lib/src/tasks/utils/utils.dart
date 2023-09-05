import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:archive/archive_io.dart';
import 'package:mclauncher4/src/tasks/forgeversion.dart';
import 'package:mclauncher4/src/tasks/version.dart';
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

  static extractZip(List<int> _bytes, String filePath,) {
    final archive = ZipDecoder().decodeBytes(_bytes);

        for (var data in archive) {
      final filename = data.name;
      if (data.isFile) {
        final datadir = data.content as List<int>;
        File(filePath +'\\'+
            filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(datadir);
      } else {
        Directory(filePath +'\\'+
                filename)
            .create(recursive: true);
      }
    }
  }

  static copyDirectory(Directory source, Directory destination) async{
  /// create destination folder if not exist
  if (!destination.existsSync()) {
   await destination.create(recursive: true);
  }
  /// get all files from source (recursive: false is important here)
 await source.list(recursive: false).forEach((entity) async{
    final newPath = destination.path + Platform.pathSeparator + path.basename(entity.path);
    if (entity is File) {
     await entity.copy(newPath);
    } else if (entity is Directory) {
     await copyDirectory(entity, Directory(newPath));
    }
  });
}



  static extractForgeInstaller(
      List<int> _bytes, Version version, ForgeVersion forgeVersion, [String? additional]) async {
    String filepath = await getTempForgePath() +
        "\\${version.toString()}\\${forgeVersion.toString()}\\${version.toString()}-${forgeVersion.toString()}${additional == null ? "" : "-" + additional}-installer.jar";
       
    String parentDirectory = path.dirname(filepath);
    await Directory(parentDirectory).create(recursive: true);
    File(filepath).writeAsBytes(_bytes);

    final archive = ZipDecoder().decodeBytes(_bytes);
    for (var data in archive) {
      final filename = data.name;
      if (data.isFile) {
        final datadir = data.content as List<int>;
        File(await getTempForgePath() +
            "\\${version.toString()}\\${forgeVersion.toString()}\\" +
            filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(datadir);
      } else {
        Directory(await getTempForgePath() +
                "\\${version.toString()}\\${forgeVersion.toString()}\\" +
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

  static convertLibraries(Map versionJson) {
    List libraries = versionJson["libraries"];
    List newlibraries = [];
    List<String> ignoreList = [
      
      "net.minecraft:launchwrapper:1.12",
      "lzma:lzma:0.0.1",
      "java3d:vecmath:1.5.2"
    ];

       newlibraries.add({
          "name":"net.minecraft:launchwrapper:1.12",
          "downloads": {
            "artifact": {
              "path": "net/minecraft/launchwrapper/1.12/launchwrapper-1.12.jar",
              "url": "https://libraries.minecraft.net/net/minecraft/launchwrapper/1.12/launchwrapper-1.12.jar",
              "size" : 32999
            }
          }
      });
           newlibraries.add({
          "name":"lzma:lzma:0.0.1",
          "downloads": {
            "artifact": {
              "path": "lzma/lzma/0.0.1/lzma-0.0.1.jar",
              "url": "https://phoenixnap.dl.sourceforge.net/project/kcauldron/lzma/lzma/0.0.1/lzma-0.0.1.jar",
              "size" : 100000
            }
          }
      });
           newlibraries.add({
          "name":"java3d:vecmath:1.5.2",
          "downloads": {
            "artifact": {
              "path": "java3d/vecmath/1.5.2/vecmath-1.5.2.jar",
              "url": "https://repo1.maven.org/maven2/javax/vecmath/vecmath/1.5.2/vecmath-1.5.2.jar",
              "size" : 100000
            }
          }
      });

    for (int i = 0; i < libraries.length; i++) {
      Map current = libraries[i];
  	  if(!(current["clientreq"] == null && current["serverreq"] == null)) {
       
      
      }
      
      // if (current["url"] == null || current["url"] == "") continue;
      if(ignoreList.contains(current["name"])) continue;
      if(current["serverreq"] == true) {
          newlibraries.add({
          "name": current["name"],
          "downloads": {
            "artifact": {
              "path": Utils.parseMaven(current["name"]),
              "url": "https://repo1.maven.org/maven2/" +  Utils.parseMaven(current["name"]),
              "size" : 100000
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
              "url": current["url"] +  Utils.parseMaven(current["name"]),
              "size" : 100000
            }
          }
      });
    }


    

    versionJson["libraries"] = newlibraries;
    return versionJson;
  }

  static List parseMavenList(String mavenString) {
    /*
    原始內容: de.oceanlabs.mcp:mcp_config:1.16.5-20210115.111550@zip
    轉換後內容: https://maven.minecraftforge.net/de/oceanlabs/mcp/mcp_config/1.16.5-20210115.110354/mcp_config-1.16.5-20210115.110354.zip

    . -> / (套件包名稱)
    : -> /
    第一個 : 後面代表套件名稱，第二個 : 後面代表版本號
    @ -> . (副檔名)
    檔案名稱組合方式: 套件名稱-套件版本號/.副檔名 (例如: mcp_config-1.16.5-20210115.110354.zip)
    */

    /// 是否為方括號，例如這種格式: [de.oceanlabs.mcp:mcp_config:1.16.5-20210115.111550@zip]
    if (isSurrounded(mavenString, "[", "]")) {
      mavenString =
          mavenString.split("[").join("").split("]").join(""); //去除方括號，方便解析
    }

    /// 以下範例的原始字串為 de.oceanlabs.mcp:mcp_config:1.16.5-20210115.111550@zip 的格式
    /// 結果: de/oceanlabs/mcp
    String packageGroup = mavenString.split(":")[0].replaceAll(".", "/");

    /// 結果: mcp_config
    String packageName = mavenString.split(":")[1];

    /// 結果: 1.16.5-20210115.111550
    String packageVersion = mavenString.split(":")[2].split("@")[0];
    String packageVersion2;
    if (mavenString.split(":").length > 3) {
      packageVersion2 =
          '${mavenString.split(":")[2].split("@")[0]}-${mavenString.split(":")[3].split("@")[0]}';
    } else {
      packageVersion2 = packageVersion;
    }

    /// 結果: zip
    /// ü
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
