
import 'package:mclauncher4/src/tasks/version.dart';



class Java {
 static String getJavaJdk(Version version) {
         String javaVer17 =
        "C:\\Users\\zepat\\Documents\\PixieLauncherInstances\\install debug\\runtime\\java-runtime-gamma\\windows-x64\\java-runtime-gamma\\bin\\java.exe";
    String javaVer8 =
        "C:\\Users\\ancie\\.jabba\\jdk\\amazon-corretto@1.8.292-10.1\\bin\\java.exe";
    String majorVer = javaVer8;

    if (version > Version(1, 16, 4)) {
      majorVer = javaVer17;
    }
    return majorVer;
  }

}