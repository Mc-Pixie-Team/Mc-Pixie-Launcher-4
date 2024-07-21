
import 'dart:ffi';
import 'dart:io' show Directory, File, OSError, PathExistsException, Platform;
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;



class murmur2 {
static const platform = MethodChannel("mc-pixie.com/murmurhash");

static Future<Uint8List> get_jar_contents(String path) async {

  if(!File(path).existsSync()) throw PathExistsException(path, OSError("File doesnt exist"));
  var result;
  try {
    result = await platform.invokeMethod<Uint8List>('get_jar_contents', {"path" : path});
  } on PlatformException catch (e) {
    print(e);
    result = Uint8List(0);
  }

  return result;
}

static Future<int> compute_hash(Uint8List buffer) async {
  var result;
  try {
    result = await platform.invokeMethod<int>('compute_hash', {"buffer" : buffer});
  } on PlatformException catch (e) {
    print(e);
    result = 0;
  }

  return result;
}
}