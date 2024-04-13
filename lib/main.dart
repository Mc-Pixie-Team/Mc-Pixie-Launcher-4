import 'package:mclauncher4/src/tasks/discord/discordRP.dart';
import 'src/app.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:mclauncher4/src/tasks/auth/supabase.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'dart:io' show Platform;

void main() async{
  supabaseHelpers().init();
  DiscordRP().initCS("1144740158374158366");
  await Path.init();
  await Hive.openBox("settings");
  runApp(
       McLauncher());
      if(Platform.isMacOS) {
         final win = appWindow;
    win.alignment = Alignment.center;
    
    win.title = "Mc-Pixie Launcher";
    win.size = Size(1530, 900);
    win.show();
      }else {
          doWhenWindowReady(() {
    final win = appWindow;
    win.alignment = Alignment.center;
    
    win.title = "Mc-Pixie Launcher";
    win.size = Size(1530, 900);
    win.show();
  });
      }
   

}
