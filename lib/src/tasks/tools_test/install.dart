import 'dart:convert';
import 'dart:io';

import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/tools_test/install_tools.dart';
import 'package:mclauncher4/src/tasks/tools_test/minecraft_command.dart';
import 'package:mclauncher4/src/tasks/tools_test/rutime.dart';
import 'package:mclauncher4/src/tasks/utils/downloader.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';

class MinecraftInstall {


 static Future install(Version version, String path) async {


  // Download and read versions.json  
    String? url;
     var minecraftManifestRES = await http.get(Uri.parse(
        'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json'));
      
  List minecraftManifest = jsonDecode(minecraftManifestRES.body)['versions'];



  for (Map versionjson in minecraftManifest) {
    if (versionjson["id"] == "$version") url = versionjson["url"];
   }
   // Checking if correct Minecraft Version is found
   if(url == null) throw "Could not find minecraft Version: $version";

   // Download and read correct version.json
   var versionJsonRES = await http.get(Uri.parse(url));
   Map versiondata = jsonDecode(versionJsonRES.body);

  String versiondataPath = p.join(path, "versions", versiondata["id"], versiondata["id"] +".json");

  String nativesPath = p.join(path, "bin", UuidV4().generate());

  versiondata["nativesPath"] = nativesPath;

   await Installs.installLibraries(versiondata["libraries"], path, nativesPath );
  await Installs.installAssets(versiondata, path);

   if(versiondata["logging"] != null) {
     print("downloading logging xml");
     var logger_file = p.join(path, "assets", "log_configs", versiondata["logging"]["client"]["file"]["id"]);
     await Downloader(versiondata["logging"]["client"]["file"]["url"], logger_file).startDownload();
   }

   if(versiondata["downloads"] != null){
      print("Downloading Client");
     await Downloader(versiondata["downloads"]["client"]["url"], p.join(path, "versions", versiondata["id"], versiondata["id"] + ".jar")).startDownload();
   }

   if(versiondata["javaVersion"] != null) {
    Runtime.installJvmRuntime(versiondata["javaVersion"]["component"], path);
   }

  await Directory(p.dirname(versiondataPath)).create(recursive: true);
  await File(versiondataPath).writeAsString(jsonEncode(versiondata));
  }

 static Future run(Version version) async{
    String path = getlibarypath();

    if(!(File(p.join(path, "versions", "$version", "$version.json")).existsSync())) {
      print("need to install: $version");
      await install(version, path);
    }
    
    print("launching...");
    var versiondata = jsonDecode( File(p.join(path, "versions", "$version", "$version.json")).readAsStringSync());
    
   var launchcommand = await MinecraftCommand.getlaunchCommand(versiondata, path);
   print(launchcommand);
   var result = await Process.start(Runtime.getExecutablePath(versiondata["javaVersion"]["component"], path) ?? "java", launchcommand);

    result.stdout.listen((event) {
      print(utf8.decode(event));
    });
    result.stderr.listen((event) {
      print(utf8.decode(event));
    });
  }


}