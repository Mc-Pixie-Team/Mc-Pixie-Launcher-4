
import 'dart:io';

import 'package:mclauncher4/src/tasks/version.dart';



class Java {
 static String getJavaJdk(Version version) {
         String javaVer17 =
        "C:\\Program Files\\Java\\jdk-17\\bin\\javaw.exe";
    String javaVer8 =
        "C:\\Program Files\\Java\\jdk1.8.0\\bin\\javaw.exe";
    String majorVer = javaVer17 ;

    if (version < Version(1, 16,0)) {
      majorVer = javaVer8;
    }
    return majorVer;
  }

  static bool get isJavaInstalled {

   
    return  File("C:\\Users\\zepat\\Documents\\PixieLauncherInstances\\jdk-17\\bin\\javaw.exe").existsSync() && File("C:\\Users\\zepat\\Documents\\PixieLauncherInstances\\jdk1.8.0_202\\bin\\javaw.exe").existsSync();
  }

}