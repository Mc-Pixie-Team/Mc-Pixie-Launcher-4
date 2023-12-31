import 'package:mclauncher4/src/tasks/discord/discordRP.dart';

import 'src/app.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:mclauncher4/src/tasks/auth/supabase.dart';

void main() {
  supabaseHelpers().init();
  DiscordRP().initCS("1144740158374158366");
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
