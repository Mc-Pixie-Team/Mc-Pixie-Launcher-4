import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
class InstallUtils {


static bool parseRuleList(List<dynamic> rules, {List<String>? options }) {
  // Rule parsing logic 

  for (var i in rules) {
    if(!parseRule(i as Map, options: options)){
      return false;
    } 
  }

  return true;
}

//MARK: Feature Parser

static bool parseFeatures(List<String> options, Map rule) {
  bool isvalid = true;

  (rule["features"] as Map).forEach((feature, enabled) { 
        if(options.length == 0) {
          isvalid = false;
          return;
        }
        options.forEach((element) { 
          if (element == feature) {
            if (!enabled) {
              isvalid = false;
              return;
            }
          }else {
            if(enabled) {
              isvalid = false;
              return;
            }
          }
        });
        if(!isvalid) {
          return;
        }
      
     });

  return isvalid;
}

//MARK: Rule Parser
static bool parseRule(Map rule, {List<String>? options }) {
    bool returnValue = rule["action"] == "disallow" ? false : true;

  if(options != null && rule["features"] != null) {
   if(!parseFeatures(options, rule)){
    return !returnValue;
   };
  }


  if (rule["os"] != null) {

    for (var osKey in (rule["os"] as Map).keys) {
      var osValue = rule["os"][osKey];
      if (osKey == "name") {
        if (osValue == "windows" && Platform.isWindows) {
          print("returning true for windows!");
          return returnValue;
        } else if (osValue == "osx" && Platform.isMacOS) {
          return returnValue;
        } else if (osValue == "linux" && Platform.isLinux) {
          return returnValue;
        }
      } else if (osKey == "arch") {
        if (osValue == "x86" && Platform.environment['PROCESSOR_ARCHITECTURE'] == "x86") {
          return returnValue;
        }
      } else if (osKey == "version") {
        if (RegExp(osValue).hasMatch(Platform.operatingSystemVersion)) {
          return returnValue;
        }
      }
    }
  }else {
    return returnValue;
  }

  return !returnValue;
}

  static bool isSurrounded(String str, String prefix, String suffix) {
    return str.startsWith(prefix) && str.endsWith(suffix);
  }

  static convertLibraries(List libraries) {
    List newlibraries = [];
    for (int i = 0; i < libraries.length; i++) {
      Map current = libraries[i];

      newlibraries.add({
        "name": current["name"],
        "downloads": {
          "artifact": {
            "path": parseMaven(current["name"]),
            "url": p.join(current["url"] ?? "https://libraries.minecraft.net", parseMaven(current["name"])),
          }
        }
      });
    }

    return newlibraries;
  }

  static List parseMavenList(String mavenString) {
    if (isSurrounded(mavenString, "[", "]")) {
      mavenString = mavenString.split("[").join("").split("]").join("");
    }

    String packageGroup = mavenString.split(":")[0].replaceAll(".", "/");
    String packageName = mavenString.split(":")[1];

    String packageVersion = mavenString.split(":")[2].split("@")[0];
    String packageVersion2;
    
    if (mavenString.split(":").length > 3) {
      packageVersion2 = '${mavenString.split(":")[2].split("@")[0]}-${mavenString.split(":")[3].split("@")[0]}';
    } else {
      packageVersion2 = packageVersion;
    }

    String packageExtension;

    if (mavenString.split("@").length < 2) {
      packageExtension = "jar";
    } else {
      packageExtension = mavenString.split("@")[1];
    }

    return ["$packageGroup/$packageName/$packageVersion", "$packageName-$packageVersion2.$packageExtension"];
  }

  static String parseMaven(String mavenString) {
    List mavenlist = parseMavenList(mavenString);

    return mavenlist[0] + "/" + mavenlist[1];
  }


    static Future<List<int>> extractFilefromjar(String filepath, String filepathinjar) async {
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
}