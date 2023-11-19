import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mclauncher4/src/objects/accounts/minecraft.dart';
import 'package:mclauncher4/src/pages/HomePage.dart';
import 'package:mclauncher4/src/pages/debugpage.dart';
import 'package:mclauncher4/src/pages/installedModpacks.dart';
import 'package:mclauncher4/src/pages/providers/ModListPage.dart';
import 'package:mclauncher4/src/pages/settings_page/settingsPage.dart';
import 'package:mclauncher4/src/pages/splash/splash.dart';
import 'package:mclauncher4/src/pages/splash/splashLogin.dart';
import 'package:mclauncher4/src/pages/user_page/userPage.dart';
import 'package:mclauncher4/src/tasks/apis/modrinth.api.dart';
import 'package:mclauncher4/src/tasks/auth/microsoft.dart';
import 'package:mclauncher4/src/tasks/discord/discordRP.dart';
import 'package:mclauncher4/src/tasks/fabric/fabric.dart';
import 'package:mclauncher4/src/tasks/forge/forge.dart';
import 'package:mclauncher4/src/tasks/models/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/win32Deleter.dart';
import 'package:mclauncher4/src/widgets/ImportField.dart';
import 'package:mclauncher4/src/widgets/SidePanel/SidePanel.dart';
import 'package:mclauncher4/src/widgets/components/sizetransitioncustom.dart';
import 'package:mclauncher4/src/tasks/utils/downloads.dart';
import 'package:mclauncher4/src/tasks/minecraft/minecraft_install.dart';
import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:mclauncher4/src/widgets/SidePanel/taskwidget.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/colorSchemes.dart';
import 'theme/textSchemes.dart';
import 'package:flutter/material.dart';
import 'widgets/NavigationDrawer/itemDrawer.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'widgets/NavigationDrawer/menuItem.dart';
import 'widgets/divider.dart' as Div;
import 'package:animations/animations.dart';
import 'package:mclauncher4/src/widgets/SidePanel/SidePanel.dart';
import 'package:mclauncher4/src/tasks/auth/supabase.dart';
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad
      };
}

class McLauncher extends StatelessWidget {
  const McLauncher({super.key});

  Future<String> get customWait async {
    await Future.delayed(Duration(seconds: 10));
    return "done!";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        scrollBehavior: MyCustomScrollBehavior(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            typography: Typography(black: blackTextSchemes),
            scrollbarTheme: ScrollbarThemeData()),
        darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
            typography: Typography(black: blackTextSchemes)),
        themeMode: ThemeMode.dark,
        home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool shouldSplashedDisplayed = true;
  bool isSplashed = true;
  int pageIndex = 1;
  int pageIndex_old = 1;
  EdgeInsets edgeInsets =
      EdgeInsets.only(left: 10, top: 12, right: 10, bottom: 12);
  final List<Widget> _pages = [
    HomePage(),
    ModListPage(),
    Debugpage(),
    Container(
      key: Key('4'),
      color: Color.fromARGB(255, 146, 91, 218),
    ),
    Container(
      key: Key('5'),
      color: Color.fromARGB(255, 146, 91, 218),
    ),
    SettingsPage(),
    UserPage(),
  ];

  OverlayEntry _overlayEntryBuilder() {
    return OverlayEntry(
      builder: (context) {
        return Align(
            alignment: Alignment.center,
            child: Container(
              height: 30,
              width: 30,
              color: Colors.green,
            ));
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    MinecraftAccountUtils().initOnFirstStart();
    Modpacks.generateManifest();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(onPressed: () async {
/*           await Minecraft().install('https://piston-meta.mojang.com/v1/packages/ed5d8789ed29872ea2ef1c348302b0c55e3f3468/1.7.10.json'); */
          // Map res = await Download().getJson('https://piston-meta.mojang.com/v1/packages/ed5d8789ed29872ea2ef1c348302b0c55e3f3468/1.7.10.json');
          // Minecraft().run(res, 'C:\\Users\\ancie\\Documents\\PixieLauncherInstances\\debug\\libraries');

          supabaseHelpers().signoutUser();

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
                  children: [
                    Container(
                      height: 28,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Align(
                        child: MenuItem(
                          onClick: () {
                            int index = 6;
                            print('change: ' + index.toString());
                            pageIndex_old = pageIndex;

                            if (index != pageIndex_old) {
                              setState(() {
                                pageIndex = index;
                              });
                            }
                          },
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
                        onClick: () {
                          int index = 5;
                          print('change: ' + index.toString());
                          pageIndex_old = pageIndex;

                          if (index != pageIndex_old) {
                            setState(() {
                              pageIndex = index;
                            });
                          }
                        },
                        title: 'Settings',
                        icon: Icon(
                          Icons.settings,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Padding(
                        child: Div.Divider(
                          size: 20,
                        ),
                        padding: EdgeInsets.only(top: 20, bottom: 20)),
                    ItemDrawer(
                        offset: 0,
                        onChange: (index) {
                          index = index + 1;
                          print('change: ' + index.toString());
                          pageIndex_old = pageIndex;

                          if (index != pageIndex_old) {
                            setState(() {
                              pageIndex = index;
                            });
                          }
                        },
                        title: 'Providers',
                        children: [
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
                                  onClick: () {
                                    int index = 0;
                                    print('change: ' + index.toString());
                                    pageIndex_old = pageIndex;

                                    if (index != pageIndex_old) {
                                      setState(() {
                                        pageIndex = index;
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
                    Div.Divider(
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
                  child: PageTransitionSwitcher(
                duration: const Duration(milliseconds: 400),
                reverse: pageIndex < pageIndex_old,
                child: Padding(
                  key: UniqueKey(),
                  padding: edgeInsets,
                  child: _pages![pageIndex],
                ),
                transitionBuilder:
                    (child, primaryAnimation, secondaryAnimation) =>
                        SharedAxisTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.vertical,
                  fillColor: Colors.transparent,
                  child: child,
                ),
              )),
              SidePanel()

              // SizeTransition(sizeFactor: 1, child: Padding(padding: edgeInsets,),)
            ],
          ),

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
          SizedBox(
            height: 35,
            child: Align(
                alignment: Alignment.topLeft,
                child: Row(
                  children: [Expanded(child: MoveWindow()), WindowButtons()],
                )),
          ),
        ]));
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: Color.fromARGB(255, 192, 192, 192),
    mouseOver: Color.fromARGB(66, 172, 172, 172),
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
          colors: buttonColors,
          onPressed: () {
            print('close');
            exit(0);
          },
        ),
      ],
    );
  }
}
