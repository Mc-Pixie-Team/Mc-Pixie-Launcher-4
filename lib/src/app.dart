import 'dart:io';
import 'dart:math';
import 'package:mclauncher4/src/objects/accounts/minecraft.dart';
import 'package:mclauncher4/src/pages/debugpage.dart';
import 'package:mclauncher4/src/pages/modListPage.dart';
import 'package:mclauncher4/src/pages/settings_page/settingsPage.dart';
import 'package:mclauncher4/src/pages/splash/splash.dart';
import 'package:mclauncher4/src/pages/splash/splashLogin.dart';
import 'package:mclauncher4/src/pages/user_page/userPage.dart';
import 'package:mclauncher4/src/tasks/apis/modrinth.api.dart';
import 'package:mclauncher4/src/tasks/auth/microsoft.dart';
import 'package:mclauncher4/src/tasks/discordStatus/discordRP.dart';
import 'package:mclauncher4/src/tasks/fabric/fabric.dart';
import 'package:mclauncher4/src/tasks/forge/forge.dart';
import 'package:mclauncher4/src/tasks/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/installController.dart';
import 'package:mclauncher4/src/tasks/win32Deleter.dart';
import 'package:mclauncher4/src/widgets/SidePanel.dart';
import 'package:mclauncher4/src/widgets/components/sizetransitioncustom.dart';
import 'package:mclauncher4/src/tasks/utils/downloads.dart';
import 'package:mclauncher4/src/tasks/minecraft/client.dart';
import 'package:mclauncher4/src/tasks/version.dart';

import 'theme/colorSchemes.dart';
import 'theme/textSchemes.dart';
import 'package:flutter/material.dart';
import 'widgets/itemDrawer.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'widgets/menuItem.dart';
import 'widgets/divider.dart' as Div;
import 'package:animations/animations.dart';
import 'package:mclauncher4/src/widgets/SidePanel.dart';

class McLauncher extends StatelessWidget {
  const McLauncher({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true, colorScheme: lightColorScheme, typography: Typography(black: blackTextSchemes), scrollbarTheme: ScrollbarThemeData()),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme, typography: Typography(black: blackTextSchemes)),
      themeMode: ThemeMode.dark,
      home: MainPage(),
    );
  }
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int pageIndex = 0;
  int pageIndex_old = 0;
  EdgeInsets edgeInsets = EdgeInsets.only(left: 10, top: 12, right: 10, bottom: 12);
  final List<Widget> _pages = [
    ModListPage(),
    Debugpage(),
    Container(
      key: Key('3'),
      color: Color.fromARGB(255, 99, 167, 223),
    ),
    Container(
      key: Key('4'),
      color: Color.fromARGB(255, 146, 91, 218),
    ),
    SettingsPage(),
    UserPage()
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
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(onPressed: () async {
/*           await Minecraft().install('https://piston-meta.mojang.com/v1/packages/ed5d8789ed29872ea2ef1c348302b0c55e3f3468/1.7.10.json'); */
          // Map res = await Download().getJson('https://piston-meta.mojang.com/v1/packages/ed5d8789ed29872ea2ef1c348302b0c55e3f3468/1.7.10.json');
          // Minecraft().run(res, 'C:\\Users\\zepat\\Documents\\PixieLauncherInstances\\debug\\libraries');
/*           SidePanel().pop(
              Container(
                decoration: BoxDecoration(color: Colors.pinkAccent, borderRadius: BorderRadius.circular(18)),
              ),
              550); */

          /* await Forge().install();
          await Forge().run(); */
          /* Microsoft().authenticate(); */
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const pixieLoginScreen()),
          // );
          print((await MinecraftAccountUtils().getStandard())!.username);
        }),
        body: Stack(children: [
          Row(
            children: [
              //   NavigationDrawer(children: children)
              Container(
                height: double.infinity,
                width: 200,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant),
                child: Column(
                  children: [
                    Container(
                      height: 28,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Center(
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
                          int index = 4;
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
                        onChange: (index) {
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
                        ])
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
                transitionBuilder: (child, primaryAnimation, secondaryAnimation) => SharedAxisTransition(
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
          SizedBox(
            height: 35,
            child: Align(
                alignment: Alignment.topLeft,
                child: Row(
                  children: [Expanded(child: MoveWindow()), WindowButtons()],
                )),
          )
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
