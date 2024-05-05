

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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

      if(modpackData["modId"] == null) {
        modpackData = modpackData["latestFiles"][0];
      }

      print(modpackData);

    

    //Getting classIds for Curseforge
     final resClassCatergories = await http.get(
            Uri.parse('$baseUrl/v1/categories?gameId=432&classesOnly=true'),
        headers: userHeader);

    List<dynamic> classCatergories = await jsonDecode(utf8.decode(resClassCatergories.bodyBytes))["data"];

    int modClassifier = classCatergories.where((element) => element["slug"] == "mc-mods").first["id"];
    int shaderClassifier = classCatergories.where((element) => element["slug"] == "shaders").first["id"];
    int resourcePackClassifier = classCatergories.where((element) => element["slug"] == "texture-packs").first["id"];
    int worldClassifier = classCatergories.where((element) => element["slug"] == "worlds").first["id"];
    
    if(modClassifier == null || shaderClassifier == null || resourcePackClassifier == null || worldClassifier == null) {
      throw "Couldn't find Class Categories";
    }


      Downloader _downloader = Downloader(modpackData["downloadUrl"], path.join(getTempCommandPath(), instanceName, "modpack-$instanceName.zip"));

      _state = MainState.downloadingMods;

      await _downloader.startDownload(onProgress: (p0) {
          _progress = p0;
      });
      print("unzip");
      _progress = 0.0;
      _state = MainState.unzipping;

     await _downloader.unzip(deleteOld: true, onZipProgress: (p0) {
      _progress = p0;
      print(p0);
     } );

     print("unzip END");
      



    Map manifest = jsonDecode(File(path.join(getTempCommandPath(), instanceName, "manifest.json")).readAsStringSync());

  await Utils.copyDirectory(source: Directory(path.join(getTempCommandPath(), instanceName, manifest["overrides"])), destination: Directory(path.join(getInstancePath(), instanceName)));

   await File(path.join( getInstancePath(), instanceName, "curseforge.manifest.json" )).writeAsString(jsonEncode(manifest));

print("done with coping");



    _state = MainState.downloadingMods;
    _progress = 0.0;

  final downloads_at_same_time  = 10;
  int _totalitems = (manifest["files"] as List).length;

  for (var i = 0; (manifest["files"] as List).length > i; ){

      Iterable<Future<dynamic>> downloads = Iterable.generate(
          downloads_at_same_time > _totalitems ? _totalitems : downloads_at_same_time,
          (index) async {
            Map current = manifest["files"][i + index];
        
              final res = await http.get(
        Uri.parse('$baseUrl/v1/mods/${current["projectID"]}/files/${current["fileID"]}'),
        headers: userHeader);
          final res2 = await http.get(
        Uri.parse('$baseUrl/v1/mods/${current["projectID"]}'),
        headers: userHeader);

        Map hitmod = await jsonDecode(utf8.decode(res.bodyBytes))["data"];
        Map hitproj = await jsonDecode(utf8.decode(res2.bodyBytes))["data"];
        

        late String innerDownloadPath;
        String? url;
        String? filename = hitmod["fileName"];

        if(hitproj["classId"] == modClassifier) {

            innerDownloadPath = "mods";

        } else if (hitproj["classId"] == shaderClassifier) {

            innerDownloadPath = "shaderpacks";

        }else if (hitproj["classId"] == resourcePackClassifier) {

          innerDownloadPath = "resourcepacks";

        }else if (hitproj["classId"] == worldClassifier) {

          innerDownloadPath = "saves";

        } else {
          print( "could find any classifier moving on");
          return;
        }



        if(hitmod["downloadUrl"] == null || hitmod["downloadUrl"] == "") {
          print("no inner modurl found for: ${modpackData["fileID"]}");
        url = 'https://www.curseforge.com/api/v1/mods/${current["projectID"]}/files/${current["fileID"]}/download';
    
        }else {

            url = hitmod["downloadUrl"];
        }
          
        if (url == null) throw "Cannot find any download url";
        print("using url: " + url + " with: " + filename.toString());


        
          Downloader _downloader = Downloader(url, path.join(getInstancePath(), instanceName, innerDownloadPath, filename));

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