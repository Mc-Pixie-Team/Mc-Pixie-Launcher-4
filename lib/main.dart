import 'package:mclauncher4/src/tasks/discord/discordRP.dart';
import 'src/app.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:mclauncher4/src/tasks/auth/supabase.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';


void main() async{
  supabaseHelpers().init();
  DiscordRP().initCS("1144740158374158366");
   Paint.enableDithering = true;
  await Path.init();
  runApp(
       McLauncher());
  doWhenWindowReady(() {
    final win = appWindow;
    win.alignment = Alignment.topLeft;
    
    win.title = "Mc-Pixie Launcher";
    win.size = Size(1530, 900);
    win.show();
  });
}
