import 'src/app.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';


void main() {
  runApp(const McLauncher());
  doWhenWindowReady(() {
    final win = appWindow;

    win.alignment = Alignment.center;
    win.title = "Mc-Pixie Launcher";
    win.size = Size(1500, 850);
    win.show();
  });
}


