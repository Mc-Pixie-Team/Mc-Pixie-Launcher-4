import 'package:mclauncher4/src/tasks/discord/discordRP.dart';
import 'package:mclauncher4/src/widgets/internet_connection_checker.dart';
import 'src/app.dart';
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/auth/supabase.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'dart:io' show Platform;


void main() async {
  supabaseHelpers().init();
  
  DiscordRP().initCS("1144740158374158366");
  await InternetConnectionCheckerHelper().initListener();
  await Path.init();
  await Hive.openBox("settings");
  await Hive.openBox("MinecraftPlayerHeads");
  await Hive.openBox("MinecraftPlayerCapes");
  await Hive.openBox("RecentlyPlayed");

    WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(1530, 900),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    windowButtonVisibility: false,
    titleBarStyle: TitleBarStyle.hidden
  );
  

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });


  runApp(McLauncher());

}
