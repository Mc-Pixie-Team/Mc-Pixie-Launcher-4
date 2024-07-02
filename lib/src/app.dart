import 'dart:io' show Directory, File, Platform, exit;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:mclauncher4/src/objects/accounts/minecraft.dart';
import 'package:mclauncher4/src/pages/home_page/home_page.dart';
import 'package:mclauncher4/src/pages/debug_page.dart';
import 'package:mclauncher4/src/pages/installed_modpacks_handler.dart';
import 'package:mclauncher4/src/pages/providers/modlist_page.dart';
import 'package:mclauncher4/src/pages/settings_page/settings_page.dart';
import 'package:mclauncher4/src/pages/user_page/user_page.dart';
import 'package:mclauncher4/src/pages/installed_modpacks_handler.dart';

import 'package:mclauncher4/src/tasks/models/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/models/navigator_key.dart';
import 'package:mclauncher4/src/tasks/models/settings_keys.dart';
import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:mclauncher4/src/tasks/storage/secure_storage.dart';
import 'package:mclauncher4/src/tasks/installs/fabric/fabric_install.dart';
import 'package:mclauncher4/src/tasks/installs/forge/forge_install.dart';
import 'package:mclauncher4/src/tasks/installs/minecraft/minecraft_install.dart';
import 'package:mclauncher4/src/tasks/installs/install_model.dart';
import 'package:mclauncher4/src/tasks/installs/minecraft/minecraft_command.dart';
import 'package:mclauncher4/src/tasks/installs/java/rutime.dart';

import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/installs/install_tools.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:mclauncher4/src/widgets/import_field.dart';
import 'package:mclauncher4/src/widgets/side_panel/side_panel.dart';
import 'package:path_provider/path_provider.dart';
import 'theme/colorSchemes.dart';
import 'theme/textSchemes.dart';
import 'package:flutter/material.dart';
import 'widgets/navigation_drawer/item_drawer.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'widgets/navigation_drawer/menu_item.dart';
import 'widgets/divider.dart' as div;
import 'package:animations/animations.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices =>
      {PointerDeviceKind.touch, PointerDeviceKind.trackpad};

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
        return const BouncingScrollPhysics();
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return const ClampingScrollPhysics();
    }
  }
}

class McLauncher extends StatefulWidget {
  const McLauncher({super.key});

  @override
  State<StatefulWidget> createState() => _McLauncherState();
  // TODO: implement createState

  static _McLauncherState of(BuildContext context) =>
      context.findAncestorStateOfType<_McLauncherState>()!;
}

class _McLauncherState extends State<McLauncher> {
  Future<String> get customWait async {
    await Future.delayed(Duration(seconds: 10));
    return "done!";
  }

  late Widget mainWidget;
  ThemeMode _themeMode = ThemeMode.system;

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  void initState() {
    mainWidget = buildMainWidget();
    super.initState();
  }

  Widget buildMainWidget() {
    return MaterialApp(
        scrollBehavior: MyCustomScrollBehavior(),
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        routes: {
          "/test": (context) => Material(child: Debugpage()),
        },
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            typography: Typography(black: blackTextSchemes),
            scrollbarTheme: ScrollbarThemeData()),
        darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
            typography: Typography(black: blackTextSchemes)),
        themeMode: _themeMode,
        home: MainPage(),
        builder: (context, child) => Stack(children: [
              child!,
              SizedBox(
                height: 35,
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Expanded(child: MoveWindow()),
                        WindowButtons()
                      ],
                    )),
              ),
            ]));
  }

  @override
  Widget build(BuildContext context) {
    return mainWidget;
  }
}

// ignore: must_be_immutable
class MainPage extends StatefulWidget {
  int pageIndex = 1;
  int oldPageIndex = 1;
  MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late BuildContext innercontext;

  bool shouldSplashedDisplayed = true;
  bool isSplashed = true;

  EdgeInsets edgeInsets =
      EdgeInsets.only(left: 10, top: 12, right: 10, bottom: 12);

  final List<Widget> _pages = [
    HomePage(),
    ModListPage(
      providerString: "modrinth",
      key: Key("modrinth"),
    ),
    const Debugpage(),
    ModListPage(
      providerString: "curseforge",
      key: Key("curseforge"),
    ),
    Container(
      key: Key('5'),
      color: Color.fromARGB(255, 146, 91, 218),
    ),
    const SettingsPage(),
    const UserPage(),
  ];

  @override
  void initState() {
    print("Main app init Called");
    // TODO: implement initState
    MinecraftAccountUtils().initOnFirstStart();

    InstalledModpacksHandler.getPacksformManifest().then((value) {
      InstalledModpacksUIHandler.installCardChildren.value
          .removeWhere((element) {
        for (var i in value) {
          if (element.key == i.key) return true;
        }
        return false;
      });
      InstalledModpacksUIHandler.installCardChildren.value.addAll(value);
    });

    super.initState();
  }

  RectTween _createRectTween(Rect? begin, Rect? end) {
    return MaterialRectArcTween(begin: begin, end: end);
  }

