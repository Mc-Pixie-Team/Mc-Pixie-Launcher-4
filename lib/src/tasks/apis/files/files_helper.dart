import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:path/path.dart' as p;
class FileHelper {

String directoryPath;

Timer? timer;

FileHelper({required this.directoryPath}){

}

save(List<UMF> files) {
  if(timer != null) timer!.cancel();
   timer = Timer(Duration(seconds: 2), () { 
    _write(files);
  });
}

_write(List<UMF> files) {
  print("write");
  List convertedumf = [];

  files.forEach((element) {
    convertedumf.add(UMF.toJson(element));
  }); 

 Map instance = jsonDecode(File(p.join(directoryPath, "instance.json")).readAsStringSync());
 instance["files"] = convertedumf;
 File(p.join(directoryPath, "instance.json")).writeAsStringSync(jsonEncode(instance));
}

}