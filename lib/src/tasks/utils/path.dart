import 'package:path_provider/path_provider.dart';

Future<String> getbinpath() async{
    
    return '${(await getApplicationDocumentsDirectory()).path}\\PixieLauncherInstances\\debug\\bin';
  }

Future<String> getworkpath() async{
    
    return '${(await getApplicationDocumentsDirectory()).path}\\PixieLauncherInstances\\debug';
  }
Future<String> getlibarypath() async{
    
    return '${(await getApplicationDocumentsDirectory()).path}\\PixieLauncherInstances\\debug';
  }
Future<String> getTempForgePath() async {
  
  return '${(await getTemporaryDirectory()).path}\\PixieLauncher\\Forge';
}

Future<String> getTempCommandPath() async {
  
  return '${(await getTemporaryDirectory()).path}\\PixieLauncher';
}

Future<String> getInstancePath() async {
  
  return '${(await getApplicationDocumentsDirectory()).path}\\PixieLauncherInstances\\instance';
}


