import 'dart:io';

class FileExplorer {
  static void openFileExplorer(String path) {
    if (Platform.isMacOS) {
      Process.start('open', [path]);
    } else if (Platform.isWindows) {
      Process.start('explorer', [path]);
    } else if (Platform.isLinux) {
      Process.start('xdg-open', [path]);
    } else {
      print('Unsupported platform');
    }
  }
}