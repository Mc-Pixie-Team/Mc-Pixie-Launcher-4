import 'dart:io';

import 'package:mclauncher4/src/tasks/version.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';

class Java {
  static String getJavaJdk(Version version) {
    String username = UsernameProvider.getUsername();

    String javaVer17 =
        "C:\\Users\\$username\\Documents\\PixieLauncherInstances\\zulu17.44.53-ca-jdk17.0.8.1-win_x64\\bin\\javaw.exe";
    String javaVer8 =
        "C:\\Users\\$username\\Documents\\PixieLauncherInstances\\zulu8.72.0.17-ca-jdk8.0.382-win_x64\\jre\\bin\\javaw.exe";
    String majorVer = javaVer17;

    if (version < Version(1, 16, 0)) {
      majorVer = javaVer8;
    }
    return majorVer;
  }

  static bool get isJavaInstalled {
    String username = UsernameProvider.getUsername();

    return File("C:\\Users\\$username\\Documents\\PixieLauncherInstances\\zulu17.44.53-ca-jdk17.0.8.1-win_x64\\bin\\javaw.exe")
            .existsSync() &&
        File("C:\\Users\\$username\\Documents\\PixieLauncherInstances\\zulu8.72.0.17-ca-jdk8.0.382-win_x64\\jre\\bin\\javaw.exe")
            .existsSync();
  }
}
