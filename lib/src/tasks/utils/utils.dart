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

  static extractForgeInstaller(
      List<int> _bytes, Version version, ForgeVersion forgeVersion) async {
          String filepath = await getTempForgePath() +"\\${version.toString()}\\${forgeVersion.toString()}\\${version.toString()}-${forgeVersion.toString()}-installer.jar";
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

  static Future<List<int>> extractFilefromjar(String filepath, String filepathinjar)  async{
    List<int> _bytes = [];

    _bytes = await File(filepath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(_bytes);
 for (var data in archive) {
      final filename = data.name;
      if (data.isFile) {
        final datadir = data.content as List<int>;
        if(filename == filepathinjar) {
          return datadir;
        }
        
      } 
    }
    Exception('unable to find file in jar:' + filepathinjar);
    return [];
  }

  static bool isSurrounded(String str, String prefix, String suffix) {
    return str.startsWith(prefix) && str.endsWith(suffix);
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
    if(mavenString.split(":").length >3){
      print('adding chard');
      packageVersion2 = '${mavenString.split(":")[2].split("@")[0]}-${mavenString.split(":")[3].split("@")[0]}';
    }else {
      packageVersion2 = packageVersion;
    }

    /// 結果: zip
    /// ü
    String packageExtension;

    if(mavenString.split("@").length < 2){
      packageExtension = "jar";
    }else {
      packageExtension = mavenString.split("@")[1];
    }
     

    return [
      "$packageGroup/$packageName/$packageVersion",
      "$packageName-$packageVersion2.$packageExtension"
    ];
  }

  static String parseMaven(String mavenString) {
    print(mavenString);
    List mavenlist = parseMavenList(mavenString);
    print(mavenlist[0] + "/" +mavenlist[1]);
    return mavenlist[0] + "/" +mavenlist[1];
  }
}
