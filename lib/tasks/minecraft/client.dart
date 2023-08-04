
import "package:path_provider/path_provider.dart" as path_provider;
import "dart:convert";
import "dart:io";



class Minecraft {
  final Future<Directory> appDocumentsDir = path_provider.getApplicationDocumentsDirectory();

  void run(Map packagejson, String path) async{
    List libraries = packagejson["libraries"];
    String os = "windows";
    String accessToken = "3423423jdisgjsdf";
    String username = "Fridolin";
    String stack = "C:\\Users\\zepat\\Documents\\PixieLauncherInstances\\debug\\versions\\${packagejson["id"]}\\${packagejson["id"]}.jar${(os == "windows") ? ";" : ":"}";

    for (var i = 0; i < libraries.length; i++) {
      Map libary = libraries[i];
      if (libary["rules"] == null) {
      } else if (chechAllowed(libary["rules"], os, "x64") == false) {
        continue;
      }
      if(libary["natives"] != null && libary["natives"][os] != null) { 
       print("adding native");
      // "$path/${libary["downloads"]["classifiers"][libary["natives"][os]]["path"]}${(os == "windows") ? ";" : ":"}";
      }
      stack += "$path/${libary["downloads"]["artifact"]["path"]}${(os == "windows") ? ";" : ":"}";
    }
     // print(stack);
     // C:\\Program Files\\Java\\jdk-17\\bin\\java.exe"
    String launchcommand = '& "C:\\Users\\zepat\\AppData\\Roaming\\.minecraft\\runtime\\jre-legacy\\windows-x64\\jre-legacy\\bin\\java.exe" -cp "$stack" net.minecraft.client.main.Main --username fridolin --version 1.16.4 --gameDir, C:\\Users\\zepat\\AppData\\Roaming\\.minecraft, --assetsDir, C:\\Users\\zepat\\AppData\\Roaming\\.minecraft\\assets --assetIndex, 1.16 --uuid, 122334dsgfds --accessToken sdfghfgbnnrdf';
    print(launchcommand);
     var tempFile = File("${(await path_provider.getTemporaryDirectory()).path}\\pixie\\temp_command.ps1");
    await tempFile.create(recursive: true);
     await tempFile.writeAsString(launchcommand);

    var result = await Process.start("powershell", ["-ExecutionPolicy", "Bypass", "-File", tempFile.path ], runInShell: true );

    
    stdout.addStream(result.stdout);
    stderr.addStream(result.stderr);
  }

  bool chechAllowed(List rules, String osName, String osArch) {
     
  if (rules.length == 0) {
    return true;
  }  

  for (var i = 0; i < rules.length; i++) {
    Map rule = rules[i];
    if (rule == null || rule["os"] == null ) continue;
    if (rule["os"]["arch"] == osArch && rule["action"] == "allow") {
      return true;
    }
    if (rule["os"]["name"] == osName && rule["action"] == "allow") {
      return true;
    }
  }

  return false;
 
}
}