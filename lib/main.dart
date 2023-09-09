import 'src/app.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:mclauncher4/src/tasks/auth/supabase.dart';

void main() {
  supabaseHelpers().init();
  Paint.enableDithering = true;
  runApp(const McLauncher());
  doWhenWindowReady(() {
    final win = appWindow;
    win.alignment = Alignment.center;
    win.title = "Mc-Pixie Launcher";
    win.size = Size(1530, 900);
    win.show();
  });
}
