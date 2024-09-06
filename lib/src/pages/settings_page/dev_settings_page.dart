import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/models/settings_keys.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:path/path.dart' as p;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DevSettingsPage extends StatefulWidget {
  const DevSettingsPage({ Key? key }) : super(key: key);

  @override
  _DevSettingsPageState createState() => _DevSettingsPageState();
}

class _DevSettingsPageState extends State<DevSettingsPage> {

  @override
  initState() {
    print("OPENED DEVELOPER SETTINGS");
    super.initState();
  }

  clearModpackManifest() {
    File(p.join(getInstancePath(), "manifest.json")).writeAsString("[]");
  }
  deleteAllModpack() {
   for (var item in Directory(getInstancePath()).listSync()) {
    item.deleteSync();
    print("DELETE");
   }
  }
  TEST() {
               var settingsBox = Hive.box('settings');

           settingsBox.put(SettingsKeys.enableDeveloperMode, false);
          //windowManager.setAsFrameless();
          // print(await SecureStorage().readSecureData("accounts"));
   
          //  await SecureStorage.storage.delete(key: "test");
          //  await SecureStorage.storage.write(key: "test", value: "[${math.Random.secure().nextInt(25)}]", mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock_this_device));
          // await MinecraftAccountUtils().saveAccounts([]);
          // //  await SecureStorage.storage.deleteAll();

          // StaticSidePanelController.controller.push(
          //     Container(
          //       color: Colors.green,
          //       width: 200.0,
          //     ),
          //     200.0);

          // showDialog(
          //     context:  navigatorKey.currentContext!,
          //     builder: (context) {
          //       return AlertDialog(
          //         title: Text("Oh no an Error occured!"),
          //         content:  SelectableText("t"),
          //         actions: [
          //          TextButton(
          //               onPressed: () {
          //                 Navigator.of(context).pop();
          //               },
          //               child: Text("Close"))

          //         ],
          //       );
          //     });

          // final SharedPreferences prefs = await SharedPreferences.getInstance();
          //  print(prefs.getInt(SettingsKeys.minRamUsage));
          //   print(prefs.getInt(SettingsKeys.maxRamUsage));
          // InstalledModpacksUIHandler.installCardChildren.add(Container(height: 100, width: 100,color: Colors.green,));
          //  print( InstalledModpacksUIHandler.installCardChildren.value.length);

          // print(await SecureStorage.storage.read(key: "test"));
          // print(await SecureStorage.isKeyRegistered("accounts"));
          // print( await SecureStorage.storage.readAll());
          //await MinecraftAccountUtils().saveAccounts([]);
          //   print("start install");
          // getDeviceInfos();
          // print(SidePanel.state.gettest);
          // SidePanel.push(Container(height: double.infinity, width: 100.0, color: Colors.green,), 100.0);
          // await Minecraft().install(Version(1,18,2));
          // print("start url");
          //     Map res = await DownloadUtils().getJson(Version(1,21));
          // //    List<dynamic> libraries = res["libraries"];
          // //   await Installs.installLibraries(libraries, getlibarypath());
          // //  await Installs.installAssets(res, getlibarypath());
          // MinecraftCommand.getlaunchCommand(res, getlibarypath());

          // await MinecraftInstall.run(Version(1, 21), installModel);
          //  print(Utils.parseMaven("net.minecraftforge:forge:1.7.10-10.13.4.1614-1.7.10"));
          // await ForgeInstall.install("1.16.5-36.2.40", getlibarypath(), installModel);
          //   await FabricInstall.run("0.15.11", "1.21", getlibarypath(), installModel);
          //Helpfull when a specific minecraft forge version wont load: https://www.minecraftforum.net/forums/support/java-edition-support/3048893-forge-1-7-2-crashes-with-no-error-message
          //   print("Running minecraft");
          //  await ForgeInstall.run("1.8.8-11.15.0.1654-1.8.8", getlibarypath());
          //Runtime.installJvmRuntime("java-runtime-delta", getlibarypath());
          // print(Platform.environment['PROCESSOR_ARCHITECTURE']);
          //    Minecraft().run(res, '4656567332');
          // print(getTempCommandPath());
          //   supabaseHelpers().signoutUser();

          //  DiscordRP().initCS();
          // SidePanel().setSecondary(Container(color: Theme.of(context).colorScheme.primary));

          // SidePanel().addToTaskWidget();
          /* await Forge().install();
          await Forge().run(); */
          /* Microsoft().authenticate(); */
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const pixieLoginScreen()),
          // );

          // Uint8List? buffer =
          //     await murmur2.get_jar_contents("C:/Users/joshi/Documents/PixieLauncherInstances/test/resourcepacks/ComplementaryReimagined_r5.1.1.zip");
          // int result = await murmur2.compute_hash(buffer);
          // buffer = null;

          // print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20,),
          TextButton(onPressed: () => clearModpackManifest(), child: Text("Clear Modpack Manifest")),
          TextButton(onPressed: () => TEST(), child: Text("TEST"))
        ],
      ),
    );
  }
}