import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:mclauncher4/src/tasks/installs/minecraft/minecraft_install.dart';
import 'package:mclauncher4/src/tasks/installs/install_model.dart';
import 'package:mclauncher4/src/tasks/installs/install_tools.dart';
import 'package:mclauncher4/src/tasks/installs/install_utils.dart';
import 'package:mclauncher4/src/tasks/installs/minecraft/minecraft_command.dart';
import 'package:mclauncher4/src/tasks/installs/java/rutime.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:path/path.dart' as p;

class FabricInstall {
  static String getVersionJsonPath(String path, String version, String minecraftVersion ) => p.join(path, "versions","fabric-loader-$version-$minecraftVersion", "fabric-loader-$version-$minecraftVersion.json");

//MARK: INSTALL

  static Future install(String version, String minecraftVersion, String path, InstallModel installModel) async{
    if(File(getVersionJsonPath(path, version, minecraftVersion)).existsSync()) return;
  	installModel.setInstallState(InstallState.installing);
    installModel.setState("Installing Fabric");
    final res = await http.get(Uri.parse('https://meta.fabricmc.net/v2/versions/loader/$minecraftVersion/$version/profile/json'),);
    Map versiondata = jsonDecode(utf8.decode(res.bodyBytes));

     if(File(p.join(path, "versions",versiondata["id"], "${versiondata["id"]}.json")).existsSync()) return;

       if(Version.parse(minecraftVersion) < Version(1, 14)){
      throw "Sorry Minecraft Version not supported for Fabric installation";
    }

    if (!File(p.join(
            path, "versions", "$minecraftVersion", "$minecraftVersion.json"))
        .existsSync()) {
      print("need to install Minecraft version: $minecraftVersion");
      await MinecraftInstall.install(Version.parse(minecraftVersion), path, installModel);
      installModel.setState("Installing Fabric");
    }

    var libraries = InstallUtils.convertLibraries(versiondata["libraries"]);
    versiondata["libraries"] = libraries;

    await Installs.installLibraries(libraries, path, p.join(path, "bin", "fabricbins"), installModel);


    String parentDirectory = p.dirname(getVersionJsonPath(path, version, minecraftVersion));
    await Directory(parentDirectory).create(recursive: true);
    await File(getVersionJsonPath(path, version, minecraftVersion)).writeAsString(jsonEncode(versiondata));
  }

//MARK: RUN

  static Future<Process> run(String version, String minecraftVersion, String path, String processId, InstallModel installModel) async{

    if(!File(getVersionJsonPath(path, version, minecraftVersion)).existsSync()) {
      print("need to install Fabric first!");
     await install(version, minecraftVersion, path, installModel);
    }
    installModel.setInstallState(InstallState.fetching);
     installModel.setState("Fetching");

      Map versionDataForge = jsonDecode(
        await File(getVersionJsonPath(path, version, minecraftVersion))
            .readAsString());

    Map versionData = jsonDecode(
        await File(p.join(path, "versions", minecraftVersion, "$minecraftVersion.json"))
            .readAsString());

    List libraries = [];

    libraries.addAll(versionDataForge["libraries"]);
    libraries.addAll(versionData["libraries"]);

    versionData["libraries"] = libraries;
    versionData["mainClass"] = versionDataForge["mainClass"];

    if (versionDataForge["arguments"]?["jvm"] != null) {
      (versionData["arguments"]["jvm"] as List)
          .addAll(versionDataForge["arguments"]["jvm"]);
    }
    if (versionDataForge["arguments"]?["game"] != null) {
      (versionData["arguments"]["game"] as List)
          .addAll(versionDataForge["arguments"]["game"]);
    }

    var launchcommand =
        await MinecraftCommand.getlaunchCommand(versionData, path, processId);

        print(launchcommand);
    var result = await Process.start(
        Runtime.getExecutablePath(
            versionData["javaVersion"]["component"], path) ??
        "java",
        launchcommand, workingDirectory: p.join( getInstancePath(), processId));

    installModel.setInstallState(InstallState.running);
    installModel.setState("Running");

   return result;
  }

}