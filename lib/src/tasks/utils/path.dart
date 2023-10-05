import 'package:path_provider/path_provider.dart';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class UsernameProvider {


static String getUsername() {
  int unLen = 256;
  return using<String>((arena) {
    final buffer = arena.allocate<Utf16>(sizeOf<Uint16>() * (unLen + 1));
    final bufferSize = arena.allocate<Uint32>(sizeOf<Uint32>());
    bufferSize.value = unLen + 1;
    final result = GetUserName(buffer, bufferSize);
    if (result == 0) {
      GetLastError();
      throw Exception(
          'Failed to get win32 username: error 0x${result.toRadixString(16)}');
    }
    return buffer.toDartString();
  });
}
}



Future<String> getbinpath() async {
  // return '${(await getApplicationDocumentsDirectory()).path}\\PixieLauncherInstances\\debug\\bin';
  return 'C:\\Users\\${UsernameProvider.getUsername()}\\Documents\\PixieLauncherInstances\\debug\\bin';
}

Future<String> getinstances() async {
  // return '${(await getApplicationDocumentsDirectory()).path}\\PixieLauncherInstances\\debug\\bin';
  return 'C:\\Users\\${UsernameProvider.getUsername()}\\Documents\\PixieLauncherInstances';
}


Future<String> getworkpath() async {
  //  return '${(await getApplicationDocumentsDirectory()).path}\\PixieLauncherInstances\\debug';
  return 'C:\\Users\\${UsernameProvider.getUsername()}\\Documents\\PixieLauncherInstances\\debug';
}

Future<String> getlibarypath() async {
  //  return '${(await getApplicationDocumentsDirectory()).path}\\PixieLauncherInstances\\debug';
  return 'C:\\Users\\${UsernameProvider.getUsername()}\\Documents\\PixieLauncherInstances\\debug';
}

Future<String> getTempForgePath() async {
 // return '${(await getTemporaryDirectory()).path}\\PixieLauncher\\Forge';
  return 'C:\\Users\\${UsernameProvider.getUsername()}\\AppData\\Local\\Temp\\PixieLauncher\\Forge';
}

Future<String> getTempCommandPath() async {
  // return '${(await getTemporaryDirectory()).path}\\PixieLauncher';
  return 'C:\\Users\\${UsernameProvider.getUsername()}\\AppData\\Local\\Temp\\PixieLauncher';
}

Future<String> getInstancePath() async {
  //return '${(await getApplicationDocumentsDirectory()).path}\\PixieLauncherInstances\\instance';
  return 'C:\\Users\\${UsernameProvider.getUsername()}\\Documents\\PixieLauncherInstances\\instance';
}

Future<String> getDocumentsPath() async {
  return 'C:\\Users\\${UsernameProvider.getUsername()}\\Documents';
}
