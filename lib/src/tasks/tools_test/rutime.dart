import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/utils/downloader.dart';
import 'package:path/path.dart' as p;


class Runtime {

static Future<void> installJvmRuntime(
  String jvmVersion,
  String minecraftDirectory, 
) async {
  print("start installing jvmR");

  final String jvmManifestUrl = "https://launchermeta.mojang.com/v1/products/java-runtime/2ec0cc96c44e5a76b9c8b7c39df7210883d12871/all.json";

  final manifestResponse = await http.get(Uri.parse(jvmManifestUrl));
  final manifestData = jsonDecode(manifestResponse.body);
  final platformString = getJvmPlatformString();

  print(platformString);
  if (!manifestData[platformString].containsKey(jvmVersion)) {
    throw Exception('VersionNotFound: $jvmVersion');
  }

  if (manifestData[platformString][jvmVersion].isEmpty) {
    print("jvm is empty");
    return;
  }

  final platformManifestResponse = await http.get(
    Uri.parse(manifestData[platformString][jvmVersion][0]['manifest']['url']),
  );
  final platformManifest = json.decode(platformManifestResponse.body);
  final basePath = p.join(minecraftDirectory, 'runtime', jvmVersion, platformString, jvmVersion);


  for (var key in platformManifest['files'].keys) {
    final value = platformManifest['files'][key];
    final currentPath = p.join(basePath, key);

    if (value['type'] == 'file') {

      // We dont download the compresses file (lzma)
      await Downloader(
        value['downloads']['raw']['url'],
        currentPath,
      ).startDownload();
      // Make files executable for unix systems
      if (value['executable'] == true) {
        try {
          await Process.run('chmod', ['+x', currentPath]);
        } catch (e) {
          // Handle error
        }
      }

    } else if (value['type'] == 'directory') {

      await Directory(currentPath).create(recursive: true);
      
    } else if (value['type'] == 'link') {

      await Directory(p.dirname(currentPath)).create(recursive: true);
      try {
        await Link(currentPath).create(value['target']);
      } catch (e) {
        // Handle error
      }
    }

    //callback['setProgress']?.call(count);
  }

  final versionPath = p.join(minecraftDirectory, 'runtime', jvmVersion, platformString, '.version');
  final versionFile = File(versionPath);
  await versionFile.writeAsString(manifestData[platformString][jvmVersion][0]['version']['name']);
}

static String getJvmPlatformString() {
  
  String? arch = Platform.environment['PROCESSOR_ARCHITECTURE'];
  if(arch == null) throw "Couldn\'t get arch typ of host machine";
  if(Platform.isWindows) {
    if(arch == "AMD64") {
      return "windows-x64";
    }else {
      return "windows-x86";
    }
  }else if (Platform.isMacOS) {
    if(arch == "ARM64") { //No 32bit support needed, cause who uses a 32bit old mac
      return "mac-os-arm64";
    }else {
      return "mac-os";
    }
  }else if(Platform.isLinux) {
    if(arch == "AMD64") {
      return "linux";
    }else {
      return "linux-i386";
    }
  }

  return "gamecore"; 
}

static String? getExecutablePath(String jvmVersion, String minecraftDirectory) {
  String jvmPlatformString = getJvmPlatformString();
  
  String javaPath = p.join(minecraftDirectory, "runtime", jvmVersion, jvmPlatformString, jvmVersion, "bin", "java");
  
  if (File(javaPath).existsSync()) {
    return javaPath;
  } else if (File("$javaPath.exe").existsSync()) {
    return "$javaPath.exe";
  }

  javaPath = javaPath.replaceAll(
    p.join("bin", "java"),
    p.join("jre.bundle", "Contents", "Home", "bin", "java")
  );

  if (File(javaPath).existsSync()) {
    return javaPath;
  } else {
    return null;
  }
}

}