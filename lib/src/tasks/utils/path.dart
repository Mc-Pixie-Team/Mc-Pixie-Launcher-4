import 'package:path_provider/path_provider.dart';

Future<String> getbinpath() async {
  // return '${(await getApplicationDocumentsDirectory()).path}\\PixieLauncherInstances\\debug\\bin';
  return 'C:\\Users\\ancie\\Documents\\PixieLauncherInstances\\debug\\bin';
}

Future<String> getworkpath() async {
  //  return '${(await getApplicationDocumentsDirectory()).path}\\PixieLauncherInstances\\debug';
  return 'C:\\Users\\ancie\\Documents\\PixieLauncherInstances\\debug';
}

Future<String> getlibarypath() async {
  //  return '${(await getApplicationDocumentsDirectory()).path}\\PixieLauncherInstances\\debug';
  return 'C:\\Users\\ancie\\Documents\\PixieLauncherInstances\\debug';
}

Future<String> getTempForgePath() async {
  //return '${(await getTemporaryDirectory()).path}\\PixieLauncher\\Forge';
  return 'C:\\Users\\ancie\\AppData\\Local\\Temp\\PixieLauncher\\Forge';
}

Future<String> getTempCommandPath() async {
  // return '${(await getTemporaryDirectory()).path}\\PixieLauncher';
  return 'C:\\Users\\ancie\\AppData\\Local\\Temp\\PixieLauncher';
}

Future<String> getInstancePath() async {
  //return '${(await getApplicationDocumentsDirectory()).path}\\PixieLauncherInstances\\instance';
  return 'C:\\Users\\ancie\\Documents\\PixieLauncherInstances\\instance';
}

Future<String> getDocumentsPath() async {
  return 'C:\\Users\\ancie\\Documents';
}
