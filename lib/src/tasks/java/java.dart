import 'dart:io';

import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:path/path.dart' as path;

class Java {
  static String getJavaJdk(Version version) {
  
    ///Users/joshig/Documents/PixieLauncherInstances/zulu17.48.15-ca-jdk17.0.10-macosx_aarch64/zulu-17.jdk/Contents/Home/bin
    String javaVer17 =
        path.join(pixieInstances(), "zulu17.48.15-ca-jdk17.0.10-macosx_aarch64","zulu-17.jdk","Contents", "Home" , "bin", "java");
      
    String javaVer8 =
         path.join(pixieInstances(), "zulu8.76.0.17-ca-jdk8.0.402-macosx_aarch64","zulu-8.jdk","Contents", "Home" , "bin", "java");
    String majorVer = javaVer17;


    if (version <= Version(1, 16, 0)) {
      majorVer = javaVer8;
    }

    if(Platform.isMacOS && version < Version(1, 17, 1)) {
      //zulu8.76.0.17-ca-jdk8.0.402-macosx_x64
      majorVer =  path.join(pixieInstances(), "zulu8.76.0.17-ca-jdk8.0.402-macosx_x64","zulu-8.jdk","Contents", "Home" , "bin", "java");
    }

    return majorVer;
  }

  static bool get isJavaInstalled {
   

    return File(path.join(pixieInstances(), "zulu17.48.15-ca-jdk17.0.10-macosx_aarch64","zulu-17.jdk","Contents", "Home" , "bin", "java"))
            .existsSync() &&
        File(path.join(pixieInstances(), "zulu8.76.0.17-ca-jdk8.0.402-macosx_aarch64","zulu-8.jdk","Contents", "Home" , "bin", "java"))
            .existsSync();
  }
}
