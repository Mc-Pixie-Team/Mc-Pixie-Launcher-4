import 'dart:io';

import 'package:archive/archive_io.dart';
import './path.dart';


class Extract {


  extractfromjar(String pathfrom, String version) async{
    List<int> _bytes = [];

    _bytes = await File("${await getlibarypath()}\\libraries\\$pathfrom").readAsBytes();
    final archive = ZipDecoder().decodeBytes(_bytes);
    for ( var data in archive) {
       final filename = data.name;
    if (data.isFile) {
      final datadir = data.content as List<int>;
      File(await getbinpath() + "\\$version\\" + filename)
        ..createSync(recursive: true)
        ..writeAsBytesSync(datadir);
    } else {
      Directory(await getbinpath()+ "\\$version\\" + filename).create(recursive: true);
    }
    }
  }
}