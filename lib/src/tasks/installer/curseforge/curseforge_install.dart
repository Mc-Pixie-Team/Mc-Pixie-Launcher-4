

import 'dart:convert';
import 'dart:io';

import 'package:mclauncher4/src/tasks/fabric/fabric.dart';
import 'package:mclauncher4/src/tasks/forge/forge.dart';
import 'package:mclauncher4/src/tasks/installer/modrinth/modrinth_install.dart';
import 'package:mclauncher4/src/tasks/minecraft/minecraft_install.dart';
import 'package:mclauncher4/src/tasks/models/download_states.dart';
import 'package:mclauncher4/src/tasks/models/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:mclauncher4/src/tasks/modloaders.dart';
import 'package:mclauncher4/src/tasks/utils/downloader.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';

import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:path/path.dart' as path;

class CurseforgeInstaller {




  double _progress = 0.0;
  MainState _state = MainState.downloadingML;

  MainState get installState => _state;
  double get progress => _progress;

  Map<String, String> userHeader = {
    "Content-type": "application/json",
    "Accept": "application/json",
    "x-api-key":
        "\$2a\$10\$zApu4/n/e1nylJMTZMv5deblPpAWUHXc226sEIP1vxCjlYQoQG3QW",
  };

  final baseUrl = "https://api.curseforge.com";


 Future install({required Map modpackData, required String instanceName, Version? localversion}) async {

      print(path.join(getInstancePath(), instanceName));
      print(modpackData);

      if(modpackData["modId"] == null) {
        modpackData = modpackData["latestFiles"][0];
      }

      Downloader _downloader = Downloader(modpackData["downloadUrl"], path.join(getTempCommandPath(), instanceName, "modpack-$instanceName.zip"));

      _state = MainState.downloadingMods;

      await _downloader.startDownload(onProgress: (p0) {
          _progress = p0;
      });
     _downloader.unzip(deleteOld: true);
      _progress = 0.0;

    Map manifest = jsonDecode(File(path.join(getTempCommandPath(), instanceName, "manifest.json")).readAsStringSync());

  await Utils.copyDirectory(source: Directory(path.join(getTempCommandPath(), instanceName, manifest["overrides"])), destination: Directory(path.join(getInstancePath(), instanceName)));

   await File(path.join( getInstancePath(), instanceName, "curseforge.manifest.json" )).writeAsString(jsonEncode(manifest));


  final downloads_at_same_time  = 10;
  int _totalitems = (manifest["files"] as List).length;

  for (var i = 0; (manifest["files"] as List).length > i; ){

      Iterable<Future<dynamic>> downloads = Iterable.generate(
          downloads_at_same_time > _totalitems ? _totalitems : downloads_at_same_time,
          (index) async {
            Map current = manifest["files"][i + index];
            print(current);
        
              final res = await http.get(
        Uri.parse('$baseUrl/v1/mods/${current["projectID"]}/files/${current["fileID"]}'),
        headers: userHeader);
        Map hit = await jsonDecode(utf8.decode(res.bodyBytes))["data"];

        String? url;
        String? filename = hit["fileName"];
        if(hit["downloadUrl"] == null || hit["downloadUrl"] == "") {
        url = 'https://www.curseforge.com/api/v1/mods/${current["projectID"]}/files/${current["fileID"]}/download';
    
        }else {

            url = hit["downloadUrl"];
        }
       
          
        if (url == null) throw "Cannot find any download url";
        print("using url: " + url + " with: " + filename.toString());
        
          Downloader _downloader = Downloader(url, path.join(getInstancePath(), instanceName,"mods",filename));

         await _downloader.startDownload();

       
          
          });

          await Future.wait(downloads);
          
  _totalitems -= downloads_at_same_time;
          i += downloads_at_same_time; 
            _progress = (i / ((manifest["files"] as List).length)) * 100;
  }

    Minecraft minecraft = Minecraft();

    Version mcVersion = Version.parse(manifest["minecraft"]["version"]);

    String modloaderId = manifest["minecraft"]["modLoaders"][0]["id"];

    ModloaderVersion mlVersion = ModloaderVersion.parse( modloaderId.split("-").last);

    Modloader modloader;

    switch(modloaderId.split("-").first) {
      case "forge":
        modloader = Forge();
        break;
      case "fabric":
        modloader = Fabric();
        break;
      default:
        throw "modloader not Supported!";
    }

      String mfilePath = path.join(getworkpath(), "versions", mcVersion.toString(), "$mcVersion.json");

    modloader.addListener(() {
      _progress = modloader.mainprogress;
    });

    minecraft.addListener(() {
      _progress = minecraft.mainprogress;
    });
    

    ///check if minecraft is installed
    if (_checkForInstall( mfilePath)) {
      _state = MainState.downloadingMinecraft;
      //install minecraft
      print('need to install minecraft: $mcVersion');
      print(mfilePath);
      await minecraft.install(mcVersion);
    }

    //check with dynamic [Modloader] if installed
    if (_checkForInstall(await modloader.getSafeDir(mcVersion, mlVersion))) {
      _state = MainState.downloadingML;
      print('need to install : $mcVersion-$mlVersion');
      await modloader.install(mcVersion, mlVersion);
    }

    


    // TODO: implement install
   // throw UnimplementedError();
  }

  bool _checkForInstall(String path) {
    return (!(File(path).existsSync()));
  }


  Future<Process> start(String processId)  async{
    String destination =
       path.join(getInstancePath(), processId, "curseforge.manifest.json" );
    Map manifest =
        (jsonDecode(await File(destination).readAsString()));
   


    Version mcVersion = Version.parse(manifest["minecraft"]["version"]);

    String modloaderId = manifest["minecraft"]["modLoaders"][0]["id"];

    ModloaderVersion mlVersion = ModloaderVersion.parse( modloaderId.split("-").last);

    Modloader? modloader;

    switch(modloaderId.split("-").first) {
      case "forge":
        modloader = Forge();
        break;
      case "fabric":
        modloader = Fabric();
        break;
      default:
        throw "modloader not Supported!";
    }

      return  await modloader.run(processId, mcVersion, mlVersion);
  }




}