  Navigator _getNavigator(BuildContext context) {
    return Navigator(
      initialRoute: "/",
      observers: [HeroController(createRectTween: _createRectTween)],
      onGenerateRoute: (RouteSettings settings) {
        print(settings.name);
        //you need to code the routes using settings == "[route name]"
        return CupertinoPageRoute(
            settings: settings,
            builder: (context) {
              innercontext = context;
              return PageTransitionSwitcher(
                duration: const Duration(milliseconds: 400),
                reverse: widget.pageIndex < widget.oldPageIndex,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    key: UniqueKey(),
                    child: _pages[widget.pageIndex]),
                transitionBuilder:
                    (child, primaryAnimation, secondaryAnimation) =>
                        SharedAxisTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.vertical,
                  fillColor: Colors.transparent,
                  child: child,
                ),
              );
            });
      },
    );
  }

  void onDrawerChange(int index) async {
    // if(Navigator.of(innercontext).canPop()){
    //   Navigator.of(innercontext).pop();
    // }

    widget.oldPageIndex = widget.pageIndex;

    if (index != widget.oldPageIndex) {
      if (Navigator.canPop(innercontext)) {
        Navigator.popUntil(innercontext, (route) {
          return route.settings.name == "/";
        });
        await Future.delayed(Duration(milliseconds: 450));
      }
      setState(() {
        widget.pageIndex = index;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(onPressed: () async {
          
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
        }),
        body: Stack(children: [
          Row(
            children: [
              //   NavigationDrawer(children: children)

              Container(
                height: double.infinity,
                width: 200,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      height: Platform.isMacOS ? 40 : 28,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Align(
                        child: MenuItem(
                          onClick: () => onDrawerChange(6),
                          title: 'Profile',
                          icon: Icon(
                            Icons.person,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: MenuItem(
                        onClick: () => onDrawerChange(5),
                        title: 'Settings',
                        icon: Icon(
                          Icons.settings,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Padding(
                        child: div.CustomDivider(
                          size: 20,
                        ),
                        padding: EdgeInsets.only(top: 20, bottom: 20)),
                    ItemDrawer(
                        offset: 0,
                        onChange: (index) {
                          index = index + 1;
                          onDrawerChange(index);
                        },
                        title: 'Providers',
                        children: <ItemDrawerItem>[
                          ItemDrawerItem(
                            icon: Icon(
                              Icons.sms,
                              size: 14,
                            ),
                            title: 'Modrinth',
                          ),
                          ItemDrawerItem(
                            icon: Icon(
                              Icons.sms,
                              size: 14,
                            ),
                            title: 'Pixie',
                          ),
                          ItemDrawerItem(
                            icon: Icon(
                              Icons.sms,
                              size: 14,
                            ),
                            title: 'Curseforge',
                          ),
                          ItemDrawerItem(
                            icon: Icon(
                              Icons.sms,
                              size: 14,
                            ),
                            title: 'FTB',
                          ),
                        ]),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 15, right: 15, top: 10, bottom: 17),
                        child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.all(
                                    Radius.elliptical(18, 18))),
                            width: double.infinity,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                ),
                                child: MenuItem(
                                  width: 140,
                                  onClick: () async {
                                    int index = 0;
                                    print('change: ' + index.toString());
                                    widget.oldPageIndex = widget.pageIndex;

                                    if (Navigator.canPop(innercontext)) {
                                      Navigator.popUntil(innercontext, (route) {
                                        return route.settings.name == "/";
                                      });

                                      await Future.delayed(
                                          Duration(milliseconds: 450));
                                    }
                                    if (index != widget.oldPageIndex) {
                                      setState(() {
                                        widget.pageIndex = index;
                                      });
                                    }
                                  },
                                  title: 'My Modpacks',
                                  icon: Icon(
                                    Icons.folder,
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ))),
                    div.CustomDivider(
                      size: 20,
                    ),
                    SizedBox(
                      height: 17,
                    ),
                    Expanded(child: SizedBox.expand()),
                    Align(
                      alignment: Alignment(-0.7, 0.2),
                      child: Text(
                        'Import Modpacks:',
                        style: Theme.of(context).typography.black.bodySmall,
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 15, right: 15, bottom: 20, top: 8),
                        child: ImportField())
                  ],
                ),
              ),
              Expanded(
                  child: Padding(
                      padding: edgeInsets, child: _getNavigator(context))),

              SidePanel(
                controller: StaticSidePanelController.controller,
              )

              // SizeTransition(sizeFactor: 1, child: Padding(padding: edgeInsets,),)
            ],
          ),
        ])

        // shouldSplashedDisplayed
        //     ? AnimatedOpacity(
        //         onEnd: () {
        //           setState(() {
        //             shouldSplashedDisplayed = false;
        //           });

        //         },
        //         opacity: isSplashed ? 1.0 : 0.0,
        //         curve: Curves.easeOutExpo,
        //         duration: Duration(milliseconds: 800),
        //         child: Container(
        //           height: double.infinity,
        //           width: double.infinity,
        //           color: Theme.of(context).colorScheme.background,
        //           child: SplashScreen(),
        //         ),
        //       )
        //     : Container(),
        );
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: Color.fromARGB(255, 192, 192, 192),
    mouseOver: Color.fromARGB(66, 172, 172, 172),
    mouseDown: Color.fromARGB(0, 92, 92, 92), //Code by Mc-PIXWIE
    iconMouseOver: const Color.fromARGB(255, 255, 255, 255),
    iconMouseDown: Color.fromARGB(255, 153, 153, 153));

final closebuttonColors = WindowButtonColors(
    iconNormal: Color.fromARGB(255, 192, 192, 192),
    mouseOver: Color.fromARGB(255, 189, 0, 0),
    mouseDown: Color.fromARGB(0, 92, 92, 92), //Code by Mc-PIXWIE
    iconMouseOver: const Color.fromARGB(255, 255, 255, 255),
    iconMouseDown: Color.fromARGB(255, 153, 153, 153));

class WindowButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //Code by Mc-PIXIE

        MinimizeWindowButton(
          colors: buttonColors,
        ),
        MaximizeWindowButton(
          colors: buttonColors,
        ),
        CloseWindowButton(
            colors: closebuttonColors,
            onPressed: () {
              print('close');
              exit(0);
            }),
      ],
    );
  }
}
