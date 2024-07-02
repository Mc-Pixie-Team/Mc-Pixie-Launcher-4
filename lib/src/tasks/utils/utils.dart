import 'dart:async';
import 'dart:io';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive_io.dart';
import 'package:mclauncher4/src/tasks/models/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/models/version_object.dart';
import './path.dart';

class Utils {

  static void copyDirectory({required Directory source, required Directory destination}) {
 
    
    if(!( destination.existsSync())) {
              destination.createSync(recursive: true);
          }

      final fileitems = source.listSync();

 fileitems.forEach( (fileEntity){ 
        final newPath = destination.path + Platform.pathSeparator + path.basename(fileEntity.path);
        if(fileEntity is File) {
          
         fileEntity.copySync(newPath);
          // try {
          //   await copyFile( source: fileEntity,  destination: File( newPath));
          // } catch (e) {
        
          // }
         
        }else if(fileEntity is Directory) {
        copyDirectory(source: fileEntity, destination: Directory(newPath));
        }
      });
   
      print("copy methode end");
  }



    static Future<void> copyFile({required File source, required File destination}) async {
    
          if(!(await destination.exists())) {
              await destination.create(recursive: true);
          }

          if(source.path == destination.path) throw "destination and source have the same path: ${destination.path}";

        final dataStream = destination.openWrite();
        await dataStream.addStream(source.openRead());

        await dataStream.close();
     
  }



  static List<String> listTOListString(List<dynamic> list) {
      List<String> exp = [];

      for (var item in list) {
        exp.add(item.toString());
      }
      return exp;
  }
}
