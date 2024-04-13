import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class Path {

static String instance_name = "PixieLauncherInstances";

static String? applicationDocumentsDirectory;
static String? temporaryDirectory;

static init() async{
 applicationDocumentsDirectory = (await getApplicationDocumentsDirectory()).path;
 temporaryDirectory = (await getTemporaryDirectory()).path;
}

//---


}



String getbinpath() {
  
  // return '${(await getApplicationDocumentsDirectory()).path}\\PixieLauncherInstances\\debug\\bin';
  
  return path.join( getDocumentsPath(), Path.instance_name, "debug", "bin");
}

String getinstances() {
  // return '${(await getApplicationDocumentsDirectory()).path}\\PixieLauncherInstances\\debug\\bin';
  return path.join(getDocumentsPath(), Path.instance_name);
}

String getworkpath() {
  //  return '${(await getApplicationDocumentsDirectory()).path}\\PixieLauncherInstances\\debug';
   return path.join(getDocumentsPath(), Path.instance_name, "debug");
}

String getlibarypath() {
  //  return '${(await getApplicationDocumentsDirectory()).path}\\PixieLauncherInstances\\debug';
  return path.join( getDocumentsPath(), Path.instance_name, "debug");
}

String getTempForgePath() {
  // return '${(await getTemporaryDirectory()).path}\\PixieLauncher\\Forge';
  if(Path.temporaryDirectory == null) throw "path must be initialized";

  return path.join(Path.temporaryDirectory!, 'PixieLauncher', 'Forge');
}


String getInstancePath() {
  //return '${(await getApplicationDocumentsDirectory()).path}\\PixieLauncherInstances\\instance';
  return path.join(getDocumentsPath(), Path.instance_name, "instance");
}
String getHTMLcachePath() {
  //return '${(await getApplicationDocumentsDirectory()).path}\\PixieLauncherInstances\\instance';
  return path.join(getDocumentsPath(), Path.instance_name, "htmlcache");
}


//--- 

String getTempCommandPath() {
  
  if(Path.temporaryDirectory == null) throw "path must be initialized";

  return path.join(Path.temporaryDirectory!, "PixieLauncher");
}

String getDocumentsPath() {
  
  if(Path.applicationDocumentsDirectory == null) throw "path must be initialized";

  return Path.applicationDocumentsDirectory!;
}

String pixieInstances()  {
    return path.join( getDocumentsPath(), Path.instance_name);
}