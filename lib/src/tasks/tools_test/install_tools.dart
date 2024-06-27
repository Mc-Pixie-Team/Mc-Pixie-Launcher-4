import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/tools_test/install_utils.dart';
import 'package:mclauncher4/src/tasks/utils/downloader.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:path/path.dart' as p;
import 'package:async_zip/async_zip.dart';

class Installs {

//MARK: InstallLibraries
static Future<void> installLibraries(List<dynamic> libraries,
  String path, String nativesPath) async {

  int librariesStack = 20;

  int _total = libraries.length;
  for (int count = 0; count <= libraries.length; count += librariesStack) {
  print("Progress: ${(count / libraries.length) * 100} %");
  Iterable<Future<dynamic>> librariesInstallations = Iterable.generate(
  librariesStack > _total ? _total : librariesStack,
  (index) async {

    var i = libraries[count + index];

    // Check if the rules allow this lib for the current system
    if (i.containsKey('rules') && !InstallUtils.parseRuleList(i['rules'])) {
      print("skip: " + i["name"]);
      return;
    }

    // Turn the name into a path
    var currentPath = p.join(path, 'libraries');
 
    String native = getNatives(i);


    if (i['downloads'].containsKey('artifact') &&
        i['downloads']['artifact']['url'].isNotEmpty &&
        i['downloads']['artifact'].containsKey('path')) {
       
        try {
          await Downloader(i['downloads']['artifact']['url'], p.join(path, 'libraries', i['downloads']['artifact']['path'])).startDownload();    
        } catch (e) {
          print("Failed download: "+ i['downloads']['artifact']['url'] + e.toString());
        }
        
    
        }
    if (native != "") {

      await Downloader(i['downloads']['classifiers'][native]['url'], p.join(currentPath, i['downloads']['classifiers'][native]['path'])).startDownload();
      // Converting dynamic list to String list
      List<String> excludeObj = [];
      if(i['extract'] != null && i['extract']['exclude'] != null) {
         for (var obj in i['extract']['exclude']){
         excludeObj.add(obj.toString());
         }
      }
      // Extracting File to folder
      extractZipArchiveSync(File(p.join(currentPath, i['downloads']['classifiers'][native]['path'])), Directory(nativesPath), exclude: i['extract'] == null ? null : excludeObj);
    }

  });
   await Future.wait(librariesInstallations);
   _total -= librariesStack;
  }

  print("Progress: 100 %");
}

//MARK: InstallAssets

static Future<void> installAssets(Map data, String path) async {
  if (data["assetIndex"] == null) {
    return;
  }

  final assetsPath = p.join(path, 'assets');

  final res = await http.get(Uri.parse(data["assetIndex"]["url"]));

  final file = File(p.join(assetsPath, 'indexes', '${data["assets"]}.json'));
  file.createSync(recursive: true);
  file.writeAsBytesSync(res.bodyBytes);
  final assetsData = jsonDecode(utf8.decode(res.bodyBytes));

  List values = (assetsData["objects"] as Map).values.toList();

  int assetsStack = 120;
  int _total = values.length;
  for (int count = 0; count <= values.length; count += assetsStack) {
    print('${(count/ (assetsData["objects"] as Map).values.length) * 100} %');
    Iterable<Future<dynamic>> assetsInstallation = Iterable.generate(
  assetsStack > _total ? _total : assetsStack,
  (index) async {
    var value = values[count + index];

    var downloadurl = 'https://resources.download.minecraft.net/${value["hash"].substring(0, 2)}/${value["hash"]}';
    var savePath =  p.join(
                assetsPath, 'objects', value["hash"].substring(0, 2), value["hash"]);
  try {
        await Downloader(
            downloadurl,
            savePath).startDownload();
  }catch (e) {
    print("Couldnt download assets: " + downloadurl);
      try {
           await Downloader(
            downloadurl,
            savePath).startDownload();
     }catch (e) {
        print("giving up on library " + downloadurl);
     }
  }

        
  });
  await Future.wait(assetsInstallation);
  _total -= assetsStack;
  }

  print('100 %');
}


static String getNatives(Map<String, dynamic> library) {
  // Returns the native part; the name of the key under "classifiers"

  var archtype = "64";

  if (library.containsKey("natives")) {
    print("nativeus");
    if (Platform.isWindows) {
      if (library["natives"].containsKey("windows")) {
        return library["natives"]["windows"].replaceAll("\${arch}", archtype);
      }
    } else if (Platform.isMacOS) {
      if (library["natives"].containsKey("osx")) {
        return library["natives"]["osx"].replaceAll("\${arch}", archtype);
      }
    } else if (Platform.isLinux) {
      if (library["natives"].containsKey("linux")) {
        return library["natives"]["linux"].replaceAll("\${arch}", archtype);
      }
    }
  }

  return "";
}
}