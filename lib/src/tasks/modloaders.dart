import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/version.dart';

class Modloader with ChangeNotifier{

  double get mainprogress => throw 'dont call this method, the Modloader class is just an example class';
  get installstate => throw 'dont call this method, the Modloader class is just an example class';

  double get progress => throw 'dont call this method, the Modloader class is just an example class';


  Future<dynamic> install(Version version, ModloaderVersion modloaderVersion,
      [additional]) {
    throw 'dont call this method, the Modloader class is just an example class ';
  }
    Future<dynamic> run(String instanceName, Version version,
      ModloaderVersion modloaderVersion) {
    throw 'dont call this method, the Modloader class is just an example class';
  }

  Future<dynamic> getSafeDir(Version version, ModloaderVersion modloaderVersion){
  throw 'dont call this method, the Modloader class is just an example class';
  }
  int getsteps(Version version, [ModloaderVersion? modloaderVersion]){
     throw 'dont call this method, the Modloader class is just an example class';
  }
}