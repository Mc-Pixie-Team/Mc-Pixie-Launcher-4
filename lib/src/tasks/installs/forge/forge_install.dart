import 'dart:convert';
import 'dart:io';

import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:mclauncher4/src/tasks/installs/forge/processor_run.dart';
import 'package:mclauncher4/src/tasks/installs/minecraft/minecraft_install.dart';
import 'package:mclauncher4/src/tasks/installs/install_model.dart';
import 'package:mclauncher4/src/tasks/installs/install_tools.dart';
import 'package:mclauncher4/src/tasks/installs/install_utils.dart';
import 'package:mclauncher4/src/tasks/installs/minecraft/minecraft_command.dart';
import 'package:mclauncher4/src/tasks/installs/java/rutime.dart';
import 'package:mclauncher4/src/tasks/utils/downloader.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/v4.dart';

class ForgeInstall {

//MARK: RUN
  static Future<Process> run(String version, String path, String processId, InstallModel installModel) async {
    if (!File(p.join(path, "versions", version, "$version.json"))
        .existsSync()) {
      await install(version, path, installModel);
    }
   installModel.setInstallState(InstallState.fetching);
   installModel.setState("Fetching");

    Map versionDataForge = jsonDecode(
        await File(p.join(path, "versions", version, "$version.json"))
            .readAsString());

    var minecraft = versionDataForge["inheritsFrom"] != null
        ? versionDataForge["inheritsFrom"]
        : versionDataForge["minecraft"];

    if(minecraft == null) {
      print("need to use assets version");

      minecraft = versionDataForge["assets"];
    }

    Map versionData = jsonDecode(
        await File(p.join(path, "versions", minecraft, "$minecraft.json"))
            .readAsString());

    List libraries = [];

    libraries.addAll(versionDataForge["libraries"]);
    libraries.addAll(versionData["libraries"]);

    versionData["libraries"] = libraries;
    versionData["mainClass"] = versionDataForge["mainClass"];

    if (versionDataForge["minecraftArguments"] != null) {
      versionData["minecraftArguments"] =
          versionDataForge["minecraftArguments"];
    }

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

//MARK: INSTALL

  static Future install(String version, String path,InstallModel installModel ) async {
   // print("Installing Forge...");
   if(File(p.join(getworkpath(), "versions", "$version", "$version.json")).existsSync()) return;
   installModel.setInstallState(InstallState.installing);
   installModel.setState("Installing Forge");
    var FORGE_DOWNLOAD_URL =
        "https://maven.minecraftforge.net/net/minecraftforge/forge/${version}/forge-${version}-installer.jar";

    var downloader = Downloader(FORGE_DOWNLOAD_URL,
        p.join(getTempForgePath(), "forge-${version}-installer.jar"));

    String tempForgePath = p.join(getTempForgePath(), "forge-${version}");
    await downloader.startDownload();
    await downloader.unzip(unzipPath: tempForgePath, deleteOld: true);

    Map versiondata = jsonDecode(
        await File(p.join(tempForgePath, "install_profile.json"))
            .readAsString());

    var forgeVersionId = versiondata["version"] != null
        ? versiondata["version"]
        : versiondata["versionInfo"]["id"];
    var minecraft_version = _getMinecraftVersion(versiondata);

    if(Version.parse(minecraft_version) < Version(1, 7, 10)){
      throw "Sorry Minecraft Version not supported for Forge installation";
    }

    if (!File(p.join(
            path, "versions", "$minecraft_version", "$minecraft_version.json"))
        .existsSync()) {
      print("need to install Minecraft version: $minecraft_version");
      await MinecraftInstall.install(Version.parse(minecraft_version), path, installModel);
      installModel.setState("Installing Forge");
    }

    String nativesPath = p.join(path, "bin", UuidV4().generate());
    List? libraries = versiondata["libraries"];

    if (libraries == null) {
    //  print("need to convert libraries");
      libraries =
          InstallUtils.convertLibraries(versiondata["versionInfo"]["libraries"]);

      // Setting converted variables as new standard for later use
      versiondata["versionInfo"]["libraries"] = libraries;
   //   print(libraries);
    }

    if (versiondata["json"] != null) {
      var versionJson = jsonDecode(
          File(p.join(tempForgePath, "version.json")).readAsStringSync());
      libraries!.addAll(versionJson["libraries"]);
    }
    await Installs.installLibraries(libraries!, path, nativesPath, installModel);


    installModel.setState("Install Forge Clients");
    // Copy Forge clients
    var forge_lib_path =
        p.join(path, "libraries", "net", "minecraftforge", "forge", version);

    var forgeClient =
        File(p.join(tempForgePath, "forge-$version-universal.jar"));
    if (forgeClient.existsSync()) {
    await  Utils.copyFile(
          source: forgeClient,
          destination: File(p.join(forge_lib_path, "forge-$version.jar")));
    }

    var forgeUniversal = File(p.join(tempForgePath, "maven", "net",
        "minecraftforge", "forge", version, "forge-$version-universal.jar"));
    if (forgeUniversal.existsSync()) {
     await Utils.copyFile(
          source: forgeUniversal,
          destination:
              File(p.join(forge_lib_path, "forge-$version-universal.jar")));
    }

    var secondForgeClient = File(p.join(tempForgePath, "maven", "net",
        "minecraftforge", "forge", version, "forge-$version.jar"));
    if (secondForgeClient.existsSync()) {
     await Utils.copyFile(
          source: secondForgeClient,
          destination: File(p.join(forge_lib_path, "forge-$version.jar")));
    }

    if (versiondata["processors"] != null) {
      await RunProcessors.runProcessors(
          versiondata.cast<String, dynamic>(),
          path,
          tempForgePath,
          p.join(tempForgePath, "data", "client.lzma"),
          "Java", installModel);
      //Todo: Implement a methode to runtime to get latest java runtime
    }

    if (versiondata["install"] != null) {
      versiondata = versiondata["versionInfo"];
    }
    if (versiondata["json"] != null) {
      var versionJson = jsonDecode(
          File(p.join(tempForgePath, "version.json")).readAsStringSync());
      versiondata = versionJson;
    }
    versiondata["nativesPath"] = nativesPath;

    await _createVersionDir(versiondata, version);
    print("Done!");
  }

  static _createVersionDir(Map versionJson, String version) async {
    String filepath =
        p.join(getworkpath(), "versions", "$version", "$version.json");
    String parentDirectory = p.dirname(filepath);
    await Directory(parentDirectory).create(recursive: true);
    await File(filepath).writeAsString(jsonEncode(versionJson));
    // created versionsDir
  }

  static String _getMinecraftVersion(Map versiondata) {
    String minecraft_version = versiondata["minecraft"] != null
        ? versiondata["minecraft"]
        : versiondata["install"]["minecraft"];
    return minecraft_version;
  }
}
